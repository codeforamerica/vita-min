require "rails_helper"

RSpec.describe LegalNameValidator do
  subject { described_class.new(attributes: [:primary_first_name]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  specify do
    assert_invalid("Rainbows🌈")
  end

  specify do
    assert_invalid("!!@#$%")
  end

  specify do
    assert_valid("Josè")
  end

  specify do
    assert_valid("Jose")
  end

  def assert_invalid(value)
    subject.validate_each(record, :primary_first_name, value)
    expect(record.errors[:primary_first_name]).to be_present
  end

  def assert_valid(value)
    subject.validate_each(record, :primary_first_name, value)
    expect(record.errors[:primary_first_name]).to eq []
  end
end
