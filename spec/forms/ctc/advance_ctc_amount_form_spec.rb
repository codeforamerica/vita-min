require "rails_helper"

describe Ctc::AdvanceCtcAmountForm do
  let!(:intake) { create :ctc_intake, :with_dependents, client: client, advance_ctc_amount_received: nil, advance_ctc_entry_method: 'unfilled' }
  let(:client) { create :client, tax_returns: [build(:tax_return, year: 2021)] }

  let(:params) {
    {
      advance_ctc_amount_received: advance_ctc_amount
    }
  }

  describe '#save' do
    context "the client enters an amount" do
      let(:advance_ctc_amount) { 1000 }

      it "persists the amount into the DB" do
        described_class.new(intake, params).save

        intake.reload
        expect(intake.advance_ctc_amount_received).to eq(1000)
        expect(intake.advance_ctc_entry_method).to eq('manual_entry')
      end
    end

    context "the client does not enter anything" do
      let(:advance_ctc_amount) { nil }

      it "validates the presence of a value" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to match array_including(:advance_ctc_amount_received)
      end
    end
  end
end
