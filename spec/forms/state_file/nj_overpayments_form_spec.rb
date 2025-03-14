require "rails_helper"

RSpec.describe StateFile::NjOverpaymentsForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, params) }

    it_behaves_like :nj_money_field_concern, field: :overpayments, can_be_empty: false do
      let(:form_params) do
        {
          has_overpayments: "yes",
          overpayments: money_field_value
        }
      end
    end

    context "invalid params" do
      context "has_overpayments is required" do
        let(:params) do
          { has_overpayments: nil }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:has_overpayments]).to include "Can't be blank."
        end
      end

      context "overpayments is required if has_overpayments=yes" do
        let(:params) do
          {
            has_overpayments: "yes",
            overpayments: nil
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
      create :state_file_nj_intake, has_overpayments: nil, overpayments: 0
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving" do
      let(:valid_params) do
        {
          has_overpayments: "yes",
          overpayments: 12345
        }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save
        expect(intake.has_overpayments).to eq "yes"
        expect(intake.overpayments).to eq 12345
      end
    end
  end
end
