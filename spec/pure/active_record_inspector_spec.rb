require 'rspec'
require 'ostruct'
require_relative  '../../app/models/rails_panel/active_record_inspector.rb'

class FakeAssociation < OpenStruct
  def collection?
    collection
  end
end

class FakeColumns < OpenStruct
end

class FakeModel
  include RailsPanel::ActiveRecordInspector

  class << self
    attr_reader :columns_hash
    def build_fields(_fields = {})
      @columns_hash = {}
      _fields.each do |key,value|
        @columns_hash[key] = FakeColumns.new(value)
      end
    end

    attr_reader :reflections
    def build_associations(_associations = {})
      @reflections = {}
      _associations.each do |key,value|
        @reflections[key] = FakeAssociation.new(value)
      end
    end
  end
end

class Order < FakeModel
  build_fields("client_name" => {:type => :string}, "notes" => {:type => :text}, "customer_id" => {:type => :integer})

  build_associations(
    :products  => {:macro => :has_and_belongs_to_many, :name => :products, :class_name => "Product", :association_foreign_key => 'product_id', :collection => true},
    :customer  => {:macro => :belongs_to, :name => :customer, :collection => false},
    :discounts => {:macro => :has_many, :name => :discounts, :collection => true}
  )
end

class Article < FakeModel
  build_associations
  build_fields({"name" => {:type => :string}, "content" => {:type => :text}, "published_at" => {:type => :datetime}})
end

class Post < FakeModel
  build_associations
  build_fields({"name" => {:type => :string}, "id" => {:type => :integer}, "created_at" => {:type => :datetime}, "updated_at" => {:type => :datetime}})
end

class Product < FakeModel
  build_associations
  build_fields("name" => {:type => :string}, "in_store" => {:type => :integer}, "price" => {:type => :float})

  def self.all
    :method_all_in_product_called
  end
end

class Customer < FakeModel
  def self.all
    [OpenStruct.new(:_name => :foo, :id => 1),OpenStruct.new(:_name => :bar, :id => 2)]
  end
end

class Discount < FakeModel
  def self.all
    :method_all_in_discount_called
  end
end
describe RailsPanel::ActiveRecordInspector do
  context "model fields" do

    it "should return all model fields" do
      Article.fields.keys.should == [:name, :content, :published_at]
    end

    it "should return proper fields attributes" do
      Article.fields[:name].should == {:display => :simple, :form_partial => 'text_field'}
      Article.fields[:content].should == {:display => :simple, :form_partial => 'text_area'}
      Article.fields[:published_at].should == {:display => :simple, :form_partial => 'text_field'}
      Product.fields[:in_store].should == {:display => :simple, :form_partial => 'text_field'}
      Product.fields[:price].should == {:display => :simple, :form_partial => 'text_field'}
    end
  end

  context "model associations" do

    it "should return all associations" do
      Order.associations.keys.should == [:products, :customer, :discounts]
    end

    it "should return proper associations attributes" do
      products_asoc = Order.associations[:products]
      products_asoc[:type].should == :association
      products_asoc[:form_partial].should == 'has_many'
      products_asoc[:association_type].should == :has_and_belongs_to_many
      products_asoc[:associated_model].should == Product
      products_asoc[:form_field].should == :product_id

      fake_object_to_call_display = OpenStruct.new(
        :products => [OpenStruct.new(:_name => :foo),OpenStruct.new(:_name => :bar)]
      )
      products_asoc[:display].call(fake_object_to_call_display).should == [:foo,:bar]
      products_asoc[:form_data].call.should == :method_all_in_product_called


      customer_asoc = Order.associations[:customer]
      customer_asoc[:type].should == :association
      customer_asoc[:form_partial].should == 'belongs_to'
      customer_asoc[:association_type].should == :belongs_to
      customer_asoc[:associated_model].should == Customer
      customer_asoc[:form_field].should == :customer_id

      fake_object_to_call_display = OpenStruct.new(
        :customer => OpenStruct.new(:_name => :foo)
      )
      customer_asoc[:display].call(fake_object_to_call_display).should == :foo
      customer_asoc[:form_data].call.should == [[:foo, 1],[:bar, 2]]

      discounts_asoc = Order.associations[:discounts]
      discounts_asoc[:type].should == :association
      discounts_asoc[:form_partial].should == 'has_many'
      discounts_asoc[:association_type].should == :has_many
      discounts_asoc[:associated_model].should == Discount
      # precisely, it is discount_ids, but I'm changing it in has_many partial
      # TODO: or it should be placed here?
      discounts_asoc[:form_field].should == :discount_id

      fake_object_to_call_display = OpenStruct.new(
        :discounts => [OpenStruct.new(:_name => :foo),OpenStruct.new(:_name => :bar)]
      )
      discounts_asoc[:display].call(fake_object_to_call_display).should == [:foo, :bar]
      discounts_asoc[:form_data].call.should == :method_all_in_discount_called
    end
  end

  it "should exclude association fields form fields" do
    Order.fields.keys.should == [:client_name, :notes]
  end

  it "should exclude id and timestamp from fields" do
    Post.fields.keys.should == [:name]
  end
end


