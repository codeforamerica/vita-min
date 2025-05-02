require "rails_helper"

RSpec.describe StateFile::FederalExtensionPaymentsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }
    let(:paid) { nil }
    let(:params) do
      {
        paid_federal_extension_payments: paid
      }
    end
    let(:form) {  described_class.new(intake, params) }

    context "with no radio selected" do
      it "returns false" do
        expect(form).not_to be_valid
      end
    end

    context "with no selected" do
      let(:paid) { "no" }

      it "returns true" do
        expect(form).to be_valid
      end
    end

    context "with yes selected" do
      let(:paid) { "yes" }

      it "returns true" do
        expect(form).to be_valid
      end
    end
  end
end
