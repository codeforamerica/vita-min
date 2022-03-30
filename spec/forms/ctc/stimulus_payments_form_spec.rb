require "rails_helper"

describe Ctc::StimulusPaymentsForm do
  let(:intake) { create :ctc_intake, client: client, eip3_amount_received: 123 }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  let(:params) {
    {
      eip_received_choice: eip_received_choice
    }
  }

  describe '#save' do
    before do
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(2400)
    end

    context "when the client received the full amount" do
      let(:eip_received_choice) { 'this_amount' }

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.eip3_amount_received).to eq(2400)
      end
    end

    context "when the client received no amount" do
      let(:eip_received_choice) { 'no_amount' }

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.eip3_amount_received).to eq(0)
      end
    end

    context "when the client received a different amount" do
      let(:eip_received_choice) { 'different_amount' }

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.eip3_amount_received).to be_nil
      end
    end
  end
end
