require "map"

module MVCLI::Validatable

  def self.included(base)
    base.extend ValidationDSL
  end

  def valid?
    validation.valid?
  end

  def violations
    validation.violations
  end

  def validation
    validators.reduce(Validation.new) do |validation, validator|
      validation.tap do
        validator.validate self, validation
      end
    end
  end

  def validators
    self.class.validators
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

    def validate(validatable, validation)
      @rules.reduce(validation) do |v, rule|
        v.tap do
          rule.call validatable, v.violations, v.errors
        end
      end
      @children.each do |name|
        validation.append name,  [validatable.send(name)].flatten.map(&:validation)
      end
    end
  end


  class Validation
    attr_reader :violations, :errors

    def initialize
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
      value = validatable.send(@field)
      if value.nil?
        return unless !!@options[:nil]
      end
      unless @predicate.call value
        violations[@field] << @message
      end
    rescue Exception => e
      errors[@field] << e
    end
  end
end
