require_relative 'spec_helper'

describe "Mutations::ModelFilter" do

  class SimpleModel; end
  class AlwaysNew
    def new_record?
      true
    end
  end

  class AlwaysSaved
    def new_record?
      false
    end
  end


  it "allows models" do
    f = Mutations::ModelFilter.new(:simple_model)
    m = SimpleModel.new
    filtered, errors = f.filter(m)
    assert_equal m, filtered
    assert_equal nil, errors
  end

  # it "disallows different types of models" do
  # end

  it "raises an exception during initialization if constantization fails" do
    assert_raises NameError do
      Mutations::ModelFilter.new(:complex_model)
    end
  end

  it "raises an exception during initialization if constantization of class fails" do
    assert_raises NameError do
      Mutations::ModelFilter.new(:simple_model, class: "ComplexModel")
    end
  end

  it "raises an exception during initialization if constantization of builder fails" do
    assert_raises NameError do
      Mutations::ModelFilter.new(:simple_model, builder: "ComplexModel")
    end
  end

  it "considers nil to be invalid" do
    f = Mutations::ModelFilter.new(:simple_model, nils: false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Mutations::ModelFilter.new(:simple_model, nils: true)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  # it "allows you to override class with a constant and succeed" do
  # end
  #
  # it "allows you to override class with a string and succeed" do
  # end
  #
  # it "allows you to override class and fail" do
  # end
  #
  # it "allows anything if new_record is true" do
  # end
  #
  # it "disallows new_records if new_record is false" do
  # end
  #
  # it "allows saved records if new_record is false" do
  # end
  #
  # it "allows other records if new_record is false" do
  # end
  #
  # it "allows you to build a record from a hash, and succeed" do
  # end
  #
  # it "allows you to build a record from a hash, and fail" do
  # end
  #
  # it "makes sure that if you build a record from a hash, it still has to be of the right class" do
  # end

end