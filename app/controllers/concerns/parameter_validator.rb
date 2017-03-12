module ParameterValidator
  extend ActiveSupport::Concern
  class NonemptyStringValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
    end

    def validate(value)
      value.is_a? String and not value.empty?
    end

    def self.build(param_description, argument, options, block)
      if argument == String and options[:empty] == false
        self.new(param_description, argument)
      end
    end

    def description
      "Must be non-empty string."
    end
  end
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
  class FloatValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
      @type = argument
    end

    def validate(value)
      return false if value.nil?
      !!(value.to_s =~ /^[-+]?[0-9]+(\.[0-9]*)?$/)
    end

    def self.build(param_description, argument, options, block)
      if argument == Float
        self.new(param_description, argument)
      end
    end

    def description
      "Must be #{@type}."
    end
  end
  class IntegerArrayValidator < Apipie::Validator::BaseValidator
    def initialize(param_description, argument)
      super(param_description)
      @type = argument
    end

    def validate(value)
      return false unless value.is_a?(Array)
      value.all? do |v|
        !!(v.to_s =~ /^[-+]?[0-9]+$/)
      end
    end

    def self.build(param_description, argument, options, block)
      if argument == Array and options[:of] == Integer
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
  class NestedValidator < Apipie::Validator::BaseValidator # for Rails 5 fix
    def initialize(param_description, argument, param_group)
      super(param_description)
      @validator = Apipie::Validator::HashValidator.new(param_description, argument, param_group)
      @type = argument
    end

    def validate(value)
      value ||= []
      return false if value.class != Array
      value.each do |child|
        return false unless @validator.validate(child.to_unsafe_h)
      end
      true
    end

    def self.build(param_description, argument, options, block)
      self.new(param_description, block, options[:param_group]) if block.is_a?(Proc) && block.arity <= 0 && argument == Array
    end

    def description
      "Must be an Array of nested elements"
    end
  end
end
