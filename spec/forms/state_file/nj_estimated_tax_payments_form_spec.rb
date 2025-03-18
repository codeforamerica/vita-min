require "rails_helper"

RSpec.describe StateFile::NjEstimatedTaxPaymentsForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :nj_money_field_concern, field: :estimated_tax_payments, can_be_empty: false do
      let(:form_params) do
        {
          has_estimated_payments: "yes",
          overpayments: 0,
          estimated_tax_payments: money_field_value
        }
      end
    end

    it_behaves_like :nj_money_field_concern, field: :overpayments, can_be_empty: false do
      let(:form_params) do
        {
          has_estimated_payments: "yes",
          overpayments: money_field_value,
          estimated_tax_payments: 0
        }
      end
    end

    context "invalid params" do
      context "has_estimated_payments is required" do
        let(:params) do
          { has_estimated_payments: nil }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:has_estimated_payments]).to include "Can't be blank."
        end
      end

      context "estimated_tax_payments is required if has_estimated_payments=yes" do
        let(:params) do
          {
            has_estimated_payments: "yes",
            overpayments: 0,
            estimated_tax_payments: nil
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:estimated_tax_payments]).to include "Can't be blank."
        end
      end

      context "overpayments is required if has_estimated_payments=yes" do
        let(:params) do
          {
            has_estimated_payments: "yes",
            overpayments: nil,
            estimated_tax_payments: 0
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:overpayments]).to include "Can't be blank."
        end
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, has_estimated_payments: nil, estimated_tax_payments: 0, overpayments: 0
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving" do
      let(:valid_params) do
        {
          has_estimated_payments: "yes",
          estimated_tax_payments: 12345,
          overpayments: 54321
        }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save
        expect(intake.has_estimated_payments).to eq "yes"
        expect(intake.estimated_tax_payments).to eq 12345
        expect(intake.overpayments).to eq 54321
      end
    end
  end
end
