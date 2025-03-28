# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StateFile::Questions::AzExtensionPaymentsController do
  let(:intake) { create :state_file_az_intake }

  describe ".show?" do

    context "when extension period is enabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(true)
        allow(Time).to receive(:zone).and_return(ActiveSupport::TimeZone["Arizona"])
        allow(Time.zone).to receive(:now).and_return(current_time)
      end

      context "when current Arizona time is before April 16, 00:00:00" do
        let(:current_time) { Time.zone.parse("2025-04-15 23:59:59") }

        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when current Arizona time is exactly April 16, 00:00:00" do
        let(:current_time) { Time.zone.parse("2025-04-16 00:00:00") }

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "when current Arizona time is after April 16, 00:00:00" do
        let(:current_time) { Time.zone.parse("2025-04-16 08:00:00") }

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end
    end

    context "when extension period is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:extension_period).and_return(false)
        allow(Time).to receive(:zone).and_return(ActiveSupport::TimeZone["Arizona"])
        allow(Time.zone).to receive(:now).and_return(current_time)
      end

      context "when current Arizona time is after April 16, 00:00:00" do
        let(:current_time) { Time.zone.parse("2025-04-16 08:00:00") }

        it "returns true" do
          expect(described_class.show?(intake)).to eq false
        end
      end
    end
  end
end
