require_relative 'spec_helper'

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
    o = GivesErrors.run(hash1: 1, arr1: "bob")
    
    assert !o.success?
    assert o.errors.is_a?(Mutations::ErrorHash)
    assert o.errors[:str1].is_a?(Mutations::ErrorAtom)
    assert o.errors[:str2].is_a?(Mutations::ErrorAtom)
    assert_nil o.errors[:int1]
    assert o.errors[:hash1].is_a?(Mutations::ErrorAtom)
    assert o.errors[:arr1].is_a?(Mutations::ErrorAtom)
  end
  
  it "returns an ErrorHash for nested hashes" do
    o = GivesErrors.run(hash1: {bool1: "poop"})
    
    assert !o.success?
    assert o.errors.is_a?(Mutations::ErrorHash)
    assert o.errors[:hash1].is_a?(Mutations::ErrorHash)
    assert o.errors[:hash1][:bool1].is_a?(Mutations::ErrorAtom)
    assert o.errors[:hash1][:bool2].is_a?(Mutations::ErrorAtom)
  end
  
  it "returns an ErrorArray for errors in arrays" do
    o = GivesErrors.run(str1: "a", str2: "opt1", arr1: ["bob", 1, "sally"])
    
    assert !o.success?
    assert o.errors.is_a?(Mutations::ErrorHash)
    assert o.errors[:arr1].is_a?(Mutations::ErrorArray)
    assert o.errors[:arr1][0].is_a?(Mutations::ErrorAtom)
    assert_nil o.errors[:arr1][1]
    assert o.errors[:arr1][2].is_a?(Mutations::ErrorAtom)
  end
  
  # it "gives symbolic errors" do
  #   
  # end
end