require "rails_helper"

describe AlphanumericValidator do
  before do
    @validatable = Class.new do
      include ActiveModel::Validations
      validates_with AlphanumericValidator, attributes: :number
      attr_accessor  :number
    end
  end

  subject { @validatable.new }

  context "not allowed characters: supertext" do
    before do
      allow(subject).to receive(:number).and_return "101619702¹1"
    end

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed characters: dashes" do
    before do
      allow(subject).to receive(:number).and_return "101-619702-1"
    end

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "only allowed characters" do
    before do
      allow(subject).to receive(:number).and_return "WADLFKadjj94856"
    end

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
