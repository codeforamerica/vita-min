require "rails_helper"

describe Ctc::AdvanceCtcForm do
  let!(:intake) { create :ctc_intake, :with_dependents, client: client, advance_ctc_amount_received: nil, advance_ctc_entry_method: 'unfilled' }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  let(:params) {
    {
      advance_ctc_received_choice: advance_ctc_received_choice
    }
  }

  describe '#save' do
    context "when the client received the estimated amount" do
      let(:advance_ctc_received_choice) { 'yes_received' }

      it "persists the estimated advance CTC values to the DB" do
        described_class.new(intake, params).save
        benefits = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)

        intake.reload
        expect(intake.advance_ctc_amount_received).to eq(benefits.ctc_amount / 2)
        expect(intake.advance_ctc_entry_method).to eq('calculated_amount')
      end
    end

    context "when the client received a different amount" do
      let(:advance_ctc_received_choice) { 'no_received_different_amount' }

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.advance_ctc_amount_received).to eq(nil)
        expect(intake.advance_ctc_entry_method).to eq('unfilled')
      end
    end

    context "when the client received no amount" do
      let(:advance_ctc_received_choice) { 'no_did_not_receive' }

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.advance_ctc_amount_received).to eq(0)
        expect(intake.advance_ctc_entry_method).to eq('did_not_receive')
      end
    end
  end
end
