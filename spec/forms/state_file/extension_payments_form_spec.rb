require "rails_helper"

RSpec.describe StateFile::ExtensionPaymentsForm do
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
      let(:params) do
        {
          paid_extension_payments: "no",
          extension_payments_amount: ""
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
          paid_extension_payments: "yes",
          extension_payments_amount: "2112"
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
          paid_extension_payments: "yes",
          extension_payments_amount: "Nyarlathotep"
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors[:extension_payments_amount]).to include I18n.t("validators.not_a_number")
      end
    end

    context "with yes selected and zero" do
      let(:invalid_params) do
        {
          paid_extension_payments: "yes",
          extension_payments_amount: "0"
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors[:extension_payments_amount]).to include I18n.t("state_file.questions.extension_payments.default_payment_validation_message")
      end
    end

    context "with yes selected and blank value" do
      let(:invalid_params) do
        {
          paid_extension_payments: "yes",
          extension_payments_amount: nil
        }
      end

      it "returns false" do
        form = described_class.new(intake, invalid_params)
        expect(form).not_to be_valid
        expect(form.errors[:extension_payments_amount]).to include I18n.t("state_file.questions.extension_payments.default_payment_validation_message")
      end
    end

    context "when Idaho" do
      let(:intake) { create :state_file_id_intake }
      let(:extension_payments_amount) { "0" }
      let(:invalid_params) do
        {
          paid_extension_payments: "yes",
          extension_payments_amount: extension_payments_amount
        }
      end

      context "when value is zero" do
        it "error_msg_if_blank_or_zero is the Idaho specific payment_validation_message" do
          form = described_class.new(intake, invalid_params)
          expect(form).not_to be_valid
          expect(form.errors[:extension_payments_amount]).to include I18n.t("state_file.questions.extension_payments.id.payment_validation_message")
          expect(form.error_msg_if_blank_or_zero).to eq I18n.t("state_file.questions.extension_payments.id.payment_validation_message")
        end
      end

      context "when value is blank" do
        let(:extension_payments_amount) { "" }
        it "error_msg_if_blank_or_zero is the Idaho specific payment_validation_message" do
          form = described_class.new(intake, invalid_params)
          expect(form).not_to be_valid
          expect(form.error_msg_if_blank_or_zero).to eq I18n.t("state_file.questions.extension_payments.id.payment_validation_message")
        end
      end

      context "when value is a non-numeric value" do
        let(:extension_payments_amount) { "hello" }
        it "error_msg_if_blank_or_zero is the Idaho specific payment_validation_message" do
          form = described_class.new(intake, invalid_params)
          expect(form).not_to be_valid
          expect(form.errors[:extension_payments_amount]).to include I18n.t("validators.not_a_number")
        end
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

    it "proceeds with no prior last names" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      expect(intake.reload.extension_payments_amount).to eq(0)
    end
  end

  describe "going back and removing amount" do
    let(:intake) { create :state_file_az_intake, extension_payments_amount: 2112 }
    let(:valid_params) do
      {
        paid_extension_payments: "no",
        extension_payments_amount: "2112"
      }
    end

    it "proceeds with 0 amount" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      expect do
        form.save
      end.to change { intake.reload.extension_payments_amount }.to(0)
    end
  end
end
