require 'spec_helper'

describe "Mutations::SymbolFilter" do

  it "allows strings" do
    sf = Mutations::SymbolFilter.new
    filtered, errors = sf.filter("hello")
    assert_equal :hello, filtered
    assert_equal nil, errors
  end

  it "allows symbols" do
    sf = Mutations::SymbolFilter.new
    filtered, errors = sf.filter(:hello)
    assert_equal :hello, filtered
    assert_equal nil, errors
  end

  it "doesn't allow non-symbols" do
    sf = Mutations::SymbolFilter.new
    [["foo"], {:a => "1"}, Object.new].each do |thing|
      _filtered, errors = sf.filter(thing)
      assert_equal :symbol, errors
    end
  end

  it "considers nil to be invalid" do
    sf = Mutations::SymbolFilter.new(:nils => false)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    sf = Mutations::SymbolFilter.new(:nils => true)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

end
