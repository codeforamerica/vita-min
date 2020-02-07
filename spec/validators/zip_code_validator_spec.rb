require "rails_helper"

RSpec.describe ZipCodeValidator do
  subject { described_class.new(attributes: [:zip_code]) }

  let!(:record) { OpenStruct.new(errors: { zip_code: [] }) }

  specify do
    assert_invalid(nil)
  end

  specify do
    assert_invalid("109238471908237")
  end

  specify do
    assert_invalid("1092")
  end

  specify do
    assert_invalid("99999")
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