module ParameterValidator
  extend ActiveSupport::Concern
  class IntegerValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
      @type = argument
    end

    def validate(value)
      return false if value.nil?
      !!(value.to_s =~ /^[-+]?[0-9]+$/)
    end

    def self.build(param_description, argument, options, block)
      if argument == Integer || argument == Fixnum
        self.new(param_description, argument)
      end
    end

    def description
      "Must be #{@type}."
    end
  end
  class BooleanValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
      @type = argument
    end

    def validate(value)
      return false if value.nil?
      ["0", "1", "true", "false"].include? value.to_s
    end

    def self.build(param_description, argument, options, block)
      if argument == TrueClass
        self.new(param_description, argument)
      end
    end

    def description
      "Must be #{@type}."
    end
  end
  class FileValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
      @type = argument
    end

    def validate(value)
      value.is_a?(Rack::Test::UploadedFile) || value.is_a?(ActionDispatch::Http::UploadedFile)
    end

    def self.build(param_description, argument, options, block)
      if argument == File
        self.new(param_description, argument)
      end
    end

    def description
      "Must be #{@type}."
    end
  end
  class FileArrayValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
      @type = argument
    end

    def validate(value)
      return false unless value.is_a?(Array)
      value.all? do |v|
        v.is_a?(Rack::Test::UploadedFile) || v.is_a?(ActionDispatch::Http::UploadedFile)
      end
    end

    def self.build(param_description, argument, options, block)
      if argument == Array and options[:of] == File
        self.new(param_description, argument)
      end
    end

    def description
      "Must be #{@type}."
    end
  end
end
