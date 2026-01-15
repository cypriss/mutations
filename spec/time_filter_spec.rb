require 'spec_helper'

describe "Mutations::TimeFilter" do

  it "takes a Time object" do
    time = Time.now
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(time)
    assert_equal time, filtered
    assert_nil errors
  end

  it "takes a Date object and converts it to a time" do
    date = Date.new
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(date)
    assert_equal date.to_time, filtered
    assert_nil errors
  end

  it "takes a DateTime object and converts it to a time" do
    date = DateTime.new
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(date)
    assert_equal date.to_time, filtered
    assert_nil errors
  end

  it "checks if the given time is after a certain time" do
    time = Time.now
    f = Mutations::TimeFilter.new(:after => time - 1)
    filtered, errors = f.filter(time)
    assert_equal time, filtered
    assert_nil errors
  end

  it "gives errors when the given time is before the after time" do
    time = Time.now
    f = Mutations::TimeFilter.new(:after => time + 1)
    filtered, errors = f.filter(time)
    assert_nil filtered
    assert_equal :after, errors
  end

  it "checks if the given time is before a certain time" do
    time = Time.now
    f = Mutations::TimeFilter.new(:before => time + 1)
    filtered, errors = f.filter(time)
    assert_equal time, filtered
    assert_nil errors
  end

  it "gives errors when the given time is after the before time" do
    time = Time.now
    f = Mutations::TimeFilter.new(:before => time - 1)
    filtered, errors = f.filter(time)
    assert_nil filtered
    assert_equal :before, errors
  end

  it "checks if the given time is in the given range" do
    time = Time.now
    f = Mutations::TimeFilter.new(:after => time - 1, :before => time + 1)
    filtered, errors = f.filter(time)
    assert_equal time, filtered
    assert_nil errors
  end

  it "should be able to parse a D-M-Y string to a time" do
    date_string = "2-1-2000"
    date = Date.new(2000, 1, 2)
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(date_string)
    assert_equal date.to_time, filtered
    assert_nil errors
  end

  it "should be able to parse a Y-M-D string to a time" do
    date_string = "2000-1-2"
    date = Date.new(2000, 1, 2)
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(date_string)
    assert_equal date.to_time, filtered
    assert_nil errors
  end

  it "should be able to handle time formatting" do
    time_string = "2000-1-2 12:13:14"
    time = Time.new(2000, 1, 2, 12, 13, 14)
    f = Mutations::TimeFilter.new(:format => '%Y-%m-%d %H:%M:%S')
    filtered, errors = f.filter(time_string)
    assert_equal time, filtered
    assert_nil errors

    time_string = "1, 2, 2000, 121314"
    f = Mutations::TimeFilter.new(:format => '%m, %d, %Y, %H%M%S')
    filtered, errors = f.filter(time_string)
    assert_equal time, filtered
    assert_nil errors
  end

  it "considers nil to be invalid" do
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(nil)
    assert_nil filtered
    assert_equal :nils, errors
  end

  it "allows the use of nil when specified" do
    f = Mutations::TimeFilter.new(:nils => true)
    filtered, errors = f.filter(nil)
    assert_nil filtered
    assert_nil errors
  end

  it "considers empty strings to be empty" do
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter('')
    assert_equal '', filtered
    assert_equal :empty, errors
  end

  it "doesn't allow non-existing times" do
    invalid_time_string = "1, 20, 2013 25:13"
    f = Mutations::TimeFilter.new
    filtered, errors = f.filter(invalid_time_string)
    assert_nil filtered
    assert_equal :time, errors
  end
end
