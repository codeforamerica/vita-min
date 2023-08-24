require "rails_helper"

describe AccountNumberValidator do
  before do
    @validatable = Class.new do
      include ActiveModel::Validations
      validates_with AccountNumberValidator, attributes: :account_number
      attr_accessor  :account_number
    end
  end

  subject { @validatable.new }

  context 'with valid account number' do
    before do
      allow(subject).to receive(:account_number).and_return '123456789'
    end

    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  context "with an account number that is too long" do
    before do
      allow(subject).to receive(:account_number).and_return '12345678000000000000'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:account_number]).to include I18n.t("validators.account_number")
    end
  end

  context "with an account number that has non-digits" do
    before do
      allow(subject).to receive(:account_number).and_return '1334ab56789'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:account_number]).to include I18n.t("validators.account_number")
    end
  end

  context "with an account number that is all digits and 17 characters long" do
    before do
      allow(subject).to receive(:account_number).and_return '12345678901234567'
    end

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "with an account number that is all digits and 5 characters long" do
    before do
      allow(subject).to receive(:account_number).and_return '12345'
    end

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
