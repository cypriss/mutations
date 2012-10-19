module Mutations
  class ValidationException < ::StandardError
    attr_accessor :errors
    
    def initialize(errors)
      self.errors = errors
    end
    
    def to_s
      "Mutations::ValidationException: #{self.errors.to_s}"
    end
  end
end