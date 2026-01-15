require 'spec_helper'

describe "Mutations::SymbolFilter" do

  it "allows strings" do
    sf = Mutations::SymbolFilter.new
    filtered, errors = sf.filter("hello")
    assert_equal :hello, filtered
    assert_nil errors
  end

  it "allows symbols" do
    sf = Mutations::SymbolFilter.new
    filtered, errors = sf.filter(:hello)
    assert_equal :hello, filtered
    assert_nil errors
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
    assert_nil filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    sf = Mutations::SymbolFilter.new(:nils => true)
    filtered, errors = sf.filter(nil)
    assert_nil filtered
    assert_nil errors
  end

  it "considers non-inclusion to be invalid" do
    sf = Mutations::SymbolFilter.new(:in => [:red, :blue, :green])
    filtered, errors = sf.filter(:orange)
    assert_equal :orange, filtered
    assert_equal :in, errors
  end

  it "considers inclusion to be valid" do
    sf = Mutations::SymbolFilter.new(:in => [:red, :blue, :green])
    filtered, errors = sf.filter(:red)
    assert_equal :red, filtered
    assert_nil errors
  end

end
