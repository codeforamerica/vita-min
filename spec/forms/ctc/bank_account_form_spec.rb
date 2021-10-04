require "rails_helper"

describe Ctc::BankAccountForm do
  let!(:bank_account) { create(:bank_account, intake: intake) }
  let(:intake) { create :ctc_intake }
  let(:bank_name) { "Bank of America" }
  let(:account_type) { "checking" }
  let(:my_bank_account) { "yes" }
  let(:routing_number) { "123456789" }
  let(:routing_number_confirmation) { "123456789" }
  let(:account_number) { "123456789" }
  let(:account_number_confirmation) { "123456789" }
  let(:params) do
    {
        bank_name: bank_name,
        account_type: account_type,
        my_bank_account: my_bank_account,
        routing_number: routing_number,
        routing_number_confirmation: routing_number_confirmation,
        account_number: account_number,
        account_number_confirmation: account_number_confirmation
    }
  end
  context 'validations' do
    context "bank_name" do
      context "when not present" do
        let(:bank_name) { nil }
        it "is not valid" do
          expect(described_class.new(bank_account, params)).not_to be_valid
        end
      end
    end

    context "bank_account_type" do
      context "when not present" do
        let(:account_type) { nil }
        it "is not valid" do
          expect(described_class.new(bank_account, params)).not_to be_valid
        end
      end
    end

    context "my_bank_account" do
      context "when not checked yes" do
        let(:my_bank_account) { "no" }
        it "is not valid" do
          expect(described_class.new(bank_account, params)).not_to be_valid
        end
      end
    end

    context "when routing number is less than 9 digits" do
      let(:routing_number) { "12345678" }
      let(:routing_number_confirmation) { "12345678" }
      it "is not valid" do
        expect(
            described_class.new(bank_account, params)
        ).not_to be_valid
      end
    end

    context "when the routing number confirmation does not match" do
      let(:routing_number) { "123456789" }
      let(:routing_number_confirmation) { "12345678" }
      it "is not valid" do
        expect(
            described_class.new(bank_account, params)
        ).not_to be_valid
      end
    end

    context "when the leading digits are not part of the acceptable routing numbers for direct deposit" do
      let(:routing_number) { "132456789" }
      let(:routing_number_confirmation) { "132456789" }

      it "is not valid" do
        expect(
          described_class.new(bank_account, params)
        ).not_to be_valid
      end
    end

    context "when account number is greater than than 17 digits" do
      let(:account_number) { "123456789012345678" }
      let(:account_number_confirmation) { "123456789012345678" }
      it "is not valid" do
        expect(
            described_class.new(bank_account, params)
        ).not_to be_valid
      end
    end

    context "when the account number confirmation does not match" do
      let(:account_number) { "123456789" }
      let(:account_number_confirmation) { "12345678" }
      it "is not valid" do
        expect(
          described_class.new(bank_account, params)
        ).not_to be_valid
      end
    end

    context "when the account number includes non digit characters" do
      let(:routing_number) { "132456af789" }
      let(:routing_number_confirmation) { "132456af789" }

      it "is not valid" do
        expect(
            described_class.new(bank_account, params)
        ).not_to be_valid
      end
    end
  end

  context '#save' do
    context "when there is an existing bank account object" do
      it "updates the existing bank account object" do
        expect {
          described_class.new(bank_account, params).save
          intake.reload
        }.to change(BankAccount, :count).by(0)
        bank_account = intake.bank_account
        expect(bank_account.bank_name).to eq "Bank of America"
        expect(bank_account.account_type).to eq "checking"
        expect(bank_account.intake).to eq intake
      end
    end
  end
end
