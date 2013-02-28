module Mutations
  class Outcome
    def initialize(is_success, result, errors)
      @success, @result, @errors = is_success, result, errors
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
  end
end
