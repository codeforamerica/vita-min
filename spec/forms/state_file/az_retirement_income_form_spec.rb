require "rails_helper"

RSpec.describe StateFile::AzRetirementIncomeForm do
  let(:intake) { create :state_file_az_intake }
  let(:form) { described_class.new(intake, params) }
  before do
    intake.direct_file_data.fed_taxable_pensions = 1000
  end

  describe "#valid?" do
    context "non-numerical values" do
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
          let(:received_military_retirement_payment_amount) { 500.50 }

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
        let(:params) do
          {
            received_military_retirement_payment: "no",
            primary_received_pension: "yes",
            primary_received_pension_amount: primary_received_pension_amount,
          }
        end

        context "primary_received_pension_amount is present" do
          let(:primary_received_pension_amount) { 500.25 }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "primary_received_pension_amount is blank" do
          let(:primary_received_pension_amount) { nil }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:primary_received_pension_amount]).to include "Can't be blank."
          end
        end
      end

      context "total amount" do
        let(:params) do
          {
            received_military_retirement_payment: "yes",
            received_military_retirement_payment_amount: received_military_retirement_payment_amount,
            primary_received_pension: "yes",
            primary_received_pension_amount: primary_received_pension_amount,
          }
        end

        before do
          intake.direct_file_data.fed_taxable_pensions = 1000
        end

        context "total is less than or equal to TotalTaxablePensionsAmt" do
          let(:received_military_retirement_payment_amount) { 500 }
          let(:primary_received_pension_amount) { 500 }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "total is greater than TotalTaxablePensionsAmt" do
          let(:received_military_retirement_payment_amount) { 500 }
          let(:primary_received_pension_amount) { 501 }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include "Total amount entered must not exceed $1000"
          end
        end
      end
    end

    context "mfj filers" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return true
      end

      context "received_military_retirement_payment, primary_received_pension, spouse_received_pension are no" do
        let(:params) do
          {
            received_military_retirement_payment: "no",
            primary_received_pension: "no",
            spouse_received_pension: "no",
          }
        end

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "spouse_received_pension is yes" do
        let(:params) do
          {
            received_military_retirement_payment: "no",
            primary_received_pension: "no",
            spouse_received_pension: "yes",
            spouse_received_pension_amount: spouse_received_pension_amount,
          }
        end

        context "spouse_received_pension_amount is present" do
          let(:spouse_received_pension_amount) { 500 }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "spouse_received_pension_amount is blank" do
          let(:spouse_received_pension_amount) { nil }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:spouse_received_pension_amount]).to include "Can't be blank."
          end
        end
      end

      context "total amount" do
        let(:params) do
          {
            received_military_retirement_payment: "yes",
            received_military_retirement_payment_amount: received_military_retirement_payment_amount,
            primary_received_pension: "yes",
            primary_received_pension_amount: primary_received_pension_amount,
            spouse_received_pension: "yes",
            spouse_received_pension_amount: spouse_received_pension_amount,
          }
        end

        before do
          intake.direct_file_data.fed_taxable_pensions = 1500
        end

        context "total is less than or equal to TotalTaxablePensionsAmt" do
          let(:received_military_retirement_payment_amount) { 500 }
          let(:primary_received_pension_amount) { 500 }
          let(:spouse_received_pension_amount) { 500 }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "total is greater than TotalTaxablePensionsAmt" do
          let(:received_military_retirement_payment_amount) { 500 }
          let(:primary_received_pension_amount) { 500 }
          let(:spouse_received_pension_amount) { 501 }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:base]).to include "Total amount entered must not exceed $1500"
          end
        end
      end
    end
  end

  describe "#save" do
    let(:params) do
      {
        received_military_retirement_payment: "yes",
        received_military_retirement_payment_amount: 100,
        primary_received_pension: "yes",
        primary_received_pension_amount: 200,
        spouse_received_pension: "yes",
        spouse_received_pension_amount: 300,
      }
    end

    it "saves the answers to the intake" do
      form.save
      intake.reload
      expect(intake.received_military_retirement_payment_yes?).to eq true
      expect(intake.received_military_retirement_payment_amount).to eq 100
      expect(intake.primary_received_pension_yes?).to eq true
      expect(intake.primary_received_pension_amount).to eq 200
      expect(intake.spouse_received_pension_yes?).to eq true
      expect(intake.spouse_received_pension_amount).to eq 300
    end

    # the more i search the internet for questions having to do with validating and saving decimals for money values,
    # the more i see people saying you shouldn't do this in rails and should instead use the money gem.
    # for now we're going with the built-in functionality which will round any extra decimal places but may want to
    # reconsider the whole data type.
    context "rounding decimals" do
      let(:params) do
        {
          received_military_retirement_payment: "yes",
          received_military_retirement_payment_amount: 20.255,
          primary_received_pension: "yes",
          primary_received_pension_amount: 400.1234,
          spouse_received_pension: "yes",
          spouse_received_pension_amount: 50.98076,
        }
      end

      it "rounds the values when saving" do
        form.save
        intake.reload
        expect(intake.received_military_retirement_payment_yes?).to eq true
        expect(intake.received_military_retirement_payment_amount).to eq 20.26
        expect(intake.primary_received_pension_yes?).to eq true
        expect(intake.primary_received_pension_amount).to eq 400.12
        expect(intake.spouse_received_pension_yes?).to eq true
        expect(intake.spouse_received_pension_amount).to eq 50.98
      end
    end
  end
end



