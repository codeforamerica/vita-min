require "rails_helper"

RSpec.describe StateFile::AzExtensionPaymentsForm do
  describe "#valid?" do
    let(:intake) { create :state_file_az_intake }

    context "with out entering an amount" do
      let(:invalid_params) do
        {
          paid_extension_payments: "yes",
          extension_payments_amount: ""
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
          paid_extension_payments: "unfilled",
          extension_payments_amount: ""
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

    context "with no selected" do
      let(:invalid_params) do
        {
          paid_extension_payments: "no",
          extension_payments_amount: ""
        }
      end

      it "returns true" do
        form = described_class.new(intake, invalid_params)
        expect(form).to be_valid
      end
    end

    context "with yes selected and a valid amount" do
      let(:invalid_params) do
        {
          paid_extension_payments: "yes",
          extension_payments_amount: "2112"
        }
      end

      it "returns true" do
        form = described_class.new(intake, invalid_params)
        expect(form).to be_valid
      end
    end

    context "with yes selected and an invalid amount" do
      let(:invalid_params) do
        {
          paid_extension_payments: "yes",
          extension_payments_amount: "Nyarlathotep"
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
      end
    end

  end

  describe "#save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        paid_extension_payments: "yes",
        extension_payments_amount: "2112"
      }
    end

    it "saves the extension payment amount to the intake" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      expect do
        form.save
      end.to change { intake.reload.extension_payments_amount }.to(2112)
    end
  end

  describe "no extension payment amount to save" do
    let(:intake) { create :state_file_az_intake }
    let(:valid_params) do
      {
        paid_extension_payments: "no",
        extension_payments_amount: ""
      }
    end

    it "proceeds with nil prior last names" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.extension_payments_amount).to eq(0)
    end
  end

  describe "going back and removing prior last names" do
    let(:intake) { create :state_file_az_intake, extension_payments_amount: 2112 }
    let(:valid_params) do
      {
        paid_extension_payments: "no",
        extension_payments_amount: "2112"
      }
    end

    it "proceeds with nil prior last names" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      expect do
        form.save
      end.to change { intake.reload.extension_payments_amount }.to(0)
    end
  end
end
