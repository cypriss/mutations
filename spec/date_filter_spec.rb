require_relative 'spec_helper'

describe "Mutations::DateFilter" do

  it "allows dates" do
    today_date = Date.today

    f = Mutations::DateFilter.new
    filtered, errors = f.filter(today_date)
    assert_equal today_date, filtered
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

