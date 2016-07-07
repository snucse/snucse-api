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
end
