require "rails_helper"

describe Ctc::StimulusPaymentsForm do
  let(:intake) { create :ctc_intake, client: client, eip1_amount_received: 0 }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  let(:params) {
    {
      eip_received_choice: eip_received_choice
    }
  }

  describe '#save' do
    before do
      allow_any_instance_of(TaxReturn).to receive(:expected_recovery_rebate_credit_one).and_return(2400)
      allow_any_instance_of(TaxReturn).to receive(:expected_recovery_rebate_credit_two).and_return(1200)
    end

    context "when the client received the full amount" do
      let(:eip_received_choice) { 'yes_received' }

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.eip1_amount_received).to eq(2400)
        expect(intake.eip2_amount_received).to eq(1200)
      end
    end

    context "when the client received no amount" do
      let(:eip_received_choice) { 'no_did_not_receive' }

      before do
        intake.update(eip1_amount_received: 123)
        intake.update(eip1_amount_received: 456)
      end

      it "persists the calculated eip values to the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.eip1_amount_received).to be_nil
        expect(intake.eip2_amount_received).to be_nil
      end
    end
  end
end
