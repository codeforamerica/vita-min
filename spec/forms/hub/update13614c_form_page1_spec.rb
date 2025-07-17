require "rails_helper"

RSpec.describe Hub::Update13614cFormPage1 do
  let(:intake) {
    build :intake,
          :with_contact_info,
          email_notification_opt_in: "yes",
          state_of_residence: "CA",
          preferred_interview_language: "en",
          primary_ssn: "123456789",
          primary_tin_type: "ssn",
          signature_method: "online",
          cv_p2_notes_comments: nil,
          balance_pay_from_bank: "unfilled",
          payment_in_installments: "unfilled"
  }
  let!(:client) { Hub::ClientsController::HubClientPresenter.new(create :client, intake: intake) }
  let(:base_form_attributes) do
    {
      primary_first_name: "John",
      primary_last_name: "Doe"
    }
  end

  describe "#save" do
    context "when balance_pay_from_bank is 'bank'" do
      let(:form_attributes) do
        base_form_attributes.merge(balance_pay_from_bank: "bank")
      end

      it "sets balance_pay_from_bank to 'yes' and payment_in_installments to 'no'" do
        form = described_class.new(client, form_attributes)
        expect(form).to be_valid
        result = form.save
        expect(result).to be true
        intake.reload

        expect(intake.balance_pay_from_bank).to eq "yes"
        expect(intake.payment_in_installments).to eq "no"
      end
    end

    context "when balance_pay_from_bank is 'mail'" do
      let(:form_attributes) do
        base_form_attributes.merge(balance_pay_from_bank: "mail")
      end

      it "sets balance_pay_from_bank to 'no' and payment_in_installments to 'no'" do
        form = described_class.new(client, form_attributes)
        expect(form).to be_valid
        result = form.save
        expect(result).to be true
        intake.reload

        expect(intake.balance_pay_from_bank).to eq "no"
        expect(intake.payment_in_installments).to eq "no"
      end
    end

    context "when balance_pay_from_bank is 'installments'" do
      let(:form_attributes) do
        base_form_attributes.merge(balance_pay_from_bank: "installments")
      end

      it "sets balance_pay_from_bank to 'unfilled' and payment_in_installments to 'yes'" do
        form = described_class.new(client, form_attributes)
        expect(form).to be_valid
        result = form.save
        expect(result).to be true
        intake.reload

        expect(intake.balance_pay_from_bank).to eq "unfilled"
        expect(intake.payment_in_installments).to eq "yes"
      end
    end
  end

  describe ".existing_attributes" do
    context "when intake has not been answered yet" do
      let(:intake) {
        build :intake,
              balance_pay_from_bank: "unfilled",
              payment_in_installments: "unfilled"
      }

      it "returns balance_pay_from_bank as 'unfilled'" do
        result = described_class.existing_attributes(intake)
        expect(result[:balance_pay_from_bank]).to eq "unfilled"
      end
    end

    context "when intake has been answered" do
      context "with bank payment (balance_pay_from_bank: 'yes', payment_in_installments: 'no')" do
        let(:intake) {
          build :intake,
                balance_pay_from_bank: "yes",
                payment_in_installments: "no"
        }

        it "returns balance_pay_from_bank as 'bank'" do
          result = described_class.existing_attributes(intake)
          expect(result[:balance_pay_from_bank]).to eq "bank"
        end
      end

      context "with mail payment (balance_pay_from_bank: 'no', payment_in_installments: 'no')" do
        let(:intake) {
          build :intake,
                balance_pay_from_bank: "no",
                payment_in_installments: "no"
        }

        it "returns balance_pay_from_bank as 'mail'" do
          result = described_class.existing_attributes(intake)
          expect(result[:balance_pay_from_bank]).to eq "mail"
        end
      end

      context "with installments (balance_pay_from_bank: 'unfilled', payment_in_installments: 'yes')" do
        let(:intake) {
          build :intake,
                balance_pay_from_bank: "unfilled",
                payment_in_installments: "yes"
        }

        it "returns balance_pay_from_bank as 'installments'" do
          result = described_class.existing_attributes(intake)
          expect(result[:balance_pay_from_bank]).to eq "installments"
        end
      end
    end
  end
end
