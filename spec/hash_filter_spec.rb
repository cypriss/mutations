require_relative 'spec_helper'

describe "Mutations::HashFilter" do

  it "allows valid hashes" do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter(foo: "bar")
    assert_equal ({"foo" => "bar"}), filtered
    assert_equal nil, errors
  end
  
  it 'disallows non-hashes' do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter("bar")
    assert_equal :hash, errors
  end
  
  it "allows wildcards in hashes" do
    hf = Mutations::HashFilter.new do
      string :*
    end
    filtered, errors = hf.filter(foo: "bar", baz: "ban")
    assert_equal ({"foo" => "bar", "baz" => "ban"}), filtered
    assert_equal nil, errors
  end
  
  it "doesn't allow wildcards in hashes" do
    hf = Mutations::HashFilter.new do
      string :*
    end
    filtered, errors = hf.filter(foo: nil)
    assert_equal ({"foo" => :nils}), errors.symbolic
  end
  
  it "allows a mix of specific keys and then wildcards" do
    hf = Mutations::HashFilter.new do
      string :foo
      integer :*
    end
    filtered, errors = hf.filter(foo: "bar", baz: "4")
    assert_equal ({"foo" => "bar", "baz" => 4}), filtered
    assert_equal nil, errors
  end
  
end
