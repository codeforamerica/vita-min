require "rails_helper"

describe IrsStreetAddressTypeValidator do
  before do
    @validatable = Class.new do
      def self.name; "Validatable"; end
      include ActiveModel::Validations
      validates_with IrsStreetAddressTypeValidator, attributes: :text
      attr_accessor :text
    end
  end

  subject { @validatable.new }

  before do
    subject.text = text
  end

  context "only allowed characters" do
    let(:text) { "123 Mid-Island St" }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "not allowed characters: pound sign" do
    let(:text) { "123 Mid-Island St #Frnt" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed characters: period" do
    let(:text) { "123 Mid-Island St." }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed to be longer than 35 chars" do
    let(:text) { "123456789012345678901234567890123456"}

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end
end
