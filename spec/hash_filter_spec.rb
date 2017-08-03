require 'spec_helper'
require 'stringio'

describe "Mutations::HashFilter" do

  it "allows valid hashes" do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    filtered, errors = hf.filter(:foo => "bar")
    assert_equal ({"foo" => "bar"}), filtered
    assert_equal nil, errors
  end

  it 'disallows non-hashes' do
    hf = Mutations::HashFilter.new do
      string :foo
    end
    _filtered, errors = hf.filter("bar")
    assert_equal :hash, errors
  end

  it "allows wildcards in hashes" do
    hf = Mutations::HashFilter.new do
      string :*
    end
    filtered, errors = hf.filter(:foo => "bar", :baz => "ban")
    assert_equal ({"foo" => "bar", "baz" => "ban"}), filtered
    assert_equal nil, errors
  end

  it "allows floats in hashes" do
    hf = Mutations::HashFilter.new do
      float :foo
    end
    filtered, errors = hf.filter(:foo => 3.14)
    assert_equal ({"foo" => 3.14}), filtered
    assert_equal nil, errors
  end

  it "allows ducks in hashes" do
    hf = Mutations::HashFilter.new do
      duck :foo, :methods => [:length]
    end
    filtered, errors = hf.filter(:foo => "123")
    assert_equal ({"foo" => "123"}), filtered
    assert_equal nil, errors
  end

  it "allows dates in hashes" do
    hf = Mutations::HashFilter.new do
      date :foo, :format => "%d-%m-%Y"
    end
    filtered, errors = hf.filter(:foo => "1-1-2000")
    assert_equal Date.new(2000, 1, 1), filtered[:foo]
    assert_equal nil, errors
  end

  it "allows files in hashes" do
    sio = StringIO.new("bob")
    hf = Mutations::HashFilter.new do
      file :foo
    end
    filtered, errors = hf.filter(:foo => sio)
    assert_equal ({"foo" => sio}), filtered
    assert_equal nil, errors
  end

  it "doesn't allow wildcards in hashes" do
    hf = Mutations::HashFilter.new do
      string :*
    end
    _filtered, errors = hf.filter(:foo => [])
    assert_equal ({"foo" => :string}), errors.symbolic
  end

  it "allows a mix of specific keys and then wildcards" do
    hf = Mutations::HashFilter.new do
      string :foo
      integer :*
    end
    filtered, errors = hf.filter(:foo => "bar", :baz => "4")
    assert_equal ({"foo" => "bar", "baz" => 4}), filtered
    assert_equal nil, errors
  end

  it "doesn't allow a mix of specific keys and then wildcards -- should raise errors appropriately" do
    hf = Mutations::HashFilter.new do
      string :foo
      integer :*
    end
    _filtered, errors = hf.filter(:foo => "bar", :baz => "poopin")
    assert_equal ({"baz" => :integer}), errors.symbolic
  end

  describe "optional params and nils" do
    it "bar is optional -- it works if not passed" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar
        end
      end

      filtered, errors = hf.filter(:foo => "bar")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- it works if nil is passed" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => nil)
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- it works if nil is passed and nils are allowed" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, :nils => true
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => nil)
      assert_equal ({"foo" => "bar", "bar" => nil}), filtered
      assert_equal nil, errors
    end
  end

  describe "optional params and empty values" do
    it "bar is optional -- discards empty" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, :discard_empty => true
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => "")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- discards empty if it needs to be stripped" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, :discard_empty => true
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => " ")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- don't discard empty if it's spaces but stripping is off" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, :discard_empty => true, :strip => false
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => " ")
      assert_equal ({"foo" => "bar", "bar" => " "}), filtered
      assert_equal nil, errors
    end

    it "bar is optional -- errors if discard_empty is false and value is blank" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :bar, :discard_empty => false
        end
      end

      _filtered, errors = hf.filter(:foo => "bar", :bar => "")
      assert_equal ({"bar" => :empty}), errors.symbolic
    end

    it "bar is optional -- discards empty -- now with wildcards" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          string :*, :discard_empty => true
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => "", :baz => "\t")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end
  end

  describe "discarding invalid values" do
    it "should discard invalid optional values" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          integer :bar, :discard_invalid => true
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => "baz")
      assert_equal ({"foo" => "bar"}), filtered
      assert_equal nil, errors
    end

    it "should discard invalid optional values for wildcards" do
      hf = Mutations::HashFilter.new do
        required do
          string :foo
        end
        optional do
          integer :*, :discard_invalid => true
        end
      end

      filtered, errors = hf.filter(:foo => "bar", :bar => "baz", :wat => 1)
      assert_equal ({"foo" => "bar", "wat" => 1}), filtered
      assert_equal nil, errors
    end


    it "should not discard invalid require values" do
      hf = Mutations::HashFilter.new do
        required do
          integer :foo, :discard_invalid => true
        end
      end

      _filtered, errors = hf.filter(:foo => "bar")
      assert_equal ({"foo" => :integer}), errors.symbolic
    end
  end

end
