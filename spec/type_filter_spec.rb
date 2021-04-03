require 'spec_helper'

describe Mutations::TypeFilter do
  let(:options){ {} }
  let(:outcome){ Mutations::TypeFilter.new(options).filter(input) }
  let(:result){ outcome[0] }
  let(:errors){ outcome[1] }

  describe 'klass input' do
    class Foo
    end

    let(:options){ { klass: Foo } }

    describe 'exactly klass' do
      let(:input){ Foo.new }

      it{ assert_equal(result, input) }
      it{ assert_nil(errors) }
    end

    describe 'subclass of klass' do
      let(:input){ Class.new(Foo).new }

      it{ assert_equal(result, input) }
      it{ assert_nil(errors) }
    end

    describe 'not a Class' do
      let(:options){ { klass: 123 } }
      let(:input){ Foo.new }

      it{ assert_nil(result) }
      it{ assert_equal(errors, :klass) }
    end

    describe 'not a klass' do
      let(:input){ Class.new }

      it{ assert_nil(result) }
      it{ assert_equal(errors, :invalid) }
    end

  end

  describe 'nil input' do
    let(:input){ nil }

    describe 'nils allowed' do
      let(:options){ { nils: true } }

      it{ assert_nil(result) }
      it{ assert_nil(errors) }
    end

    describe 'nils not allowed' do
      let(:options){ { nils: false } }

      it{ assert_nil(result) }
      it{ assert_equal(errors, :nils) }
    end
  end

end
