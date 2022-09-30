require "rails_helper"

describe IrsTextTypeValidator do
  before do
    @validatable = Class.new do
      include ActiveModel::Validations
      validates_with IrsTextTypeValidator, attributes: :text
      attr_accessor  :text
    end
  end

  subject { @validatable.new }

  context "not allowed characters: supertext" do
    before do
      allow(subject).to receive(:text).and_return "101619702¹1"
    end

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed characters: emoji" do
    before do
      allow(subject).to receive(:text).and_return "🙋"
    end

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "only allowed characters" do
    before do
      allow(subject).to receive(:text).and_return "One pinata"
    end

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
