require 'spec_helper'

describe RocketPants, 'Configuration' do

  describe 'the environment' do

    around do |test|
      restoring_env 'RAILS_ENV', 'RACK_ENV' do
        with_config :env, nil, &test
      end
    end

    it 'should have an environment' do
      RocketPants.env.should be_present
      RocketPants.env.should be_a ActiveSupport::StringInquirer
    end

    it 'should set it correctly' do
      RocketPants.env = "my_new_env"
      RocketPants.env.should == "my_new_env"
      RocketPants.env.should be_a ActiveSupport::StringInquirer
    end

    context "Rails.env is present" do
      before do
        allow(Rails).to receive(:env) { "production".inquiry }
      end
      it "should default to Rails env" do
        RocketPants.env.production?.should eq true
        RocketPants.env.staging?.should eq false
        RocketPants.env.development?.should eq false
      end
    end
    context "Rails env is not present" do
      before do
        allow(Rails).to receive(:env) { nil }
      end
      context "RAILS_ENV and RACK_ENV are present" do
        before do
          allow(ENV).to receive(:[]).with("RAILS_ENV").and_return("production")
          allow(ENV).to receive(:[]).with("RACK_ENV").and_return("staging")
        end
        it "should default to RAILS_ENV" do
          expect(RocketPants.env.production?).to eq(true)
          expect(RocketPants.env.staging?).to eq(false)
          expect(RocketPants.env.development?).to eq(false)
        end
      end
      context "RACK_ENV is only present" do
        before do
          allow(ENV).to receive(:[]).with("RAILS_ENV").and_return(nil)
          allow(ENV).to receive(:[]).with("RACK_ENV").and_return("staging")
        end
        it "should default to RACK_ENV" do
          expect(RocketPants.env.production?).to eq(false)
          expect(RocketPants.env.staging?).to eq(true)
          expect(RocketPants.env.development?).to eq(false)
        end
      end
      context "RAILS_ENV and RACK_ENV are not present" do
        before do
          allow(ENV).to receive(:[]).with("RAILS_ENV").and_return(nil)
          allow(ENV).to receive(:[]).with("RACK_ENV").and_return(nil)
        end
        it "should default to development environment" do
          expect(RocketPants.env.production?).to eq(false)
          expect(RocketPants.env.staging?).to eq(false)
          expect(RocketPants.env.development?).to eq(true)
        end
      end
    end

    it 'should let you restore the environment' do
      RocketPants.env = 'other'
      RocketPants.env = nil
      RocketPants.env.should == RocketPants.default_env
    end
  end

  describe 'passing through errors' do

    around :each do |test|
      with_config :pass_through_errors, nil, &test
    end

    it 'should allow you to force it to false' do
      RocketPants.pass_through_errors = false
      RocketPants.should_not be_pass_through_errors
    end

    it 'should allow you to force it to true' do
      RocketPants.pass_through_errors = true
      RocketPants.should be_pass_through_errors
    end

    it 'should default to if the env is dev or test' do
      %w(development test).each do |environment|
        allow(RocketPants).to receive(:env) { ActiveSupport::StringInquirer.new(environment) }
        RocketPants.pass_through_errors = nil
        RocketPants.should be_pass_through_errors
      end
    end

    it 'should default to false in other envs' do
      %w(production staging).each do |environment|
        allow(RocketPants).to receive(:env) { ActiveSupport::StringInquirer.new(environment) }
        RocketPants.pass_through_errors = nil
        RocketPants.should_not be_pass_through_errors
      end
    end

  end

  describe 'showing exception messages' do

    around :each do |test|
      with_config :show_exception_message, nil, &test
    end

    it 'should allow you to force it to false' do
      RocketPants.show_exception_message = false
      RocketPants.should_not be_show_exception_message
    end

    it 'should allow you to force it to true' do
      RocketPants.show_exception_message = true
      RocketPants.should be_show_exception_message
    end

    it 'should default to true in test and development' do
      %w(development test).each do |environment|
        allow(RocketPants).to receive(:env) { ActiveSupport::StringInquirer.new(environment) }
        RocketPants.show_exception_message = nil
        RocketPants.should be_show_exception_message
      end
    end

    it 'should default to false in other environments' do
      %w(production staging somethingelse).each do |environment|
        allow(RocketPants).to receive(:env) { ActiveSupport::StringInquirer.new(environment) }
        RocketPants.show_exception_message = nil
        RocketPants.should_not be_show_exception_message
      end
    end
  end
end