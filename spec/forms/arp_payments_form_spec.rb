require "rails_helper"

describe ArpPaymentsForm do
  let(:intake) { create :intake }
  let(:form) do
    described_class.new(intake, {
       received_stimulus_payment: received_stimulus_payment,
       eip1_amount_received: eip1_amount_received,
       eip2_amount_received: eip2_amount_received,
       eip3_amount_received: eip3_amount_received,
    })
  end
  let(:received_stimulus_payment) { "unfilled" }
  let(:eip1_amount_received) { 0 }
  let(:eip2_amount_received) { 0 }
  let(:eip3_amount_received) { 0 }

  describe "validations" do
    context "eip" do
      context "when eip amounts are all blank and not unsure" do
        let(:received_stimulus_payment) { "unfilled" }
        let(:eip1_amount_received) {  }
        let(:eip2_amount_received) {  }
        let(:eip3_amount_received) {  }
        it "adds an error" do
          form.valid?
          expect(form.errors).to include :received_stimulus_payment
        end
      end
    end
  end

  describe "#save" do
    context "when stimulus was received" do
      let(:eip1_amount_received) { 100 }
      it "sets received_stimulus_payment to yes" do
        form.save
        expect(intake.reload.received_stimulus_payment).to eq "yes"
      end
    end

    context "when all stimulus payments are 0" do
      let(:eip1_amount_received) { 0 }
      let(:eip2_amount_received) { 0 }
      let(:eip3_amount_received) { 0 }

      it "sets received_stimulus_payment to yes" do
        form.save
        expect(intake.reload.received_stimulus_payment).to eq "no"
      end
    end

    context "when stimulus payments are 0 but provided an unsure value" do
      let(:eip1_amount_received) { 0 }
      let(:eip2_amount_received) { 0 }
      let(:eip3_amount_received) { 0 }
      let(:received_stimulus_payment) { "unsure" }

      it "leaves set to unsure" do
        form.save
        expect(intake.reload.received_stimulus_payment).to eq "unsure"
      end
    end
  end
end