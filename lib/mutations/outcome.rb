module Mutations
  class Outcome
    attr_reader :result, :errors, :inputs

    def initialize(is_success, result, errors, inputs)
      @success, @result, @errors, @inputs = is_success, result, errors, inputs
    end

    def success?
      @success
    end

    def failure?
      !success?
    end
  end
end
