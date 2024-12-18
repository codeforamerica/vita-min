require "rails_helper"

shared_examples :nj_money_field_concern do |field:, must_be_positive: false, can_be_empty: false|
  describe "validations" do
    let(:form) { described_class.new(intake, form_params) }

    context "invalid params" do
      context "field #{can_be_empty ? "can" : "cannot"} be nil" do
        let(:money_field_value) { nil }

        it "is #{can_be_empty ? "valid" : "invalid"}" do
          expect(form.valid?).to eq can_be_empty
          unless can_be_empty
            expect(form.errors[field]).to include "Can't be blank."
          end
        end
      end

      context "with a non numeric sales-use-tax" do
        let(:money_field_value) { "NaN" }

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[field]).to include "Please enter numbers only."
        end
      end

      context "with a value less than 0" do
        let(:money_field_value) { -1 }

        it "is invalid" do
          expect(form.valid?).to eq false
          p must_be_positive
          expected_message = must_be_positive ? "must be greater than or equal to 1" : "must be greater than or equal to 0"
          expect(form.errors[field]).to include expected_message
        end
      end
    end

    context "valid params" do
      context "with an integer field value" do
        let(:money_field_value) { 30 }

        it "is valid" do
          expect(form.valid?).to eq true
        end
      end

      context "with a non-integer field value" do
        let(:money_field_value) { 30.55 }

        it "is valid" do
          expect(form.valid?).to eq true
        end
      end
    end
  end
end
