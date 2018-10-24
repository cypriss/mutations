require 'spec_helper'

describe Mutations::SymbolFilter do
  let(:options){ {} }
  let(:outcome){ Mutations::SymbolFilter.new(options).filter(input) }
  let(:result){ outcome[0] }
  let(:errors){ outcome[1] }

  describe 'string input' do
    let(:input){ 'foo' }

    it{ assert_equal(result, :foo) }
    it{ assert_nil(errors) }
  end

  describe 'symbol input' do
    let(:input){ :foo }

    it{ assert_equal(result, :foo) }
    it{ assert_nil(errors) }
  end

  describe 'input not a symbol' do
    let(:input){ 1 }

    it{ assert_nil(result) }
    it{ assert_equal(errors, :symbol) }
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
