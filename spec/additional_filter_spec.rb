require 'spec_helper'

describe "Mutations::AdditionalFilter" do

  describe "Additional Filter" do
    module Mutations
      class SometestFilter < Mutations::AdditionalFilter
        @default_options = {
          :nils => false
        }

        def filter(data)
          return [data, nil]
        end
      end

      class MultiWordTestFilter < Mutations::AdditionalFilter
        @default_options = {
          :nils => false
        }

        def filter(data)
          return [data, nil]
        end
      end
    end

    class TestCommandUsingAdditionalFilters < Mutations::Command
      required do
        sometest :first_name
        multi_word_test :last_name
      end

      def execute
        { :first_name => first_name, :last_name => last_name }
      end
    end

    it "should recognize additional filters" do
      outcome = TestCommandUsingAdditionalFilters.run(:first_name => "John", :last_name => "Doe")
      assert outcome.success?
      assert_nil outcome.errors
    end

    class TestCommandUsingAdditionalFiltersInHashes < Mutations::Command
      required do
        hash :a_hash do
          sometest :first_name
        end
      end

      def execute
        { :a_hash => a_hash }
      end
    end

    it "should be useable in hashes" do
      outcome = TestCommandUsingAdditionalFiltersInHashes.run(
        :a_hash => { :first_name => "John" }
      )

      assert outcome.success?
      assert_nil outcome.errors
    end

    class TestCommandUsingAdditionalFiltersInArrays < Mutations::Command
      required do
        array :an_array do
          sometest
        end
      end

      def execute
        { :an_array => an_array }
      end
    end

    it "should be useable in arrays" do
      outcome = TestCommandUsingAdditionalFiltersInArrays.run(
        :an_array => [ "John", "Bill" ]
      )

      assert outcome.success?
      assert_nil outcome.errors
    end

    module Mutations
      class AdditionalWithBlockFilter < Mutations::AdditionalFilter

        def initialize(opts={}, &block)
          super(opts)

          if block_given?
            instance_eval(&block)
          end
        end

        def should_be_called
          @was_called = true
        end

        def filter(data)
          if @was_called
            [true, nil]
          else
            [nil, :not_called]
          end
        end
      end
    end

    class TestCommandUsingBlockArgument < Mutations::Command
      required do
        additional_with_block :foo do
          should_be_called
        end
      end

      def execute
        true
      end
    end

    it "can have a block constructor" do
      assert_equal true, TestCommandUsingBlockArgument.run!(:foo => 'bar')
    end

    class TestCommandUsingBlockArgumentInAnArray < Mutations::Command
      required do
        array :some_array do
          additional_with_block do
            should_be_called
          end
        end
      end

      def execute
        true
      end
    end

    it "It can have a block constructor when used in an array" do
      assert_equal true, TestCommandUsingBlockArgumentInAnArray.run!(:some_array => ['bar'])
    end
  end
end
