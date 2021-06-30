require "rails_helper"

RSpec.describe FileTypeAllowedValidator do
  subject { described_class.new(attributes: [:document]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  context "png" do
    let(:valid_document) { fixture_file_upload("test-pattern.png") }

    it "is a valid file type" do
      assert_valid(valid_document)
    end
  end

  context "all caps extension JPG" do
    let(:valid_document) { fixture_file_upload("test-pattern.JPG") }

    it "is a valid file type after downcase" do
      assert_valid(valid_document)
    end
  end

  context "html" do
    let(:invalid_document) { fixture_file_upload("test-pattern.html") }

    it "is not a valid file type" do
      assert_invalid(invalid_document)
    end
  end

  def assert_invalid(value)
    subject.validate_each(record, :document, value)
    expect(record.errors[:document]).to include I18n.t("validators.file_type")
  end

  def assert_valid(value)
    subject.validate_each(record, :document, value)
    expect(record.errors[:document]).to eq []
  end
end
