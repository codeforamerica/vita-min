require "rails_helper"

RSpec.describe StateFile::AzRetirementIncomeForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }
    let(:form) { described_class.new(intake, params) }

    context "dollar amounts are of the correct type" do
      let(:params) do
        {
          received_military_retirement_payment: "yes",
          received_military_retirement_payment_amount: "yes i am an amount",
          primary_received_pension: "yes",
          primary_received_pension_amount: "&*()$",
          spouse_received_pension: "yes",
          spouse_received_pension_amount: "beepboop",
        }
      end

      it "is invalid and attaches the correct error" do
        allow(intake).to receive(:filing_status_mfj?).and_return true

        expect(form).not_to be_valid
        expect(form.errors[:received_military_retirement_payment_amount]).to include "is not a number"
        expect(form.errors[:primary_received_pension_amount]).to include "is not a number"
        expect(form.errors[:spouse_received_pension_amount]).to include "is not a number"
      end

    #  TODO: maybe check that something like 30.3456 is not valid
    end

    context "single filer" do
      before do
        allow(intake).to receive(:filing_status_single?).and_return true
      end

      context "received_military_retirement_payment, primary_received_pension are no" do
        let(:params) do
          {
            received_military_retirement_payment: "no",
            primary_received_pension: "no",
          }
        end

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "received_military_retirement_payment is yes" do
        let(:params) do
          {
            received_military_retirement_payment: "yes",
            received_military_retirement_payment_amount: received_military_retirement_payment_amount,
            primary_received_pension: "no",
          }
        end

        context "received_military_retirement_payment_amount is present" do
          let(:received_military_retirement_payment_amount) { 1500 }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "received_military_retirement_payment_amount is blank" do
          let(:received_military_retirement_payment_amount) { nil }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:received_military_retirement_payment_amount]).to include "Can't be blank."
          end
        end
      end

      context "primary_received_pension is yes" do
        it "is valid if primary_received_pension_amount is present" do; end

        it "is invalid if primary_received_pension_amount is blank" do; end
      end

      context "total amount" do
        it "is valid if below total from df xml" do; end

        it "is invalid if above total from df xml" do; end
      end
    end

    context "mfj filers" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "received_military_retirement_payment, primary_received_pension, spouse_received_pension are no" do
        it "is valid" do; end
      end

      context "spouse_received_pension is yes" do
        it "is valid if spouse_received_pension_amount is present" do; end

        it "is invalid if spouse_received_pension_amount is blank" do; end
      end

      context "total amount" do
        it "is valid if below total from df xml" do; end

        it "is invalid if above total from df xml" do; end
      end
    end
  end

  describe "#save" do
  end
end



