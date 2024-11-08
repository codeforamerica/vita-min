require "rails_helper"

RSpec.describe ZipCodeValidator do
  subject { described_class.new(attributes: [:zip_code], zip_code_lengths: zip_code_lengths) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  context "with default length of 5 digits" do
    let(:zip_code_lengths) { [5] }
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
      assert_valid("10572")
    end

    specify do
      assert_valid("94103")
    end
  end

  context "with zip code lengths of 5 9 and 12 digits" do
    let(:zip_code_lengths) { [5, 9, 12] }

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
      assert_invalid("999-99")
    end

    specify do
      assert_valid("10572")
    end

    specify do
      assert_valid("941033456")
    end

    specify do
      assert_valid("94103-3456")
    end

    specify do
      assert_valid("94103-3456-123")
    end
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
