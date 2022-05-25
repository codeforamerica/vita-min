require "rails_helper"

RSpec.describe FileTypeAllowedValidator do
  let(:attr_name) { :document }
  subject { described_class.new(attributes: [attr_name]) }

  let!(:record) { OpenStruct.new(errors: ActiveModel::Errors.new(nil)) }
  let(:attachment) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("spec", "fixtures", "files", filename), 'rb'),
      filename: filename,
      content_type: content_type
    )
  end
  before do
    stub_const("OpenStruct::ACCEPTED_FILE_TYPES", [:browser_native_image, :other_image, :document])
  end

  context "png" do
    let(:filename) { "test-pattern.png" }
    let(:content_type) { "image/png" }

    it "is a valid file type" do
      assert_valid(attachment)
    end
  end

  context "all caps extension JPG" do
    let(:filename) { "test-pattern.JPG" }
    let(:content_type) { "image/jpeg" }

    it "is a valid file type after downcase" do
      assert_valid(attachment)
    end
  end

  context "html" do
    let(:filename) { "test-pattern.html" }
    let(:content_type) { "text/html" }

    it "is not a valid file type" do
      assert_invalid(attachment)
    end
  end

  def assert_invalid(value)
    subject.validate_each(record, attr_name, value)
    expect(record.errors[:document]).to include I18n.t("validators.file_type", valid_types: described_class.extensions(record.class).to_sentence)
  end

  def assert_valid(value)
    subject.validate_each(record, attr_name, value)
    expect(record.errors[:document]).to eq []
  end
end
