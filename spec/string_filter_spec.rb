require 'spec_helper'

describe "Mutations::StringFilter" do

  it "allows valid strings" do
    sf = Mutations::StringFilter.new
    filtered, errors = sf.filter("hello")
    assert_equal "hello", filtered
    assert_equal nil, errors
  end

  it "allows symbols" do
    sf = Mutations::StringFilter.new
    filtered, errors = sf.filter(:hello)
    assert_equal "hello", filtered
    assert_equal nil, errors
  end

  it "allows fixnums" do
    sf = Mutations::StringFilter.new
    filtered, errors = sf.filter(1)
    assert_equal "1", filtered
    assert_equal nil, errors
  end

  it "disallows non-string" do
    sf = Mutations::StringFilter.new
    [["foo"], {:a => "1"}, Object.new].each do |thing|
      filtered, errors = sf.filter(thing)
      assert_equal :string, errors
    end
  end

  it "strips" do
    sf = Mutations::StringFilter.new(:strip => true)
    filtered, errors = sf.filter(" hello ")
    assert_equal "hello", filtered
    assert_equal nil, errors
  end

  it "doesn't strip" do
    sf = Mutations::StringFilter.new(:strip => false)
    filtered, errors = sf.filter(" hello ")
    assert_equal " hello ", filtered
    assert_equal nil, errors
  end

  it "considers nil to be invalid" do
    sf = Mutations::StringFilter.new(:nils => false)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    sf = Mutations::StringFilter.new(:nils => true)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers empty strings to be invalid" do
    sf = Mutations::StringFilter.new(:empty => false)
    filtered, errors = sf.filter("")
    assert_equal "", filtered
    assert_equal :empty, errors
  end

  it "considers empty strings to be valid" do
    sf = Mutations::StringFilter.new(:empty => true)
    filtered, errors = sf.filter("")
    assert_equal "", filtered
    assert_equal nil, errors
  end

  it "considers stripped strings that are empty to be invalid" do
    sf = Mutations::StringFilter.new(:empty => false)
    filtered, errors = sf.filter("   ")
    assert_equal "", filtered
    assert_equal :empty, errors
  end

  it "considers long strings to be invalid" do
    sf = Mutations::StringFilter.new(:max_length => 5)
    filtered, errors = sf.filter("123456")
    assert_equal "123456", filtered
    assert_equal :max_length, errors
  end

  it "considers long strings to be valid" do
    sf = Mutations::StringFilter.new(:max_length => 5)
    filtered, errors = sf.filter("12345")
    assert_equal "12345", filtered
    assert_equal nil, errors
  end

  it "considers short strings to be invalid" do
    sf = Mutations::StringFilter.new(:min_length => 5)
    filtered, errors = sf.filter("1234")
    assert_equal "1234", filtered
    assert_equal :min_length, errors
  end

  it "considers short strings to be valid" do
    sf = Mutations::StringFilter.new(:min_length => 5)
    filtered, errors = sf.filter("12345")
    assert_equal "12345", filtered
    assert_equal nil, errors
  end

  it "considers bad matches to be invalid" do
    sf = Mutations::StringFilter.new(:matches => /aaa/)
    filtered, errors = sf.filter("aab")
    assert_equal "aab", filtered
    assert_equal :matches, errors
  end

  it "considers good matches to be valid" do
    sf = Mutations::StringFilter.new(:matches => /aaa/)
    filtered, errors = sf.filter("baaab")
    assert_equal "baaab", filtered
    assert_equal nil, errors
  end

  it "considers non-inclusion to be invalid" do
    sf = Mutations::StringFilter.new(:in => %w(red blue green))
    filtered, errors = sf.filter("orange")
    assert_equal "orange", filtered
    assert_equal :in, errors
  end

  it "considers inclusion to be valid" do
    sf = Mutations::StringFilter.new(:in => %w(red blue green))
    filtered, errors = sf.filter("red")
    assert_equal "red", filtered
    assert_equal nil, errors
  end

  it "converts symbols to strings" do
    sf = Mutations::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(:my_sym)
    assert_equal "my_sym", filtered
    assert_equal nil, errors
  end

  it "converts integers to strings" do
    sf = Mutations::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(1)
    assert_equal "1", filtered
    assert_equal nil, errors
  end

  it "converts booleans to strings" do
    sf = Mutations::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(true)
    assert_equal "true", filtered
    assert_equal nil, errors
  end

  it "disallows symbols" do
    sf = Mutations::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(:my_sym)
    assert_equal :my_sym, filtered
    assert_equal :string, errors
  end

  it "disallows integers" do
    sf = Mutations::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(1)
    assert_equal 1, filtered
    assert_equal :string, errors
  end

  it "disallows booleans" do
    sf = Mutations::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(true)
    assert_equal true, filtered
    assert_equal :string, errors
  end
end
