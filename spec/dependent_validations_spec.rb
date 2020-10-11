require 'spec_helper'
require '../lib/mutations/dependent_validations'

describe "Mutations::DependentValidations" do

  describe "invalid graphs" do
    class CyclicCommand
      include Mutations::DependentValidations

      def self.validations
        {
          independent_validation: [],
          cyclic_validation_1: %i[cyclic_validation_2],
          cyclic_validation_2: %i[cyclic_validation_1],
        }
      end

      def independent_validation; end
    end

    it "rejects cyclic graphs" do
      assert_raises(Mutations::DependentValidations::CyclicDependencyError) do
        CyclicCommand.new.validate
      end
    end

    class NoEntryCommand
      include Mutations::DependentValidations

      def self.validations
        {
          dependent_validation: %i[undeclared_validation],
        }
      end
    end

    it "rejects graphs with undeclared validations" do
      assert_raises(Mutations::DependentValidations::UndeclaredValidationError) do
        NoEntryCommand.new.validate
      end
    end

    class IncorrectlyTypedCommand
      include Mutations::DependentValidations

      def self.validations
        {
          dependent_validation: [->() { true }],
        }
      end
    end

    it "rejects graphs of the wrong type" do
      assert_raises(Mutations::DependentValidations::InvalidValidationsError) do
        IncorrectlyTypedCommand.new.validate
      end
    end

    class NoValidationCommand
      include Mutations::DependentValidations
    end

    it "rejects undefined graphs" do
      assert_raises(Mutations::DependentValidations::UndefinedValidationsError) do
        NoValidationCommand.new.validate
      end
    end
  end
  
  describe "running validations" do
    class DependentCommand < Mutations::Command
      include Mutations::DependentValidations

      attr_reader :called_validations

      def self.validations
        {
          no_dependents: [],
          independent_validation_1: [],
          independent_validation_2: [],
          dependent_validation_1: %i[independent_validation_1],
          dependent_validation_2: %i[independent_validation_2],
          dependent_validation_3: %i[dependent_validation_1 dependent_validation_2],
          dependent_validation_4: %i[independent_validation_1 dependent_validation_1],
        }
      end

      def initialize(passing_validations)
        @passing_validations = passing_validations
        @called_validations = []
      end

      def no_dependents
        @called_validations << __callee__
        add_error(__callee__, :failed, "oh no") unless @passing_validations.include?(__callee__)
      end
      alias_method :independent_validation_1, :no_dependents
      alias_method :independent_validation_2, :no_dependents
      alias_method :dependent_validation_1, :no_dependents
      alias_method :dependent_validation_2, :no_dependents
      alias_method :dependent_validation_3, :no_dependents
      alias_method :dependent_validation_4, :no_dependents

    end

    it "runs all validations successfully" do
      all_validations = DependentCommand.validations.keys
      command = DependentCommand.new(all_validations)
      command.validate

      assert_equal all_validations.sort, command.called_validations.sort
    end

    it "skips validations whose dependencies failed" do
      all_validations = DependentCommand.validations.keys 
      passing_validations = all_validations - [:independent_validation_2]
      dependent_validations = [:dependent_validation_2, :dependent_validation_3]
      command = DependentCommand.new(passing_validations)
      command.validate

      assert_equal (all_validations - dependent_validations).sort, command.called_validations.sort 
    end
  end

end
