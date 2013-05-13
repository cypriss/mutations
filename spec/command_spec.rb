require 'spec_helper'
require 'simple_command'

describe "Command" do

  describe "SimpleCommand" do
    it "should allow valid in put in" do
      outcome = SimpleCommand.run(:name => "John", :email => "john@gmail.com", :amount => 5)

      assert outcome.success?
      assert_equal ({:name => "John", :email => "john@gmail.com", :amount => 5}).stringify_keys, outcome.result
      assert_equal nil, outcome.errors
    end

    it "should filter out spurious params" do
      outcome = SimpleCommand.run(:name => "John", :email => "john@gmail.com", :amount => 5, :buggers => true)

      assert outcome.success?
      assert_equal ({:name => "John", :email => "john@gmail.com", :amount => 5}).stringify_keys, outcome.result
      assert_equal nil, outcome.errors
    end

    it "should discover errors in inputs" do
      outcome = SimpleCommand.run(:name => "JohnTooLong", :email => "john@gmail.com")

      assert !outcome.success?
      assert_equal :max_length, outcome.errors.symbolic[:name]
    end

    it "shouldn't throw an exception with run!" do
      result = SimpleCommand.run!(:name => "John", :email => "john@gmail.com", :amount => 5)
      assert_equal ({:name => "John", :email => "john@gmail.com", :amount => 5}).stringify_keys, result
    end

    it "should throw an exception with run!" do
      assert_raises Mutations::ValidationException do
        result = SimpleCommand.run!(:name => "John", :email => "john@gmail.com", :amount => "bob")
      end
    end

    it "should do standalone validation" do
      outcome = SimpleCommand.validate(:name => "JohnLong", :email => "john@gmail.com")
      assert outcome.success?
      assert_nil outcome.result
      assert_nil outcome.errors

      outcome = SimpleCommand.validate(:name => "JohnTooLong", :email => "john@gmail.com")
      assert !outcome.success?
      assert_nil outcome.result
      assert_equal :max_length, outcome.errors.symbolic[:name]
    end

    it "should merge multiple hashes" do
      outcome = SimpleCommand.run({:name => "John", :email => "john@gmail.com"}, {:email => "bob@jones.com", :amount => 5})

      assert outcome.success?
      assert_equal ({:name => "John", :email => "bob@jones.com", :amount => 5}).stringify_keys, outcome.result
    end

    it "should merge hashes indifferently" do
      outcome = SimpleCommand.run({:name => "John", :email => "john@gmail.com"}, {"email" => "bob@jones.com", "amount" => 5})

      assert outcome.success?
      assert_equal ({:name => "John", :email => "bob@jones.com", :amount => 5}).stringify_keys, outcome.result
    end

    it "shouldn't accept non-hashes" do
      assert_raises ArgumentError do
        outcome = SimpleCommand.run(nil)
      end

      assert_raises ArgumentError do
        outcome = SimpleCommand.run(1)
      end

      assert_raises ArgumentError do
        outcome = SimpleCommand.run({:name => "John"}, 1)
      end
    end

    it "should accept nothing at all" do
      SimpleCommand.run # make sure nothing is raised
    end

    it "should return the filtered inputs in the outcome" do
      outcome = SimpleCommand.run(:name => " John ", :email => "john@gmail.com", :amount => "5")
      assert_equal ({:name => "John", :email => "john@gmail.com", :amount => 5}).stringify_keys, outcome.inputs
    end
  end

  describe "EigenCommand" do
    class EigenCommand < Mutations::Command

      required { string :name }
      optional { string :email }

      def execute
        {:name => inputs[:name], :email => email}
      end
    end

    it "should define getter methods on params" do
      mutation = EigenCommand.run(:name => "John", :email => "john@gmail.com")
      assert_equal ({:name => "John", :email => "john@gmail.com"}), mutation.result
    end
  end

  describe "MutatatedCommand" do
    class MutatatedCommand < Mutations::Command

      required { string :name }
      optional { string :email }

      def execute
        inputs[:name], self.email = "bob", "bob@jones.com"
        {:name => inputs[:name], :email => inputs[:email]}
      end
    end

    it "should define setter methods on params" do
      mutation = MutatatedCommand.run(:name => "John", :email => "john@gmail.com")
      assert_equal ({:name => "bob", :email => "bob@jones.com"}), mutation.result
    end
  end

  describe "ErrorfulCommand" do
    class ErrorfulCommand < Mutations::Command

      required { string :full_name }
      optional { string :email }

      def execute
        add_error("bob", :is_a_bob)

        1
      end
    end

    it "should let you add errors" do
      outcome = ErrorfulCommand.run(:name => "John", :email => "john@gmail.com")

      assert !outcome.success?
      assert_nil outcome.result
      assert :is_a_bob, outcome.errors.symbolic[:bob]
    end
  end

  describe "MultiErrorCommand" do
    class ErrorfulCommand < Mutations::Command

      required { string :full_name }
      optional { string :email }

      def execute
        moar_errors = Mutations::ErrorHash.new
        moar_errors[:bob] = Mutations::ErrorAtom.new(:bob, :is_short)
        moar_errors[:sally] = Mutations::ErrorAtom.new(:sally, :is_fat)

        merge_errors(moar_errors)

        1
      end
    end

    it "should let you merge errors" do
      outcome = ErrorfulCommand.run(:name => "John", :email => "john@gmail.com")

      assert !outcome.success?
      assert_nil outcome.result
      assert :is_short, outcome.errors.symbolic[:bob]
      assert :is_fat, outcome.errors.symbolic[:sally]
    end
  end

  describe "PresentCommand" do
    class PresentCommand < Mutations::Command

      optional do
        string :email
        string :full_name
      end

      def execute
        if full_name_present? && email_present?
          1
        elsif !full_name_present? && email_present?
          2
        elsif full_name_present? && !email_present?
          3
        else
          4
        end
      end
    end

    it "should handle *_present? methods" do
      assert_equal 1, PresentCommand.run!(:full_name => "John", :email => "john@gmail.com")
      assert_equal 2, PresentCommand.run!(:email => "john@gmail.com")
      assert_equal 3, PresentCommand.run!(:full_name => "John")
      assert_equal 4, PresentCommand.run!
    end
  end

  describe "RawInputsCommand" do
    class RawInputsCommand < Mutations::Command

      required do
        string :full_name
      end

      def execute
        return raw_inputs
      end
    end

    it "should return the raw input data" do
      input = { "full_name" => "Hello World", "other" => "Foo Bar Baz" }
      assert_equal input, RawInputsCommand.run!(input)
    end
  end

  describe "Ommit creating convenience functions for reserved variable names" do
    class ReservedVariableNamesCommand < Mutations::Command
      required do
        # Reserved names
        string :execute
        integer :run

        # Free name
        string :email
      end

      def execute
        if !self.respond_to?("execute_present?") and !self.respond_to?("run_present?")
          if self.respond_to?("email_present?")
            if inputs.include?(:execute) and inputs.include?(:run) and inputs.include?(:email)
              return true
            end
          end
        end

        return false
      end
    end

    it "should not generate convenience functions for reserved names" do
      assert_equal true, ReservedVariableNamesCommand.run!(:execute => "execute", :run => 3, :email => "john@gmail.com")
    end
  end

end
