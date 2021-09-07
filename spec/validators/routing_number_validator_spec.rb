require "rails_helper"
class Validatable
  include ActiveModel::Validations
  validates_with RoutingNumberValidator, attributes: :routing_number
  attr_accessor  :routing_number
end

describe RoutingNumberValidator do
  let(:routing_number) { nil }
  subject { Validatable.new }

  context 'with valid routing number' do
    before do
      allow(subject).to receive(:routing_number).and_return '123456789'
    end

    it 'is valid' do

      expect(subject).to be_valid
    end
  end

  context "with a routing number that is too short" do
    before do
      allow(subject).to receive(:routing_number).and_return '12345678'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:routing_number]).to include I18n.t("validators.routing_number")
    end
  end

  context "with a routing number that does not match the regex" do
    before do
      allow(subject).to receive(:routing_number).and_return '133456789'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:routing_number]).to include I18n.t("validators.routing_number")
    end
  end

  context "with a routing number that is too long not match the regex" do
    before do
      allow(subject).to receive(:routing_number).and_return '1334567890'
    end

    it 'is not valid' do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:routing_number]).to include I18n.t("validators.routing_number")
    end
  end
end