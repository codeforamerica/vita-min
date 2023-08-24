require "rails_helper"

RSpec.describe IpPinValidator do
  subject { described_class.new(attributes: [:ip_pin]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  specify do
    assert_invalid("000000")
  end

  specify do
    assert_invalid("1234567")
  end


  specify do
    assert_invalid("!!@#$%")
  end

  specify do
    assert_valid("555555")
  end

  specify do
    assert_valid("123456")
  end

  def assert_invalid(value)
    subject.validate_each(record, :ip_pin, value)
    expect(record.errors[:ip_pin]).to be_present
  end

  def assert_valid(value)
    subject.validate_each(record, :ip_pin, value)
    expect(record.errors[:ip_pin]).to eq []
  end
end
