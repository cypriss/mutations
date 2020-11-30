require 'spec_helper'

describe "Chickens::DateFilter" do
  it "takes a date object" do
    date = Date.new
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(date)
    assert_equal date, filtered
    assert_equal nil, errors
  end
  
  it "takes a DateTime object" do
    date = DateTime.new
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(date)
    assert_equal date, filtered
    assert_equal nil, errors
  end
  
  it "takes a Time object and converts it to a date" do
    time = Time.now
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(time)
    assert_equal time.to_date, filtered
    assert_equal nil, errors
  end

  it "checks if the given date is after a certain date" do
    date = Date.new(2005, 1, 1)
    after_date = Date.new(2000, 1, 1)
    f = Chickens::DateFilter.new(:after => after_date)
    filtered, errors = f.filter(date)

    assert_equal date, filtered
    assert_equal nil, errors
  end

  it "gives errors when the given date is before the after date" do
    date = Date.new(1995, 1, 1)
    after_date = Date.new(2000, 1, 1)
    f = Chickens::DateFilter.new(:after => after_date)
    filtered, errors = f.filter(date)

    assert_equal nil, filtered
    assert_equal :after, errors
  end

  it "checks if the given date is before a certain date" do
    date = Date.new(1995, 1, 1)
    after_date = Date.new(2000, 1, 1)
    f = Chickens::DateFilter.new(:before => after_date)
    filtered, errors = f.filter(date)

    assert_equal date, filtered
    assert_equal nil, errors
  end

  it "gives errors when the given date is after the before date" do
    date = Date.new(2005, 1, 1)
    before_date = Date.new(2000, 1, 1)
    f = Chickens::DateFilter.new(:before => before_date)
    filtered, errors = f.filter(date)

    assert_equal nil, filtered
    assert_equal :before, errors
  end

  it "checks if the given date is in the given range" do
    date = Date.new(2005, 1, 1)
    after_date = Date.new(2000, 1, 1)
    before_date = Date.new(2010, 1, 1)
    f = Chickens::DateFilter.new(:after => after_date, :before => before_date)
    filtered, errors = f.filter(date)

    assert_equal date, filtered
    assert_equal nil, errors
  end

  it "should be able to parse a D-M-Y string to a date" do
    date_string = "2-1-2000"
    date = Date.new(2000, 1, 2)
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(date_string)

    assert_equal date, filtered
    assert_equal nil, errors
  end

  it "should be able to parse a Y-M-D string to a date" do
    date_string = "2000-1-2"
    date = Date.new(2000, 1, 2)
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(date_string)

    assert_equal date, filtered
    assert_equal nil, errors
  end

  it "should be able to handle date formatting" do
    date_string = "2000-1-2"
    date = Date.new(2000, 1, 2)
    f = Chickens::DateFilter.new(:format => '%Y-%m-%d')
    filtered, errors = f.filter(date_string)

    assert_equal date, filtered
    assert_equal nil, errors

    date_string = "1, 2, 2000"
    f = Chickens::DateFilter.new(:format => '%m, %d, %Y')
    filtered, errors = f.filter(date_string)

    assert_equal date, filtered
    assert_equal nil, errors
  end

  it "considers nil to be invalid" do
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(nil)

    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers empty strings to be empty" do
    f = Chickens::DateFilter.new
    filtered, errors = f.filter("")
    assert_equal "", filtered
    assert_equal :empty, errors
  end

  it "allows the use of nil when specified" do
    f = Chickens::DateFilter.new(:nils => true)
    filtered, errors = f.filter(nil)

    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "considers empty strings to be nil if empty_is_nil option is used" do
    f = Chickens::DateFilter.new(:empty_is_nil => true)
    _filtered, errors = f.filter("")
    assert_equal :nils, errors
  end

  it "returns empty strings as nil if empty_is_nil option is used" do
    f = Chickens::DateFilter.new(:empty_is_nil => true, :nils => true)
    filtered, errors = f.filter("")
    assert_equal nil, filtered
    assert_equal nil, errors
  end

  it "doesn't allow non-existing dates" do
    date_string = "1, 20, 2013"
    f = Chickens::DateFilter.new
    filtered, errors = f.filter(date_string)

    assert_equal nil, filtered
    assert_equal :date, errors
  end
end
