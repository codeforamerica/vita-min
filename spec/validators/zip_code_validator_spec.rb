require "rails_helper"

RSpec.describe ZipCodeValidator do
  subject { described_class.new(attributes: [:zip_code]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  specify do
    assert_invalid(nil)
  end

  specify do
    assert_invalid("109238471908237")
  end

  specify do
    assert_invalid("1092")
  end

  # For the moment we have excluded this spec because we not checking against known zip codes
  xspecify do
    assert_invalid("99999")
  end

  specify do
    assert_valid("10752")
  end

  specify do
    assert_valid("94103")
  end

  def assert_invalid(value)
    subject.validate_each(record, :zip_code, value)
    expect(record.errors[:zip_code]).to be_present
  end

  def assert_valid(value)
    subject.validate_each(record, :zip_code, value)
    expect(record.errors[:zip_code]).to eq []
  end
end
