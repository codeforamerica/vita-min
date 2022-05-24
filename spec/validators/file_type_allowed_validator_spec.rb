require "rails_helper"

RSpec.describe FileTypeAllowedValidator do
  subject { described_class.new(attributes: [:document]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }

  before do
    stub_const("OpenStruct::ACCEPTED_FILE_TYPES", [:browser_native_image, :other_image, :document])
  end

  context "png" do
    let(:valid_document) { build :document, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pattern.png") }

    it "is a valid file type" do
      assert_valid(valid_document.upload)
    end
  end

  context "all caps extension JPG" do
    let(:valid_document) { build :document, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pattern.JPG") }

    it "is a valid file type after downcase" do
      assert_valid(valid_document.upload)
    end
  end

  context "html" do
    let(:invalid_document) { build :document, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pattern.html") }

    it "is not a valid file type" do
      assert_invalid(invalid_document.upload)
    end
  end

  def assert_invalid(value)
    subject.validate_each(record, :document, value)
    expect(record.errors[:document]).to include I18n.t("validators.file_type", valid_types: described_class.extensions(record.class).to_sentence)
  end

  def assert_valid(value)
    subject.validate_each(record, :document, value)
    expect(record.errors[:document]).to eq []
  end
end
