require_relative 'spec_helper'

describe "Mutations::DateFilter" do

  it "allows dates via Date class" do
    today_date = Date.today
    f = Mutations::DateFilter.new
    filtered, errors = f.filter(today_date)
    assert_equal today_date, filtered
    assert_equal nil, errors
  end

  it "allows dates via DateTime class" do
    today_date = DateTime.now
    f = Mutations::DateFilter.new
    filtered, errors = f.filter(today_date)
    assert_equal today_date, filtered
    assert_equal nil, errors
  end

  it "allow string dates" do
    string_date = "21-10-2013"
    f = Mutations::DateFilter.new
    filtered, errors = f.filter(string_date)
    assert_equal Date.strptime(string_date, "%d-%m-%Y"), filtered
    assert_equal nil, errors
  end

  it "considers wrong formated dates to be invalid" do
    wrong_string_date = "31-31-2013"
    f = Mutations::DateFilter.new
    filtered, errors = f.filter(wrong_string_date)
    assert_equal :date, errors
  end

  it "allow user to add custom format" do
    string_date = "12/10/2013"
    custom_format = "%m/%d/%Y"
    f = Mutations::DateFilter.new(format: custom_format, nils: true)
    filtered, errors = f.filter(string_date)
    assert_equal Date.strptime(string_date, custom_format), filtered
    assert_equal nil, errors
  end

  it "considers non-dates to be invalid" do
    f = Mutations::DateFilter.new
    [[true], {a: "1"}, Object.new, true, [Date.today]].each do |thing|
      filtered, errors = f.filter(thing)
      assert_equal :date, errors
    end
  end

  it "considers nil to be invalid" do
    f = Mutations::DateFilter.new(nils: false)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it "considers nil to be valid" do
    f = Mutations::DateFilter.new(nils: true)
    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end
end

