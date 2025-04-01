# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StateFile::Questions::AzExtensionPaymentsController do
  let(:intake) { create :state_file_az_intake }

  describe ".show?" do
    context "when extension period is enabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(true)
      end

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when extension period is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(false)
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end

