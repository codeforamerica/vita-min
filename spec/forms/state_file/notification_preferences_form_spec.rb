require "rails_helper"

RSpec.describe StateFile::NotificationPreferencesForm do
  let!(:intake) { create :state_file_az_intake }

  describe "#valid?" do
    context "when sms_notification_opt_in is present" do
      let(:valid_params) do
        {
          sms_notification_opt_in: "yes",
          phone_number: "+14155551212"
        }
      end

      subject(:form) { described_class.new(intake, valid_params) }

      it "is valid" do
        expect(form).to be_valid
      end

      context "when phone number is not in e164 format" do
        let(:invalid_params) do
          {
            sms_notification_opt_in: "yes",
            phone_number: "415555121"
          }
        end
        subject(:form) { described_class.new(intake, invalid_params) }

        it "is invalid" do
          form.valid?
          expect(form).not_to be_valid
        end

        it "adds an error to the phone_number attribute" do
          form.valid?
          expect(form.errors[:phone_number]).to include "Please enter a valid phone number"
        end
      end
    end

    context "when sms_notification_opt_in is not present" do
      let(:invalid_params) do
        {
          email_notification_opt_in: "yes",
          phone_number: "415555121"
        }
      end
      subject(:form) { described_class.new(intake, invalid_params) }

      it "does not validate phone number" do
        form.valid?
        expect(form).to be_valid
      end

      it "updates the intake with the provided attributes" do
        expect { form.save }.to change(intake, :email_notification_opt_in).from("unfilled").to("yes")
      end
    end

    context "when neither are present" do
      let(:invalid_params) do
        {
          phone_number: "415555121",
          email_notification_opt_in: "no"
        }
      end
      subject(:form) { described_class.new(intake, invalid_params) }

      it 'is invalid' do
        form.valid?
        expect(form).not_to be_valid
      end
    end
  end
end
