require "rails_helper"

describe IrsBusinessNameTypeValidator do
  before do
    @validatable = Class.new do
      def self.name; "Validatable"; end
      include ActiveModel::Validations
      validates_with IrsBusinessNameTypeValidator, attributes: :text
      attr_accessor :text
    end
  end

  subject { @validatable.new }

  before do
    subject.text = text
  end

  context "only allowed characters" do
    let(:text) { "Business-Name #1 (Guy & Sons)" }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "not allowed characters: leading space" do
    let(:text) { " Space Cadets" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed characters: trailing space" do
    let(:text) { "Space Cadets " }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed characters: adjacent spaces" do
    let(:text) { "Space  Cadets" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed characters: other symbols" do
    let(:text) { "Sp@ce C@dets" }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end

  context "not allowed to be longer than 75 chars" do
    let(:text) { "A" * 76 }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end
end
