require "rails_helper"

describe ArpPaymentsForm do
  let(:intake) { create :intake }
  let(:form) do
    described_class.new(intake, {
       received_stimulus_payment: received_stimulus_payment,
       eip1_amount_received: eip1_amount_received,
       eip2_amount_received: eip2_amount_received,
       eip3_amount_received: eip3_amount_received,
       advance_ctc_amount_received: advance_ctc_amount_received,
       received_advance_ctc_payment: received_advance_ctc_payment
    })
  end
  let(:received_stimulus_payment) { "unfilled" }
  let(:eip1_amount_received) { }
  let(:eip2_amount_received) { }
  let(:eip3_amount_received) { }
  let(:advance_ctc_amount_received) { }
  let(:received_advance_ctc_payment) { "unfilled" }

  describe "validations" do
    context "eip" do
      context "when eip amounts are all blank and not unsure" do
        it "adds an error" do
          form.valid?
          expect(form.errors).to include :received_stimulus_payment
        end
      end

      context "when unsure and eip amounts are blank" do
        let(:received_advance_ctc_payment) { "unsure" }
        it "is valid" do
          form.valid?
          expect(form.errors).not_to include :received_stimulus_payment
        end
      end
    end

    context "ctc" do
      context "when ctc amount is blank and not unsure" do
        it "adds an error" do
          form.valid?
          expect(form.errors).to include :received_advance_ctc_payment
        end
      end

      context "when ctc amount is unsure and blank" do
        let(:received_advance_ctc_payment) { "unsure" }
        it "does not add an error" do
          form.valid?
          expect(form.errors).not_to include :received_advance_ctc_payment
        end
      end
    end
  end
end