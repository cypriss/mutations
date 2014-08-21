module Mutations
  class ValidationException < ::StandardError
    attr_accessor :errors

    def initialize(errors)
      self.errors = errors
    end

    def to_s
      "#{errors.message_list.join('; ')}"
    end
  end
end
