require_relative 'spec_helper'

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
    filtered.should == "1"
    assert_equal nil, errors
  end
  
  it "disallows non-string" do
    sf = Mutations::StringFilter.new
    [["foo"], {a: "1"}, Object.new].each do |thing|
      filtered, errors = sf.filter(thing)
      errors.should == :string
    end
  end
  
  it "strips" do
    sf = Mutations::StringFilter.new(strip: true)
    filtered, errors = sf.filter(" hello ")
    filtered.should == "hello"
    assert_equal nil, errors
  end
  
  it "doesn't strip" do
    sf = Mutations::StringFilter.new(strip: false)
    filtered, errors = sf.filter(" hello ")
    filtered.should == " hello "
    assert_equal nil, errors
  end
  
  it "considers nil to be invalid" do
    sf = Mutations::StringFilter.new(nils: false)
    filtered, errors = sf.filter(nil)
    filtered.should be_nil
    errors.should == :nils
  end
  
  it "considers nil to be valid" do
    sf = Mutations::StringFilter.new(nils: true)
    filtered, errors = sf.filter(nil)
    filtered.should be_nil
    assert_equal nil, errors
  end
  
  it "considers empty strings to be invalid" do
    sf = Mutations::StringFilter.new(empty: false)
    filtered, errors = sf.filter("")
    filtered.should == ""
    errors.should == :empty
  end
  
  it "considers empty strings to be valid" do
    sf = Mutations::StringFilter.new(empty: true)
    filtered, errors = sf.filter("")
    filtered.should == ""
    assert_equal nil, errors
  end
  
  it "considers stripped strings that are empty to be invalid" do
    sf = Mutations::StringFilter.new(empty: false)
    filtered, errors = sf.filter("   ")
    filtered.should == ""
    errors.should == :empty
  end
  
  it "considers lengthy strings to be invalid" do
    sf = Mutations::StringFilter.new(length: 5)
    filtered, errors = sf.filter("123456")
    filtered.should ==  "123456"
    errors.should == :length
  end
  
  it "considers unlengthy to be valid" do
    sf = Mutations::StringFilter.new(length: 5)
    filtered, errors = sf.filter("12345")
    filtered.should == "12345"
    assert_equal nil, errors
  end
  
  it "considers bad matches to be invalid" do
    sf = Mutations::StringFilter.new(matches: /aaa/)
    filtered, errors = sf.filter("aab")
    filtered.should == "aab"
    errors.should == :matches
  end
  
  it "considers good matches to be valid" do
    sf = Mutations::StringFilter.new(matches: /aaa/)
    filtered, errors = sf.filter("baaab")
    filtered.should == "baaab"
    assert_equal nil, errors
  end
  
  it "considers non-inclusion to be invalid" do
    sf = Mutations::StringFilter.new(in: %w(red blue green))
    filtered, errors = sf.filter("orange")
    filtered.should == "orange"
    errors.should == :in
  end
  
  it "considers inclusion to be valid" do
    sf = Mutations::StringFilter.new(in: %w(red blue green))
    filtered, errors = sf.filter("red")
    filtered.should == "red"
    assert_equal nil, errors
  end
end
