require 'spec_helper'
require 'active_model_serializers'

describe RocketPants::Base, 'active_model_serializers integration', :target => 'active_model_serializers', integration: 'true' do
  include ControllerHelpers

  use_reversible_tables :fish, :scope => :all

  # t.string  :name
  # t.string  :latin_name
  # t.integer :child_number
  # t.string  :token

  let(:fish)   { Fish.create! :name => "Test Fish", :latin_name => "Fishus fishii", :child_number => 1, :token => "xyz" }
  after(:each) { Fish.delete_all }

  class SerializerA < ActiveModel::Serializer
    attributes :name, :latin_name
  end

  class SerializerB < ActiveModel::Serializer
    attributes :name, :child_number
  end

  describe 'on instances' do

    it 'should let you disable the serializer' do
      with_config :serializers_enabled, false do
        allow(TestController).to receive(:test_data) { fish }
        expect(fish).to_not receive(:active_model_serializer)
        get :test_data
        content[:response].should be_present
        content[:response].should be_a Hash
      end
    end

    it 'should use the active_model_serializer' do
      allow(TestController).to receive(:test_data) { fish }
      allow(fish).to receive(:active_model_serializer) { SerializerB }
      expect(SerializerB).to receive(:new).with(fish, anything).and_call_original
      get :test_data
      content[:response].should be_present
      content[:response].should be_a Hash
      content[:response].keys.map(&:to_sym).should =~ [:name, :child_number]
    end

    it 'should let you specify a custom serializer' do
      allow(TestController).to receive(:test_data) { fish }
      allow(TestController).to receive(:test_options) { {:serializer => SerializerA} }
      expect(SerializerA).to receive(:new).with(fish, anything).and_call_original
      get :test_data
      content[:response].should be_present
      content[:response].should be_a Hash
      content[:response].keys.map(&:to_sym).should =~ [:name, :latin_name]
    end

    it 'should use serializable_hash without a serializer' do
      expect(SerializerA).to_not receive(:new).with(fish, anything)
      expect(SerializerB).to_not receive(:new).with(fish, anything)
      allow(TestController).to receive(:test_data) { fish }
      expected_keys = fish.serializable_hash.keys.map(&:to_sym)
      expect(fish).to receive(:serializable_hash).and_call_original
      get :test_data
      content[:response].should be_present
      content[:response].should be_a Hash
      content[:response].keys.map(&:to_sym).should =~ expected_keys
    end
  end

  describe 'on arrays' do

    it 'should work with array serializers' do
      allow(TestController).to receive(:test_data) { [fish] }
      allow(fish).to receive(:active_model_serializer) { SerializerB }
      expect(SerializerB).to receive(:new).with(fish, anything).and_call_original
      get :test_data
      content[:response].should be_present
      content[:response].should be_a Array
      serialized_fish = content[:response].first
      serialized_fish.should be_a Hash
      serialized_fish.keys.map(&:to_sym).should =~ [:name, :child_number]
    end

    it 'should support each_serializer' do
      allow(TestController).to receive(:test_data) { [fish] }
      expect(SerializerA).to receive(:new).with(fish, anything).and_call_original
      allow(TestController).to receive(:test_options) { {:each_serializer => SerializerA} }
      get :test_data
      content[:response].should be_present
      content[:response].should be_a Array
      serialized_fish = content[:response].first
      serialized_fish.should be_a Hash
      serialized_fish.keys.map(&:to_sym).should =~ [:name, :latin_name]
    end

    it 'should default to the serializable hash version' do
      expect(SerializerA).to_not receive(:new).with(fish, anything)
      expect(SerializerB).to_not receive(:new).with(fish, anything)
      allow(TestController).to receive(:test_data) { [fish] }
      expected_keys = fish.serializable_hash.keys.map(&:to_sym)
      expect(fish).to receive(:serializable_hash).and_call_original
      get :test_data
      content[:response].should be_present
      content[:response].should be_a Array
      serialized_fish = content[:response].first
      serialized_fish.should be_a Hash
      serialized_fish.keys.map(&:to_sym).should =~ expected_keys
    end
  end
end