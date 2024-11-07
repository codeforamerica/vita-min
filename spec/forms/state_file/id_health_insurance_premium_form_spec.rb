require "rails_helper"

RSpec.describe StateFile::IdHealthInsurancePremiumForm do
  let(:intake_has_health_insurance_premium) { "no" }
  let(:health_insurance_paid_amount) { nil }
  let(:intake) do
    create :state_file_id_intake,
           has_health_insurance_premium: intake_has_health_insurance_premium,
           health_insurance_paid_amount: health_insurance_paid_amount
  end

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    context "invalid params" do
      context "has_health_insurance_premium is required" do
        let(:params) do
          {
            has_health_insurance_premium: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:has_health_insurance_premium]).to include "Can't be blank."
        end
      end

      context "health_insurance_paid_amount is required if client has_health_insurance_premium" do
        let(:params) do
          {
            has_health_insurance_premium: "yes",
            health_insurance_paid_amount: nil
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:health_insurance_paid_amount]).to include "Can't be blank."
        end
      end

      context "with a non numeric health_insurance_paid_amount" do
        let(:params) do
          {
            has_health_insurance_premium: "yes",
            health_insurance_paid_amount: "NaN",
          }
        end

        it "is valid" do
          expect(form.valid?).to eq false
          expect(form.errors[:health_insurance_paid_amount]).to include "Please enter numbers only."
        end
      end

      context "with a value less than 0" do
        let(:params) do
          {
            has_health_insurance_premium: "yes",
            health_insurance_paid_amount: "-1",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:health_insurance_paid_amount]).to include "Please enter numbers only."
        end
      end
    end

    context "valid params" do

      context "with a non integer health insurance paid amount" do
        let(:params) do
          {
            has_health_insurance_premium: "yes",
            health_insurance_paid_amount: "30.5",
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq true
        end
      end

    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }

    context "has health_insurance_premium" do
      let(:valid_params) do
        { has_health_insurance_premium: "yes",
          health_insurance_paid_amount: 1699.51 }
      end

      it "saves values" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.has_health_insurance_premium).to eq "yes"
        expect(intake.health_insurance_paid_amount).to eq 1699.51
      end
    end

    context "no longer has health insurance premium (switched after selecting 'yes' and inputting value)" do
      let(:valid_params) do
        { has_health_insurance_premium: "no",
          health_insurance_paid_amount: 1699.51 }
      end

      it "saves values" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.has_health_insurance_premium).to eq "no"
        expect(intake.health_insurance_paid_amount).to eq nil
      end
    end
  end
end
