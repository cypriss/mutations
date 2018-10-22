require 'spec_helper'

describe Mutations::UriFilter do
  let(:options){ {} }
  let(:outcome){ Mutations::UriFilter.new(options).filter(input) }
  let(:result){ outcome[0] }
  let(:errors){ outcome[1] }

  describe "#blank" do
    subject{ Mutations::UriFilter.new.send(:blank?, value) }

    describe "nil" do
      let(:value){ nil }
      it{ assert(subject) }
    end

    describe "empty string" do
      let(:value){ "" }
      it{ assert(subject) }
    end

    describe "whitespace" do
      let(:value){ " " }
      it{ assert(subject) }
    end

    describe "some text" do
      let(:value){ "abc" }
      it{ assert(!subject) }
    end
  end

  describe 'invalid type input' do
    let(:input){ true }

    it{ assert_nil(result) }
    it{ assert_equal(errors, :invalid) }
  end

  describe 'string input' do
    let(:input){ 'http://www.altavista.com' }

    describe 'is blank' do
      let(:input){ '' }

      it{ assert_nil(result) }
      it{ assert_equal(errors, :blank) }
    end

    describe 'invalid uri' do
      let(:input){ 'oops' }

      it "returns the error" do
        URI.stub :parse, lambda {|x| raise 'invalid URI'} do
          assert_nil(result)
          assert_equal(errors, 'invalid URI')
        end
      end
    end

    describe 'with scheme constraint' do

      describe 'matching constraint' do
        let(:options){ { scheme: :http } }

        it{ assert_equal(result, URI.parse(input)) }
        it{ assert_nil(errors) }
      end

      describe 'not matching constraint' do
        let(:options){ { scheme: :https} }

        it{ assert_nil(result) }
        it{ assert_equal(errors, :scheme) }
      end

      describe 'and blank url scheme' do
        let(:options){ { scheme: :http} }
        let(:input){ 'altavista.com' }

        it{ assert_nil(result) }
        it{ assert_equal(errors, :scheme) }
      end
    end

    describe 'without scheme constraint' do
      describe 'and blank url scheme' do
        let(:input){ 'altavista.com' }

        it{ assert_equal(result, URI.parse(input)) }
        it{ assert_nil(errors) }
      end
    end

  end

  describe 'uri input' do
    let(:input){ URI.parse('http://www.altavista.com') }

    describe 'with scheme constraint' do
      describe 'matching constraint' do
        let(:options){ { scheme: :http } }

        it{ assert_equal(result, input) }
        it{ assert_nil(errors) }
      end

      describe 'not matching constraint' do
        let(:options){ { scheme: :https} }

        it{ assert_nil(result) }
        it{ assert_equal(errors, :scheme) }
      end

      describe 'and blank url scheme' do
        let(:options){ { scheme: :http} }
        let(:input){ URI.parse('altavista.com') }

        it{ assert_nil(result) }
        it{ assert_equal(errors, :scheme) }
      end
    end

    describe 'without scheme constraint' do
      describe 'and blank url scheme' do
        let(:input){ URI.parse('altavista.com') }

        it{ assert_equal(result, input) }
        it{ assert_nil(errors) }
      end
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
