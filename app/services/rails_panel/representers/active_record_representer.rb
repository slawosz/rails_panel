require 'active_support/concern'
require 'active_support/core_ext/string'
require 'active_support/inflector'

module RailsPanel
  module Representers
    class ActiveRecordRepresenter

      def initialize(model)
        @model = model
      end
      # returns model fields hash, where field is key and its value is hash with keys:
      # * :display - how to display the hash, default has value :simple
      # * :form_partial - which partial will be used to display this field in form,
      # by default type_to_partial using field type.
      #
      # This method may be inherited when you want to provide custom partial:
      #
      #   class MyModel < ActiveRecord::Base
      #     inculde RailsPanel::ActiveRecordInspector
      #
      #     def fields
      #       super.merge(:field_to_customize => {:form_partial => :my_partial, :display => :simple})
      #     end
      #   end
      #
      # :my_partial will be _my_partial from app view path
      #
      #  But in most cases for this customization is recomended to override {RailsPanel::ActiveRecordInspector.attributes} or
      #  {RailsPanel::ResourcesHelper.attributes}
      def fields
        fields = {}
        @model.columns_hash.each do |field,data|
          fields[field.to_sym] = {:form_partial => type_to_partial[data.type], :display => :simple}
        end
        associations.each_value do |data|
          fields.delete(data[:form_field])
        end
        excluded_fields.each do |field|
          fields.delete field
        end
        fields
      end

      # returns model associations hash, where association name is key which value is hash
      # with keys:
      # * :type - informs that is association, has value :association
      # * :form_partial - which partial will be used to display this field in form, generaly it is determined by type_to_partial using association_type.
      # * :associatied_model - class of model that is associated
      # * :association_type - type of association (has_many, belongs_to and so on)
      # * :form_field - field used for html input
      # * :display - proc which get one parameter (model instance) and returns String (based on model _name method) or Array of string, used for displaying associated record(s) in show page
      # * :form_data - proc which return data to display in form input, used for selecting associated records
      # * :through - if model is associated with another with has many through association, this key stores association used for through association
      #
      # For customization, see ActiveRecordInspector.attributes docs
      def associations
        @assocs ||= {}
        @form_excluded_keys = []
        @show_and_table_excluded_keys = []
        @table_excluded_keys = []
        @model.reflections.each do |name, data|
          @assocs[name] = {
            :type => :association,
            :form_partial => type_to_partial[data.macro],
            :associated_model => name.to_s.classify.singularize.constantize,
            :association_type => data.macro,
            :form_field => (name.to_s.singularize + "_id").to_sym,
            :display => data.collection? ? lambda {|obj| obj.send(name).map{|a| label_for(a)}} : lambda {|obj| (rel_obj = obj.send(name)) ? label_for(rel_obj) : nil},
            :form_data => form_data_proc_for_association(name.to_s.classify.singularize.constantize)[data.macro],
            :through => data.options[:through]
          }
          if (to_exclude = data.options[:through])
            @form_excluded_keys << to_exclude << name
            @show_and_table_excluded_keys << name
          end
          if data.macro == :has_many || data.macro == :has_and_belongs_to_many
            @table_excluded_keys << name
          end
        end
        @assocs
      end

      # returns hash which key is field or association type and value is a partial
      # that will be displayed in form
      def type_to_partial
        {
          :text => 'text_area',
          :string => 'text_field',
          :integer => 'text_field',
          :float => 'text_field',
          :datetime => 'date_time',
          :date => 'date',
          :belongs_to => 'belongs_to',
          :has_many   => 'has_many',
          :has_one   => 'has_one',
          :has_and_belongs_to_many => 'has_many',
        }
      end
      private :type_to_partial

      def form_data_proc_for_association(model_class)
        {
          :belongs_to => lambda { model_class.all.map{ |c| [label_for(c), c.id] }},
          :has_one => lambda { model_class.all.map{ |c| [label_for(c), c.id] }},
          :has_many   => lambda { model_class.all },
          :has_and_belongs_to_many => lambda { model_class.all }
        }
      end
      private :form_data_proc_for_association

      # model properties
      # * :params_key - key that will be used to get model data form params hash
      def properties
        {
          :params_key => @model.name.underscore.to_sym
        }
      end

      def associations_keys
        associations.keys
      end

      def fields_keys
        fields.keys
      end

      # This is one of the most important method in RailsPanel.
      # Return attributes hash, ie fields + model association.
      # Stores all data required for displaying model in RailsPanel.
      #
      # When you want to customize displaying or form you should overide this method.
      # For hash details see ActiveRecordInspector.associations and ActiveRecordInspector.fields
      #
      # Example:
      #
      # class MyModel < ActiveRecord::Base
      #   inculde RailsPanel::ActiveRecordInspector
      #
      #   def attributes
      #     custom_attributes = :field_or_association => {...} #some hash for field or association
      #     super.merge(custom_attributes)
      #   end
      # end
      #
      # This method is used in RailsPanel::ResourceHelper, where it will be overiding in most cases.
      def attributes
        fields.merge associations
      end

      # This method is used in view to iterate through attributes, we want to display.
      #
      # Returns array of symbols:
      # [:title, :content, :comments]
      #
      # By overide this method, you can:
      # * disable some attribute (field or association)
      # * change order for displaying
      #
      # Also by overidding you can add custom attributes, that dont exists in model.
      # When you add such attributes you should also override attributes method, to provide
      # partial for display. This is very usefull for nested_attributes, javascript widgets like
      # inputToken or uploadiffy
      #
      # For real life examples see wiki
      #
      def attributes_keys
        associations_keys + fields_keys
      end

      def show_and_table_attributes
        attributes
      end

      def show_and_table_attributes_keys
        show_and_table_attributes.keys - @show_and_table_excluded_keys
      end

      # Attributes hash used only in show action, so overiding this methods
      # affects only show actions
      def show_attributes
        show_and_table_attributes
      end

      def show_attributes_keys
        show_attributes.keys - @show_and_table_excluded_keys
      end

      def table_attributes
        show_and_table_attributes
      end

      def table_attributes_keys
        (table_attributes.keys - @show_and_table_excluded_keys) - @table_excluded_keys
      end

      def form_attributes
        attributes
      end

      def form_attributes_keys
        form_attributes.keys - @form_excluded_keys
      end

      # fields that are not displayed by default
      def excluded_fields
        [:id, :created_at, :updated_at]
      end

      def label_for(obj)
        if obj.respond_to? :name
          return obj.name
        end
        if obj.respond_to? :title
          return obj.title
        end
        obj.class.name + obj.id.to_s
      end
    end
  end
end
