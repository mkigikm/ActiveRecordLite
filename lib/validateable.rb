require_relative '01_sql_object'

module Validateable
#class SQLObject
  def self.validates(attribute, opts)
    validators << lambda do |to_validate|
      value = to_validate.send(attribute)

      opts.each do |test, test_options|
        case test
        when :presence
          return false if value.nil?
        when :length
          return false if value.length > test_options
        end
      end

      true
    end
  end

  def self.validators
    @validators ||= []
  end

  def valid?
    self.class.validators.all? { |validator| validator.call(self) }
  end
end

class SQLObject
  include Validateable
end
