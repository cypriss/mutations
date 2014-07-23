module Mutations
  class Outcome
    attr_reader :errors, :inputs, :result, :success
    alias_method :success?, :success

    def initialize(is_success, result, errors, inputs)
      @success, @result, @errors, @inputs = is_success, result, errors, inputs
    end
  end
end
