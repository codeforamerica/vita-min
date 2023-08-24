require "rails_helper"

describe IrsCityTypeValidator do
  before do
    @validatable = Class.new do
      include ActiveModel::Validations
      validates_with IrsCityTypeValidator, attributes: :text
      attr_accessor :text
    end
  end

  subject { @validatable.new }

  before do
    subject.text = text
  end

  context "characters allowed" do
    context "only allowed characters" do
      let(:text) { "San Francisco" }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "not allowed characters: any punctuation" do
      let(:text) { "San Francisco," }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end

    context "not allowed characters: any numbers" do
      let(:text) { "San Francisc0" }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end
  end

  context "length" do
    context "when 22 chars or less" do
      let(:text) { "ABCDEFGHI ABCDEFGHI AB" }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when 23 chars or more" do
      let(:text) { "ABCDEFGHI ABCDEFGHI ABC" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end
end
