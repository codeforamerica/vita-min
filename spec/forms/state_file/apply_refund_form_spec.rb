require "rails_helper"

RSpec.describe StateFile::ApplyRefundForm do
  describe "#valid?" do
    let(:intake) { create :state_file_id_intake }

    context "with out entering an amount" do
      let(:invalid_params) do
        {
          paid_prior_year_refund_payments: "yes",
          prior_year_refund_payments_amount: ""
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with no radio selected" do
      let(:invalid_params) do
        {
          paid_prior_year_refund_payments: "unfilled",
          prior_year_refund_payments_amount: ""
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with no selected" do
      let(:params) do
        {
          paid_prior_year_refund_payments: "no",
          prior_year_refund_payments_amount: ""
        }
      end

      it "returns true" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "with yes selected and a valid amount" do
      let(:invalid_params) do
        {
          paid_prior_year_refund_payments: "yes",
          prior_year_refund_payments_amount: "2112"
        }
      end

      it "returns true" do
        form = described_class.new(intake, invalid_params)
        expect(form).to be_valid
      end
    end

    context "with yes selected and a non number" do
      let(:invalid_params) do
        {
          paid_prior_year_refund_payments: "yes",
          prior_year_refund_payments_amount: "Nyarlathotep"
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with yes selected and zero" do
      let(:invalid_params) do
        {
          paid_prior_year_refund_payments: "yes",
          prior_year_refund_payments_amount: "0"
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end
  end

  describe "#save" do
    let(:intake) { create :state_file_id_intake }
    let(:valid_params) do
      {
        paid_prior_year_refund_payments: "yes",
        prior_year_refund_payments_amount: "2112"
      }
    end

    it "saves the prior year refund payment amount to the intake" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      expect do
        form.save
      end.to change { intake.reload.prior_year_refund_payments_amount }.to(2112)
    end

    describe "no prior year refund payment amount to save" do
      let(:intake) { create :state_file_id_intake }
      let(:valid_params) do
        {
          paid_prior_year_refund_payments: "no",
          prior_year_refund_payments_amount: ""
        }
      end

      it "proceeds with no prior year refund" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save
        expect(intake.reload.prior_year_refund_payments_amount).to eq(0)
      end
    end

    describe "going back and removing amount" do
      let(:intake) { create :state_file_id_intake, prior_year_refund_payments_amount: 2112 }
      let(:valid_params) do
        {
          paid_prior_year_refund_payments: "no",
          prior_year_refund_payments_amount: "2112"
        }
      end

      it "proceeds with 0 amount" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        expect do
          form.save
        end.to change { intake.reload.prior_year_refund_payments_amount }.to(0)
      end
    end
  end
end
