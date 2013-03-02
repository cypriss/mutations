module Mutations
  class Outcome
    def initialize(is_success, result, errors, inputs)
      @success, @result, @errors, @inputs = is_success, result, errors, inputs
    end

    def success?
      @success
    end

    def result
      @result
    end

    def errors
      @errors
    end
    
    def inputs
      @inputs
    end
  end
end
