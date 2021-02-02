require 'spec_helper'
require 'securerandom'

describe 'Mutations::UUIDFilter' do
   it 'parses uuids as as string' do
    f = Mutations::UUIDFilter.new
    uuid = SecureRandom.uuid.to_s
    filtered, errors = f.filter(uuid)

    assert_equal uuid, filtered
    assert_equal nil, errors
  end

  it 'does not treat nils as uuids' do
    f = Mutations::UUIDFilter.new(nils: false)
    filtered, errors = f.filter(nil)

    assert_equal nil, filtered
    assert_equal :nils, errors
  end

  it 'can accept nils' do
    f = Mutations::UUIDFilter.new(nils: true)
    uuid = SecureRandom.uuid
    filtered, errors = f.filter(uuid)
    assert_equal uuid, filtered
    assert_equal nil, errors

    filtered, errors = f.filter(nil)
    assert_equal nil, filtered
    assert_equal nil, errors
  end
end
