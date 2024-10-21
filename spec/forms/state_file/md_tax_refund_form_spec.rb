require "rails_helper"

RSpec.describe StateFile::MdTaxRefundForm do
  let!(:intake) { create :state_file_md_intake, payment_or_deposit_type: "unfilled" }

  let(:valid_params) do
    {
      payment_or_deposit_type: "mail",
      routing_number: "019456124",
      routing_number_confirmation: "019456124",
      account_number: "12345",
      account_number_confirmation: "12345",
      account_type: "checking",
      bank_name: "Bank official",
      account_holder_name: "Geddy Lee"
    }
  end

  describe "#save" do
    context "when params valid and payment type is mail" do
      it "updates the intake" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.payment_or_deposit_type).to eq "mail"
        expect(intake.account_type).to eq "unfilled"
        expect(intake.account_number).to be_nil
        expect(intake.routing_number).to be_nil
        expect(intake.bank_name).to be_nil
        expect(intake.account_holder_name).to be_nil
      end
    end

    context "when params valid and payment type is deposit" do
      let(:valid_params) do
        super().merge(payment_or_deposit_type: "direct_deposit")
      end

      it "updates the intake" do
        form = described_class.new(intake, valid_params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.payment_or_deposit_type).to eq "direct_deposit"
        expect(intake.account_type).to eq "checking"
        expect(intake.routing_number).to eq "019456124"
        expect(intake.account_number).to eq "12345"
        expect(intake.bank_name).to eq "Bank official"
        expect(intake.account_holder_name).to eq "Geddy Lee"
      end
    end

    context "when overwriting an existing intake" do
      let!(:intake) do
        create(
          :state_file_md_intake,
          payment_or_deposit_type: "mail",
          routing_number: "019456124",
          account_number: "12345",
          account_type: "checking",
          bank_name: "Bank official",
          account_holder_name: "Laney Knope"
        )
      end

      it "updates the intake" do
        form = described_class.new(intake, valid_params.merge(payment_or_deposit_type: "mail"))
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.payment_or_deposit_type).to eq "mail"
        expect(intake.account_type).to eq "unfilled"
        expect(intake.account_number).to be_nil
        expect(intake.routing_number).to be_nil
        expect(intake.bank_name).to be_nil
        expect(intake.account_holder_name).to be_nil
      end
    end
  end

  describe "#valid?" do
    let(:payment_or_deposit_type) { "direct_deposit" }
    let(:routing_number) { "019456124" }
    let(:routing_number_confirmation) { "019456124" }
    let(:account_number) { "12345" }
    let(:account_number_confirmation) { "12345" }
    let(:account_type) { "checking" }
    let(:bank_name) { "Bank official" }
    let(:account_holder_name) { "Laney Knope" }

    let(:params) do
      {
        payment_or_deposit_type: payment_or_deposit_type,
        routing_number: routing_number,
        routing_number_confirmation: routing_number_confirmation,
        account_number: account_number,
        account_number_confirmation: account_number_confirmation,
        account_type: account_type,
        bank_name: bank_name,
        account_holder_name: account_holder_name
      }
    end

    context "when the payment_or_deposit_type is mail and no other params" do
      let(:params) { { payment_or_deposit_type: "mail" } }
      it "is valid" do
        form = described_class.new(intake, params)

        expect(form).to be_valid
      end
    end

    context "when the payment_or_deposit_type is direct_deposit" do
      context "all other params present" do
        it "is valid" do
          form = described_class.new(intake, params)
          expect(form).to be_valid
        end
      end

      context "missing account holder name" do
        let(:account_holder_name) { nil }
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :account_holder_name
        end
      end

      # Keep the other context tests for invalid routing numbers, account numbers, etc.
    end
  end
end
