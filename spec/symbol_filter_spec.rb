require 'spec_helper'

describe "Chickens::SymbolFilter" do

  it "allows strings" do
    sf = Chickens::SymbolFilter.new
    filtered, errors = sf.filter("hello")
    assert_equal :hello, filtered
    assert_equal nil, errors
  end

  it "allows symbols" do
    sf = Chickens::SymbolFilter.new
    filtered, errors = sf.filter(:hello)
    assert_equal :hello, filtered
    assert_equal nil, errors
  end

  it "doesn't allow non-symbols" do
    sf = Chickens::SymbolFilter.new
    [["foo"], {:a => "1"}, Object.new].each do |thing|
      _filtered, errors = sf.filter(thing)
      assert_equal :symbol, errors
    end
  end

  it "considers nil to be invalid" do
    sf = Chickens::SymbolFilter.new(:nils => false)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    sf = Chickens::SymbolFilter.new(:nils => true)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers non-inclusion to be invalid" do
    sf = Chickens::SymbolFilter.new(:in => [:red, :blue, :green])
    filtered, errors = sf.filter(:orange)
    assert_equal :orange, filtered
    assert_equal :in, errors
  end

  it "considers inclusion to be valid" do
    sf = Chickens::SymbolFilter.new(:in => [:red, :blue, :green])
    filtered, errors = sf.filter(:red)
    assert_equal :red, filtered
    assert_equal nil, errors
  end

end
