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
  let(:eip1_amount_received) { 0 }
  let(:eip2_amount_received) { 0 }
  let(:eip3_amount_received) { 0 }
  let(:advance_ctc_amount_received) { 0 }
  let(:received_advance_ctc_payment) { "unfilled" }

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
        let(:advance_ctc_amount_received) { nil }
        let(:received_advance_ctc_payment) { "unfilled" }
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

    context "when advance ctc is set to 0" do
      let(:advance_ctc_amount_received) { 0  }
      let(:received_advance_ctc_payment) { "unfilled" }
      it "sets received ctc to no" do
        form.save
        expect(intake.reload.received_advance_ctc_payment).to eq "no"
      end
    end

    context "when advance ctc is set to a number other than 0" do
      let(:advance_ctc_amount_received) { 10 }
      let(:received_advance_ctc_payment) { "unfilled" }
      it "sets received ctc to yes" do
        form.save
        expect(intake.reload.received_advance_ctc_payment).to eq "yes"
      end
    end

    context "when advance ctc is set to a number other than 0 and unsure is checked" do
      let(:advance_ctc_amount_received) { 10  }
      let(:received_advance_ctc_payment) { "unsure" }

      it "sets received ctc to unsure" do
        form.save
        expect(intake.reload.received_advance_ctc_payment).to eq "unsure"
      end
    end

  end
end