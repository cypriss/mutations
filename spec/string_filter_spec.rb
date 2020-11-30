# encoding: utf-8

require 'spec_helper'

describe "Chickens::StringFilter" do

  it "allows valid strings" do
    sf = Chickens::StringFilter.new
    filtered, errors = sf.filter("hello")
    assert_equal "hello", filtered
    assert_equal nil, errors
  end

  it "allows symbols" do
    sf = Chickens::StringFilter.new
    filtered, errors = sf.filter(:hello)
    assert_equal "hello", filtered
    assert_equal nil, errors
  end

  it "allows numbers" do
    sf = Chickens::StringFilter.new
    filtered, errors = sf.filter(1)
    assert_equal "1", filtered
    assert_equal nil, errors
  end

  it "disallows non-string" do
    sf = Chickens::StringFilter.new
    [["foo"], {:a => "1"}, Object.new].each do |thing|
      _filtered, errors = sf.filter(thing)
      assert_equal :string, errors
    end
  end

  it "strips" do
    sf = Chickens::StringFilter.new(:strip => true)
    filtered, errors = sf.filter(" hello ")
    assert_equal "hello", filtered
    assert_equal nil, errors
  end

  it "doesn't strip" do
    sf = Chickens::StringFilter.new(:strip => false)
    filtered, errors = sf.filter(" hello ")
    assert_equal " hello ", filtered
    assert_equal nil, errors
  end

  it "considers nil to be invalid" do
    sf = Chickens::StringFilter.new(:nils => false)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    sf = Chickens::StringFilter.new(:nils => true)
    filtered, errors = sf.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers empty strings to be nil if empty_is_nil option is used" do
    f = Chickens::StringFilter.new(:empty_is_nil => true)
    _filtered, errors = f.filter("")
    assert_equal :nils, errors
  end

  it "returns empty strings as nil if empty_is_nil option is used" do
    f = Chickens::StringFilter.new(:empty_is_nil => true, :nils => true)
    filtered, errors = f.filter("")
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers empty strings to be invalid" do
    sf = Chickens::StringFilter.new(:empty => false)
    filtered, errors = sf.filter("")
    assert_equal "", filtered
    assert_equal :empty, errors
  end

  it "considers empty strings to be valid" do
    sf = Chickens::StringFilter.new(:empty => true)
    filtered, errors = sf.filter("")
    assert_equal "", filtered
    assert_equal nil, errors
  end

  it "considers stripped strings that are empty to be invalid" do
    sf = Chickens::StringFilter.new(:empty => false)
    filtered, errors = sf.filter("   ")
    assert_equal "", filtered
    assert_equal :empty, errors
  end

  it "considers stripped strings that are blank to be nil if empty_is_nil option is used" do
    sf = Chickens::StringFilter.new(:strip => true, :empty_is_nil => true, :nils => true)
    filtered, errors = sf.filter("   ")
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers stripped strings that are blank to be invalid if empty_is_nil option is used" do
    sf = Chickens::StringFilter.new(:strip => true, :empty_is_nil => true)
    filtered, errors = sf.filter("   ")
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers strings that contain only control characters to be invalid" do
    sf = Chickens::StringFilter.new(:empty => false)
    filtered, errors = sf.filter("\u0000\u0000")
    assert_equal "", filtered
    assert_equal :empty, errors
  end

  it "considers long strings to be invalid" do
    sf = Chickens::StringFilter.new(:max_length => 5)
    filtered, errors = sf.filter("123456")
    assert_equal "123456", filtered
    assert_equal :max_length, errors
  end

  it "considers long strings to be valid" do
    sf = Chickens::StringFilter.new(:max_length => 5)
    filtered, errors = sf.filter("12345")
    assert_equal "12345", filtered
    assert_equal nil, errors
  end

  it "considers short strings to be invalid" do
    sf = Chickens::StringFilter.new(:min_length => 5)
    filtered, errors = sf.filter("1234")
    assert_equal "1234", filtered
    assert_equal :min_length, errors
  end

  it "considers short strings to be valid" do
    sf = Chickens::StringFilter.new(:min_length => 5)
    filtered, errors = sf.filter("12345")
    assert_equal "12345", filtered
    assert_equal nil, errors
  end

  it "considers bad matches to be invalid" do
    sf = Chickens::StringFilter.new(:matches => /aaa/)
    filtered, errors = sf.filter("aab")
    assert_equal "aab", filtered
    assert_equal :matches, errors
  end

  it "considers good matches to be valid" do
    sf = Chickens::StringFilter.new(:matches => /aaa/)
    filtered, errors = sf.filter("baaab")
    assert_equal "baaab", filtered
    assert_equal nil, errors
  end

  it "considers non-inclusion to be invalid" do
    sf = Chickens::StringFilter.new(:in => %w(red blue green))
    filtered, errors = sf.filter("orange")
    assert_equal "orange", filtered
    assert_equal :in, errors
  end

  it "considers inclusion to be valid" do
    sf = Chickens::StringFilter.new(:in => %w(red blue green))
    filtered, errors = sf.filter("red")
    assert_equal "red", filtered
    assert_equal nil, errors
  end

  it "converts symbols to strings" do
    sf = Chickens::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(:my_sym)
    assert_equal "my_sym", filtered
    assert_equal nil, errors
  end

  it "converts integers to strings" do
    sf = Chickens::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(1)
    assert_equal "1", filtered
    assert_equal nil, errors
  end

  it "converts bigdecimals to strings" do
    sf = Chickens::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(BigDecimal("0.0001"))
    assert_equal("0.1E-3", filtered.upcase)
    assert_equal nil, errors
  end

  it "converts floats to strings" do
    sf = Chickens::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(0.0001)
    assert_equal "0.0001", filtered
    assert_equal nil, errors
  end

  it "converts booleans to strings" do
    sf = Chickens::StringFilter.new(:strict => false)
    filtered, errors = sf.filter(true)
    assert_equal "true", filtered
    assert_equal nil, errors
  end

  it "disallows symbols" do
    sf = Chickens::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(:my_sym)
    assert_equal :my_sym, filtered
    assert_equal :string, errors
  end

  it "disallows integers" do
    sf = Chickens::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(1)
    assert_equal 1, filtered
    assert_equal :string, errors
  end

  it "disallows bigdecimals" do
    sf = Chickens::StringFilter.new(:strict => true)
    big_decimal = BigDecimal("0.0001")
    filtered, errors = sf.filter(big_decimal)
    assert_equal big_decimal, filtered
    assert_equal :string, errors
  end

  it "disallows floats" do
    sf = Chickens::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(0.0001)
    assert_equal 0.0001, filtered
    assert_equal :string, errors
  end

  it "disallows booleans" do
    sf = Chickens::StringFilter.new(:strict => true)
    filtered, errors = sf.filter(true)
    assert_equal true, filtered
    assert_equal :string, errors
  end

  it "removes control characters" do
    sf = Chickens::StringFilter.new(:allow_control_characters => false)
    filtered, errors = sf.filter("Hello\u0000\u0000World!")
    assert_equal "Hello World!", filtered
    assert_equal nil, errors
  end

  it "doesn't remove control characters" do
    sf = Chickens::StringFilter.new(:allow_control_characters => true)
    filtered, errors = sf.filter("Hello\u0000\u0000World!")
    assert_equal "Hello\u0000\u0000World!", filtered
    assert_equal nil, errors
  end

  it "doesn't remove tabs, spaces and line breaks" do
    sf = Chickens::StringFilter.new(:allow_control_characters => false)
    filtered, errors = sf.filter("Hello,\tWorld !\r\nNew Line")
    assert_equal "Hello,\tWorld !\r\nNew Line", filtered
    assert_equal nil, errors
  end

  it "doesn't remove emoji" do
    sf = Chickens::StringFilter.new(:allow_control_characters => false)
    filtered, errors = sf.filter("😂🙂🙃🤣🤩🥰🥱")
    assert_equal "😂🙂🙃🤣🤩🥰🥱", filtered
    assert_equal nil, errors
  end

end
