module Mutations
  module DependentValidations

    # This module allows you to declare dependencies between your validatios and only run them if
    # all the validations they depend on have already been run and passed.
    #
    # For example, suppose you have a user whose email TLD must match their country, but they may
    # not have provided a location yet. You might define the command like so:
    #
    # class UpdateEmail < Mutations::Command
    #   def validate
    #     validate_country_code
    #     validate_email
    #   end
    #
    #   def validate_country_code
    #     return unless user.country_code.blank?
    #
    #     add_error(:country, :not_provided, "You must provide your location first")
    #   end
    #
    #   def validate_email
    #     return if user.country_code.blank?
    #     return if email.tld == user.country_code
    #
    #     add_error(:email, :mismatching_tld, "Your email's TLD must match your country code")
    #   end
    # end
    #
    # But this can quickly become unwieldy as validations further depend on each other. Failing to
    # add the correct guards can result in confusing error messages (in this case, telling the user
    # their email must match their country code, which they never provided).
    #
    # With this module, this becomes:
    #
    # class UpdateEmail < Mutations::Command
    #   include Mutations::DependentValidations
    #
    #   def validations
    #     {
    #       validate_country_code:[],
    #       validate_email: %i[validate_country_code],
    #     }
    #   end
    #
    #   def validate_country_code
    #     return unless user.country_code.blank?
    #
    #     add_error(:country, :not_provided, "You must provide your location first")
    #   end
    #
    #   def validate_email
    #     return if email.tld == user.country_code
    #
    #     add_error(:email, :mismatching_tld, "Your email's TLD must match your country code")
    #   end
    # end
    #
    # Importantly, note that we no longer invert #validate_country_code's guards in #validate_email,
    # nor do we provide an implementation of #validate, which is provided by the module.

    CyclicDependencyError = Class.new(StandardError)
    InvalidValidationsError = Class.new(StandardError)
    UndefinedValidationsError = Class.new(StandardError)
    UndeclaredValidationError = Class.new(StandardError)

    def validate
      raise UndefinedValidationsError, "No validations provided (as .validations class method)" unless self.class.respond_to?(:validations, true)

      validations = self.class.validations
      raise InvalidValidationsError, "All validations and dependencies must be symbols" unless validations.all? { |k,v| k.class == Symbol && v.all? { |dep| dep.class == Symbol } }

      undeclared_validations = validations.values.flatten.uniq - validations.keys
      raise UndeclaredValidationError, "Undeclared validations: #{undeclared_validations}, all dependencies must be explicit" if undeclared_validations.any?

      validation_outcomes = {}
      validations.keys.each do |validation|
        # This executes validations and their dependencies, depth-first. In the example above, we
        # would always run the address check first, regardless of the order in which .validations
        # defines the dependencies.
        recursively_run_validation(validation, validation_outcomes, Set.new)
      end
    end

    def recursively_run_validation(validation, outcomes, seen_validations)
      # If we already ran this validation, it's a met dependency and we can ignore it.
      return if outcomes.key?(validation)
      raise CyclicDependencyError, "Encountered #{validation} twice when evaluating validation dependencies" if seen_validations.member?(validation)

      seen_validations.add(validation)
      depends_on = self.class.validations[validation]
      depends_on.each do |dependency|
        recursively_run_validation(dependency, outcomes, seen_validations)
      end

      outcomes[validation] = if depends_on.all? { |dependency| outcomes[dependency] == :success }
        # No errors defined is equivalent to zero errors in this context.
        error_count = ->() { (defined?(@errors) && !@errors.nil?) ? @errors.size : 0 }
        initial_error_count = error_count.call
        send(validation)
        (initial_error_count == error_count.call) ? :success : :fail
      else
        :skipped
      end
    end

  end
end
