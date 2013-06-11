require 'spec_helper'

describe "Mutations - errors" do

  class GivesErrors < Mutations::Command
    required do
      string :str1
      string :str2, :in => %w(opt1 opt2 opt3)
    end

    optional do
      integer :int1
      hash :hash1 do
        boolean :bool1
        boolean :bool2
      end
      array :arr1 do integer end
    end

    def execute
      inputs
    end
  end

  it "returns an ErrorHash as the top level error object, and ErrorAtom's inside" do
    o = GivesErrors.run(:hash1 => 1, :arr1 => "bob")

    assert !o.success?
    assert o.errors.is_a?(Mutations::ErrorHash)
    assert o.errors[:str1].is_a?(Mutations::ErrorAtom)
    assert o.errors[:str2].is_a?(Mutations::ErrorAtom)
    assert_nil o.errors[:int1]
    assert o.errors[:hash1].is_a?(Mutations::ErrorAtom)
    assert o.errors[:arr1].is_a?(Mutations::ErrorAtom)
  end

  it "returns an ErrorHash for nested hashes" do
    o = GivesErrors.run(:hash1 => {:bool1 => "poop"})

    assert !o.success?
    assert o.errors.is_a?(Mutations::ErrorHash)
    assert o.errors[:hash1].is_a?(Mutations::ErrorHash)
    assert o.errors[:hash1][:bool1].is_a?(Mutations::ErrorAtom)
    assert o.errors[:hash1][:bool2].is_a?(Mutations::ErrorAtom)
  end

  it "returns an ErrorArray for errors in arrays" do
    o = GivesErrors.run(:str1 => "a", :str2 => "opt1", :arr1 => ["bob", 1, "sally"])

    assert !o.success?
    assert o.errors.is_a?(Mutations::ErrorHash)
    assert o.errors[:arr1].is_a?(Mutations::ErrorArray)
    assert o.errors[:arr1][0].is_a?(Mutations::ErrorAtom)
    assert_nil o.errors[:arr1][1]
    assert o.errors[:arr1][2].is_a?(Mutations::ErrorAtom)
  end

  it "titleizes keys" do
    atom = Mutations::ErrorAtom.new(:newsletter_subscription, :boolean)
    assert_equal "Newsletter Subscription isn't a boolean", atom.message
  end

  describe "Bunch o errors" do
    before do
      @outcome = GivesErrors.run(:str1 => "", :str2 => "opt9", :int1 => "zero", :hash1 => {:bool1 => "bob"}, :arr1 => ["bob", 1, "sally"])
    end

    it "gives symbolic errors" do
      expected = {"str1"=>:empty,
       "str2"=>:in,
       "int1"=>:integer,
       "hash1"=>{"bool1"=>:boolean, "bool2"=>:required},
       "arr1"=>[:integer, nil, :integer]}

      assert_equal expected, @outcome.errors.symbolic
    end

    it "gives messages" do
      expected = {"str1"=>"Str1 can't be blank", "str2"=>"Str2 isn't an option", "int1"=>"Int1 isn't an integer", "hash1"=>{"bool1"=>"Bool1 isn't a boolean", "bool2"=>"Bool2 is required"}, "arr1"=>["Arr1[0] isn't an integer", nil, "Arr1[2] isn't an integer"]}

      assert_equal expected, @outcome.errors.message
    end

    it "can flatten those messages" do
      expected = ["Str1 can't be blank", "Str2 isn't an option", "Int1 isn't an integer", "Bool1 isn't a boolean", "Bool2 is required", "Arr1[0] isn't an integer", "Arr1[2] isn't an integer"]

      assert_equal expected.size, @outcome.errors.message_list.size
      expected.each { |e| assert @outcome.errors.message_list.include?(e) }
    end
  end

end
