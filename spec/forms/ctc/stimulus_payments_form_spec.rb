require "rails_helper"

describe Ctc::StimulusPaymentsForm do
  let(:intake) { create :ctc_intake, client: client, eip1_amount_received: 0 }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2020)] }

  let(:params) {
    {
      eip1_entry_method: "calculated_amount",
      eip2_entry_method: "calculated_amount"
    }
  }

  describe '#save' do
    before do
      allow_any_instance_of(TaxReturn).to receive(:expected_recovery_rebate_credit_one).and_return(2400)
      allow_any_instance_of(TaxReturn).to receive(:expected_recovery_rebate_credit_two).and_return(1200)
    end

    it "persists the calculated eip values to the DB" do
      described_class.new(intake, params).save

      intake.reload
      expect(intake.eip1_amount_received).to eq(2400)
      expect(intake.eip2_amount_received).to eq(1200)
    end
  end
end
