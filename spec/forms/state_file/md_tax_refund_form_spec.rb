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
      account_holder_first_name: "Geddy",
      account_holder_middle_initial: "J",
      account_holder_last_name: "Lee",
      account_holder_suffix: "JR",
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
        expect(intake.account_holder_first_name).to be_nil
        expect(intake.account_holder_middle_initial).to be_nil
        expect(intake.account_holder_last_name).to be_nil
        expect(intake.account_holder_suffix).to be_nil
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
        expect(intake.account_holder_first_name).to eq "Geddy"
        expect(intake.account_holder_middle_initial).to eq "J"
        expect(intake.account_holder_last_name).to eq "Lee"
        expect(intake.account_holder_suffix).to eq "JR"
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
          account_holder_first_name: "Laney",
          account_holder_middle_initial: "",
          account_holder_last_name: "Knope",
          account_holder_suffix: "",
          joint_account_holder_first_name: "Janey",
          joint_account_holder_middle_initial: "",
          joint_account_holder_last_name: "Knope",
          joint_account_holder_suffix: "",
          has_joint_account_holder: 'yes',
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
        expect(intake.account_holder_first_name).to be_nil
        expect(intake.account_holder_middle_initial).to be_nil
        expect(intake.account_holder_last_name).to be_nil
        expect(intake.account_holder_suffix).to be_nil
        expect(intake.account_holder_first_name).to be_nil
        expect(intake.account_holder_middle_initial).to be_nil
        expect(intake.account_holder_last_name).to be_nil
        expect(intake.account_holder_suffix).to be_nil
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
    let(:account_holder_first_name) { "Laney" }
    let(:account_holder_middle_initial) { "K" }
    let(:account_holder_last_name) { "Knope" }
    let(:account_holder_suffix) { "II" }
    let(:joint_account_holder_first_name) { "" }
    let(:joint_account_holder_middle_initial) { "" }
    let(:joint_account_holder_last_name) { "" }
    let(:joint_account_holder_suffix) { "" }
    let(:has_joint_account_holder) { "no" }

    let(:params) do
      {
        payment_or_deposit_type: payment_or_deposit_type,
        routing_number: routing_number,
        routing_number_confirmation: routing_number_confirmation,
        account_number: account_number,
        account_number_confirmation: account_number_confirmation,
        account_type: account_type,
        account_holder_first_name: account_holder_first_name,
        account_holder_middle_initial: account_holder_middle_initial,
        account_holder_last_name: account_holder_last_name,
        account_holder_suffix: account_holder_suffix,
        has_joint_account_holder: has_joint_account_holder,
        joint_account_holder_first_name: joint_account_holder_first_name,
        joint_account_holder_middle_initial: joint_account_holder_middle_initial,
        joint_account_holder_last_name: joint_account_holder_last_name,
        joint_account_holder_suffix: joint_account_holder_suffix,
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
      let(:payment_or_deposit_type) { "direct_deposit" }

      context "all other params present" do
        it "is valid" do
          form = described_class.new(intake, params)
          expect(form).to be_valid
        end
      end

      context "missing account holder name" do
        let(:account_holder_first_name) { nil }
        let(:account_holder_last_name) { nil }
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :account_holder_first_name
          expect(form.errors).to include :account_holder_last_name
        end
      end

      context "has invalid account_holder params" do
        let(:account_holder_first_name) { "A123456789101112131415A1234567891" }
        let(:account_holder_middle_initial) { 'AB' }
        let(:account_holder_last_name) { "B'23%9" }
        let(:account_holder_suffix) { "SH" }

        it "is invalid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:account_holder_first_name]).to include("Only letters, hyphen, and apostrophe are accepted, and first name must be less than 16 characters.")
          expect(form.errors[:account_holder_middle_initial]).to include("is too long (maximum is 1 character)")
          expect(form.errors[:account_holder_last_name]).to include("Only letters, hyphen, and apostrophe are accepted, and last name must be less than 32 characters.")
          expect(form.errors[:account_holder_suffix]).to include("is not included in the list")
        end
      end

      context "missing joint account holder name" do
        let(:joint_account_holder_first_name) { nil }
        let(:joint_account_holder_last_name) { nil }

        context "when client did not indicate has_joint_account_holder" do
          it "is valid" do
            form = described_class.new(intake, params)
            expect(form).to be_valid
            expect(form.errors).to be_empty
          end
        end

        context "when client did indicate has_joint_account_holder" do
          let(:has_joint_account_holder) { 'yes' }

          context "has valid params" do
            let(:joint_account_holder_first_name) { "ABCD EFGH-JKLM" }
            let(:joint_account_holder_middle_initial) { "Z" }
            let(:joint_account_holder_last_name) { "B'ONEIL" }
            let(:joint_account_holder_suffix) { "VII" }

            it "is valid" do
              form = described_class.new(intake, params)
              expect(form).to be_valid
              expect(form.errors).to be_empty
            end
          end

          context "has invalid params" do
            let(:joint_account_holder_first_name) { "A123456789101112131415A1234567891" }
            let(:joint_account_holder_middle_initial) { 'AB' }
            let(:joint_account_holder_last_name) { "B'23%9" }
            let(:joint_account_holder_suffix) { "SH" }

            it "is invalid" do
              form = described_class.new(intake, params)
              expect(form).not_to be_valid
              expect(form.errors[:joint_account_holder_first_name]).to include("Only letters, hyphen, and apostrophe are accepted, and first name must be less than 16 characters.")
              expect(form.errors[:joint_account_holder_middle_initial]).to include("is too long (maximum is 1 character)")
              expect(form.errors[:joint_account_holder_last_name]).to include("Only letters, hyphen, and apostrophe are accepted, and last name must be less than 32 characters.")
              expect(form.errors[:joint_account_holder_suffix]).to include("is not included in the list")
            end
          end

          context "has missing params" do
            let(:joint_account_holder_first_name) { nil }
            let(:joint_account_holder_middle_initial) { nil }
            let(:joint_account_holder_last_name) { nil }
            let(:joint_account_holder_suffix) { nil }

            it "is invalid" do
              form = described_class.new(intake, params)
              expect(form).not_to be_valid
              expect(form.errors[:joint_account_holder_first_name]).to include("Can't be blank.")
              expect(form.errors[:joint_account_holder_middle_initial]).to be_empty
              expect(form.errors[:joint_account_holder_last_name]).to include("Can't be blank.")
              expect(form.errors[:joint_account_holder_suffix]).to be_empty
            end
          end
        end
      end

      context "missing account type" do
        let(:account_type) { nil }
        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :account_type
        end
      end

      context "account number is letters" do
        let(:account_number) { "ABC" }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :account_number
        end
      end

      context "account number is too long" do
        let(:account_number) { '1234567891011121314' }

        it 'is not valid' do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :account_number
        end
      end

      context "routing number is letters" do
        let(:routing_number) { "ABC123456" }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :routing_number
        end
      end

      context "routing number is 3 numbers long" do
        let(:routing_number) { "123" }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :routing_number
        end
      end

      context "routing number does not match the regex" do
        let(:routing_number) { "339999999" }
        let(:routing_number_confirmation) { "339999999" }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :routing_number
        end
      end

      context "account number confirmation is not equal to the account number" do
        let(:account_number_confirmation) { "1234" }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :account_number_confirmation
        end
      end

      context "routing number confirmation is not equal to the routing number" do
        let(:routing_number_confirmation) { "999999999" }

        it "is not valid" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors).to include :routing_number_confirmation
        end
      end

      context "when the routing and account number are the same" do
        let(:routing_number) { "123456789" }
        let(:account_number) { "123456789" }

        it "is not valid and returns error" do
          form = described_class.new(intake, params)

          expect(form).not_to be_valid
          expect(form.errors).to include :routing_number, :account_number
        end
      end
    end
  end
end
