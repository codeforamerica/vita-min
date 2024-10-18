require "rails_helper"

RSpec.describe SignaturePinValidator do
  subject { described_class.new(attributes: [:signature_pin]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  specify do
    assert_invalid("000000")
  end

  specify do
    assert_invalid("1234567")
  end

  specify do
    assert_invalid("1234")
  end

  specify do
    assert_invalid("!@#$%")
  end

  specify do
    assert_valid("55555")
  end

  specify do
    assert_valid("12345")
  end

  def assert_invalid(value)
    subject.validate_each(record, :signature_pin, value)
    expect(record.errors[:signature_pin]).to be_present
  end

  def assert_valid(value)
    subject.validate_each(record, :signature_pin, value)
    expect(record.errors[:signature_pin]).to eq []
  end
end
