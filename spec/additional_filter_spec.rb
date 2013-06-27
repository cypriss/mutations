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
    end

    class TestCommandUsingAdditionalFilters < Mutations::Command
      required do
        sometest :first_name
      end

      def execute
        { :first_name => first_name }
      end
    end

    it "should recognize additional filters" do
      outcome = TestCommandUsingAdditionalFilters.run(:first_name => "John")
      assert outcome.success?
      assert_equal nil, outcome.errors
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
      assert_equal nil, outcome.errors
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
      assert_equal nil, outcome.errors
    end
  end
end
