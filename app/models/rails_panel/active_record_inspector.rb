require 'active_support/concern'
require 'active_support/core_ext/string'
require 'active_support/inflector'

module RailsPanel
  module ActiveRecordInspector
    extend ActiveSupport::Concern

    module ClassMethods

      # returns model fields hash, where field is key and its value is hash with keys:
      # * :display - how to display the hash, default has value :simple
      # * :form_partial - which partial will be used to display this field in form,
      # generaly it is determined by type_to_partial using field type.
      def fields
        fields = {}
        self.columns_hash.each do |field,data|
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
      # * :form_partial - which partial will be used to display this field in form,
      # generaly it is determined by type_to_partial using association_type.
      # * :associatied_model - class of model that is associated
      # * :association_type - type of association (has_many, belongs_to and so on)
      # * :form_field - field used for html input
      # * :display - proc which get one parameter (model instance) and returns String (based on model _name method) or Array of string,
      # used for displaying associated record(s) in show page
      # * :form_data - proc which return data to display in form input, used for selecting associated records
      # * :through - if model is associated with another with has many through association, this key stores association used for through association
      def associations
        @assocs ||= {}
        @form_excluded_keys = []
        @show_and_table_excluded_keys = []
        @table_excluded_keys = []
        self.reflections.each do |name, data|
          @assocs[name] = {
            :type => :association,
            :form_partial => type_to_partial[data.macro],
            :associated_model => name.to_s.classify.singularize.constantize,
            :association_type => data.macro,
            :form_field => (name.to_s.singularize + "_id").to_sym,
            :display => data.collection? ? lambda {|obj| obj.send(name).map{|a| a.send(:_name)}} : lambda {|obj| (rel_obj = obj.send(name)) ? rel_obj.send(:_name) : nil},
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
          :belongs_to => lambda { model_class.all.map{ |c| [c._name, c.id] }},
          :has_one => lambda { model_class.all.map{ |c| [c._name, c.id] }},
          :has_many   => lambda { model_class.all },
          :has_and_belongs_to_many => lambda { model_class.all }
        }
      end
      private :form_data_proc_for_association

      # model properties
      # * :params_key - key that will be used to get model data form params hash
      def properties
        {
          :params_key => self.name.underscore.to_sym
        }
      end

      def associations_keys
        associations.keys
      end

      def fields_keys
        fields.keys
      end

      def attributes
        fields.merge associations
      end

      def attributes_keys
        associations_keys + fields_keys
      end

      def show_and_table_attributes
        attributes
      end

      def show_and_table_attributes_keys
        show_and_table_attributes.keys - @show_and_table_excluded_keys
      end

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


      def excluded_fields
        [:id, :created_at, :updated_at]
      end
    end

    module InstanceMethods
      def _name
        if self.respond_to? :name
          return self.name
        end
        if self.respond_to? :title
          return self.title
        end
        self.class.name + self.id.to_s
      end
    end
  end
end
