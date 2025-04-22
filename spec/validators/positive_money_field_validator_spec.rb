require "rails_helper"

describe PositiveMoneyFieldValidator do
  before do
    @validatable = Class.new do
      include ActiveModel::Validations
      validates_with PositiveMoneyFieldValidator, attributes: :extension_payments_amount
      attr_accessor  :extension_payments_amount

      def payment_msg
        "class specific error message"
      end
    end
  end

  let(:extension_payments_amount) { nil }

  subject { @validatable.new }

  context 'is a positive decimal' do
    before do
      allow(subject).to receive(:extension_payments_amount).and_return '1.2'
    end

    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  context 'value is 0.2' do
    before do
      allow(subject).to receive(:extension_payments_amount).and_return '0.2'
    end

    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  context 'with non-numeric value' do
    before do
      allow(subject).to receive(:extension_payments_amount).and_return 'non-numeric value'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:extension_payments_amount]).to include I18n.t("validators.not_a_number")
    end
  end

  context 'value is blank' do
    before do
      allow(subject).to receive(:extension_payments_amount).and_return ''
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:extension_payments_amount]).to include "class specific error message"
    end
  end

  context 'value is less than zero' do
    before do
      allow(subject).to receive(:extension_payments_amount).and_return '-1.1'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:extension_payments_amount]).to include "class specific error message"
    end
  end

  context 'value is 0' do
    before do
      allow(subject).to receive(:extension_payments_amount).and_return '0'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:extension_payments_amount]).to include "class specific error message"
    end
  end
end
