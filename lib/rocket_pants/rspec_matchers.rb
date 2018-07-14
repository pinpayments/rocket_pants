module RocketPants
  module RSpecMatchers
    extend RSpec::Matchers::DSL

    def self.normalised_error(e)
      if e.is_a?(String) || e.is_a?(Symbol)
        Errors[e]
      else
        e
      end
    end

    def self.normalise_urls(object)
      if object.is_a?(Array)
        object.each { |o| o['url'] = nil }
      elsif object.is_a?(Hash) || (defined?(APISmith::Smash) && object.is_a?(APISmith::Smash))
        object['url'] = nil
      end
      object
    end

    # Converts it to JSON and back again.
    def self.normalise_as_json(object, options = {})
      options = options.reverse_merge(:compact => true) if object.is_a?(Array)
      object = RocketPants::Respondable.normalise_object(object, options)
      j = ActiveSupport::JSON
      j.decode(j.encode({'response' => object}))['response']
    end

    def self.normalise_response(response, options = {})
      normalise_urls normalise_as_json response, options
    end

    def self.parsed_body(response)
     begin
        ActiveSupport::JSON.decode(response.body)
      rescue StandardError => e
        nil
      end
    end

    def self.decoded_body(response)
      begin
        decoded = parsed_body(response)
        if decoded.is_a?(Hash)
          Hashie::Mash.new(decoded)
        else
          decoded
        end
      end
    end

    def self.valid_for?(response, allowed, disallowed)
      body = decoded_body(response)
      return false if body.blank?
      body = body.to_hash
      return false if body.has_key?("error")
      allowed.all? { |f| body.has_key?(f) } && !disallowed.any? { |f| body.has_key?(f) }
    end

    def self.differ
      return @_differ if instance_variable_defined?(:@_differ)
      if defined?(RSpec::Support::Differ)
        @_differ = RSpec::Support::Differ.new
      elsif defined?(RSpec::Expectations::Differ)
        @_differ = RSpec::Expectations::Differ.new
      else
        @_differ = nil
      end
    end

    matcher :_be_api_error do |error_type|

      match do |response|
        @error = RSpecMatchers.decoded_body(response).error
        @error.present? && (error_type.blank? || RSpecMatchers.normalised_error(@error) == error_type)
      end

      failure_message_for_should do |response|
        if @error.blank?
          "expected #{error_type || "any error"} on response, got no error"
        else error_type.present? && (normalised = RSpecMatchers.normalised_error(@error)) != error_type
          "expected #{error_type || "any error"} but got #{normalised} instead"
        end
      end

      failure_message_for_should_not do |response|
        "expected response to not have an #{error_type || "error"}, but it did (#{@error})"
      end

    end

    matcher :be_singular_resource do

      match do |response|
        RSpecMatchers.valid_for? response, %w(), %w(count pagination)
      end

    end

    matcher :be_collection_resource do

      match do |response|
        RSpecMatchers.valid_for? response, %w(count), %w(pagination)
      end

    end

    matcher :be_paginated_resource do

      match do |response|
        RSpecMatchers.valid_for? response, %w(count pagination), %w()
      end

    end

    def be_api_error(error = nil)
      _be_api_error error
    end


  end
end
