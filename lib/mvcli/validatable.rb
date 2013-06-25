require "map"

module MVCLI::Validatable

  def self.included(base)
    base.extend ValidationDSL
  end

  def valid?
    validation.valid?
  end

  def validate!
    validation.validate!
  end

  def violations
    validation.violations
  end

  def validation
    validators.reduce(Validation.new(self)) do |validation, validator|
      validation.tap do
        validator.validate self, validation
      end
    end
  end

  def validators
    self.class.validators
  end

  class ValidationError < StandardError
    attr_reader :validation

    def initialize(validation)
      super "#{validation.object} is invalid"
      @validation = validation
    end

    def violations
      validation.violations
    end

    def each(&block)
      validation.each(&block)
    end
  end

  class Validator
    def initialize
      @rules = []
      @children = []
    end

    def validates(field, message, options = {}, &predicate)
      @rules << Rule.new(field, message, Map(options), predicate)
    end

    def validates_child(name)
      @children << name
    end

    def validate(object, validation = Validation.new(object))
      @rules.reduce(validation) do |v, rule|
        v.tap do
          rule.call object, v.violations, v.errors
        end
      end
      @children.each do |name|
        validate_child object, name, validation
      end
      return validation
    end

    def validate_child(object, name, validation)
      child = object.send(name) || []
      validation.append name, [child].flatten.map(&:validation)
    rescue StandardError => e
      validation.errors[name] << e
    end
  end


  class Validation
    attr_reader :object, :violations, :errors

    def initialize(object)
      @object = object
      @children = Map.new do |h,k|
        h[k] = []
      end
      @violations = Map.new do |h,k|
        h[k] = []
      end
      @errors = Map.new do |h,k|
        h[k] = []
      end
    end

    def valid?
      violations.empty? && errors.empty? && children_valid?
    end

    def validate!
      fail ValidationError, self unless valid?
    end

    def children_valid?
      @children.values.each do |validations|
        return false unless validations.all?(&:valid?)
      end
      return true
    end

    def [](key)
      @children[key]
    end

    def each(&block)
      @children.each &block
    end

    def append(name, validations)
      @children[name] += validations
    end
  end

  module ValidationDSL
    def validator
      @validator ||= Validator.new
    end

    def validators
      ancestors.reduce [] do |validators, base|
        validators.tap do
          validators << base.validator if base.respond_to?(:validator)
        end
      end
    end

    def validates(field, message, options = {}, &predicate)
      validator.validates field, message, options, &predicate
    end

    def validates_not(field, message, &predicate)
      validates(field, message) {|*_| !predicate.call(*_)}
    end

    def validates_child(name)
      validator.validates_child name
    end
  end

  class Rule
    def initialize(field, message, options, predicate)
      @field, @message, @options, @predicate = field, message, options, predicate
    end
    def call(validatable, violations, errors)
      value, error = read validatable
      if value.nil?
        return unless !!@options[:nil]
      end
      unless @predicate.call value
        violations[@field] << @message
      end
      errors[@field] << error if error
    end

    def read(validatable)
      return validatable.send(@field), nil
    rescue StandardError => e
      return nil, e
    end
  end
end
