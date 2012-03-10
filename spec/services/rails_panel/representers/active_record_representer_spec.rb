require 'spec_helper'
require 'ostruct'
require_relative  '../../../../app/services/rails_panel/representers/active_record_representer.rb'

class FakeAssociation < OpenStruct
  def collection?
    collection
  end

  def options
    if super
      super
    else
      {}
    end
  end
end

class FakeColumns < OpenStruct
end

class FakeModel

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
    :discounts => {:macro => :has_many, :name => :discounts, :collection => true},
    :invoice => {:macro => :has_one, :name => :invoice, :collection => false}
  )
end

class Car < FakeModel
  build_fields
  build_associations(
    :clients => {:macro => :has_many, :options => {:through => :rentals}, :collection => true, :name => :clients},
    :rentals => {:macro => :has_many, :collection => true, :name => :rentals}
  )
end

class Client < FakeModel
  def self.all
    :method_all_in_client_called
  end
end

class Rental < FakeModel
  def self.all
    :method_all_in_rental_called
  end
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
  build_associations
  build_fields("birth_date" => {:type => :date})
  def self.all
    [OpenStruct.new(:_name => :foo, :id => 1),OpenStruct.new(:_name => :bar, :id => 2)]
  end
end

class Invoice < FakeModel
  def self.all
    [OpenStruct.new(:_name => :foo, :id => 1),OpenStruct.new(:_name => :bar, :id => 2)]
  end
end

class Discount < FakeModel
  def self.all
    :method_all_in_discount_called
  end
end

describe RailsPanel::Representers::ActiveRecordRepresenter do

  let(:article_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Article)
  end
  let(:order_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Order)
  end
  let(:product_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Product)
  end
  let(:customer_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Customer)
  end
  let(:discount_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Discount)
  end
  let(:invoice_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Invoice)
  end
  let(:foo_bar_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(FooBar)
  end
  let(:post_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Post)
  end
  let(:car_representer) do
    RailsPanel::Representers::ActiveRecordRepresenter.new(Car)
  end

  context "model fields" do

    it "should return all model fields" do
      article_representer.fields.keys.should == [:name, :content, :published_at]
    end

    it "should return proper fields attributes" do
      article_representer.fields[:name].should == {:display => :simple, :form_partial => 'text_field'}
      article_representer.fields[:content].should == {:display => :simple, :form_partial => 'text_area'}
      article_representer.fields[:published_at].should == {:display => :simple, :form_partial => 'date_time'}
      product_representer.fields[:in_store].should == {:display => :simple, :form_partial => 'text_field'}
      product_representer.fields[:price].should == {:display => :simple, :form_partial => 'text_field'}
      customer_representer.fields[:birth_date].should == {:display => :simple, :form_partial => 'date'}
    end
  end

  context "model associations" do

    it "should return all associations" do
      order_representer.associations.keys.should == [:products, :customer, :discounts, :invoice]
    end

    it "should return proper associations attributes" do
      products_asoc = order_representer.associations[:products]
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


      customer_asoc = order_representer.associations[:customer]
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

      discounts_asoc = order_representer.associations[:discounts]
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

      invoice_asoc = order_representer.associations[:invoice]
      invoice_asoc[:type].should == :association
      invoice_asoc[:form_partial].should == 'has_one'
      invoice_asoc[:association_type].should == :has_one
      invoice_asoc[:associated_model].should == Invoice
      invoice_asoc[:form_field].should == :invoice_id

      fake_object_to_call_display = OpenStruct.new(
        :invoice => OpenStruct.new(:_name => :foo)
      )
      invoice_asoc[:display].call(fake_object_to_call_display).should == :foo
      customer_asoc[:form_data].call.should == [[:foo, 1],[:bar, 2]]
    end

    context "has many throught" do
      it "should return proper associations attributes" do
        clients_asoc = car_representer.associations[:clients]
        clients_asoc[:type].should == :association
        clients_asoc[:form_partial].should == 'has_many'
        clients_asoc[:association_type].should == :has_many
        clients_asoc[:associated_model].should == Client
        clients_asoc[:form_field].should == :client_id
        clients_asoc[:through].should == :rentals

        fake_object_to_call_display = OpenStruct.new(
          :clients => [OpenStruct.new(:_name => :foo),OpenStruct.new(:_name => :bar)]
        )
        clients_asoc[:display].call(fake_object_to_call_display).should == [:foo, :bar]
        clients_asoc[:form_data].call.should == :method_all_in_client_called

        rentals_asoc = car_representer.associations[:rentals]
        rentals_asoc[:type].should == :association
        rentals_asoc[:form_partial].should == 'has_many'
        rentals_asoc[:association_type].should == :has_many
        rentals_asoc[:associated_model].should == Rental
        rentals_asoc[:form_field].should == :rental_id

        fake_object_to_call_display = OpenStruct.new(
          :rentals => [OpenStruct.new(:_name => :foo),OpenStruct.new(:_name => :bar)]
        )
        rentals_asoc[:display].call(fake_object_to_call_display).should == [:foo, :bar]
        rentals_asoc[:form_data].call.should == :method_all_in_rental_called
      end
      it "should not should not show its attributes in keys for form by default" do
        car_representer.form_attributes_keys.should == []
      end

      # TODO: sometimes we would like to see  it in show...
      it "should not show record related in has many through association in show and index" do
        car_representer.show_attributes_keys.should == [:rentals]
        car_representer.table_attributes_keys.should == []
      end
    end
  end

  it "should exclude association fields form fields" do
    order_representer.fields.keys.should == [:client_name, :notes]
  end

  it "should not show many model related in index" do
    order_representer.table_attributes_keys.should_not include(:discounts)
  end

  it "should not show habtm model related in index" do
    order_representer.table_attributes_keys.should_not include(:products)
  end

  it "should exclude id and timestamp from fields" do
    post_representer.fields.keys.should == [:name]
  end

  it "should has valid params_key property" do
    class FooBar < FakeModel
    end

    foo_bar_representer.properties[:params_key].should == :foo_bar
  end
end
