require 'spec_helper'
require 'will_paginate/collection'
require 'will_paginate/active_record'

describe RocketPants::Base, 'will_paginate integration', :target => 'will_paginate', integration: true do
  include ControllerHelpers

  describe 'on models' do

    use_reversible_tables :users, :scope => :all

    before :all do
      25.times { |i| User.create :age => (18 + i) }
    end

    it 'should let you expose a classically paginated collection' do
      allow(TestController).to receive(:test_data) { User.paginate(:per_page => 5, :page => 1) }
      get :test_data
      content[:response].should be_present
      content[:count].should == 5
      content[:pagination].should be_present
      content[:pagination][:count].should == 25
    end

    it 'should not expose non-paginated as paginated' do
      allow(TestController).to receive(:test_data) { User.all }
      get :test_data
      content[:response].should be_present
      content[:count].should == 25
      content[:pagination].should_not be_present
    end

    it 'should let you expose a relational collection' do
      allow(TestController).to receive(:test_data) { User.limit(5).all }
      get :test_data
      content[:response].should be_present
      content[:count].should == 5
    end
  end

  describe 'on arrays' do

    it 'should correctly convert a will paginate collection' do
      pager = WillPaginate::Collection.create(2, 10) { |p| p.replace %w(a b c d e f g h i j); p.total_entries = 200 }
      allow(TestController).to receive(:test_data) { pager }
      get :test_data
      content.should have_key(:pagination)
      content[:pagination].should == {
        :next => 3,
        :current => 2,
        :previous => 1,
        :pages => 20,
        :count => 200,
        :per_page => 10
      }.stringify_keys
      content.should have_key(:count)
      content[:count].should == 10
    end
    
  end

end