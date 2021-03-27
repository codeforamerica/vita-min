require "rails_helper"

RSpec.describe NotificationPreferenceForm do
  let(:intake) { create :intake }

  describe "#validations" do
    describe "#need_one_communication_method" do
      context "opted into sms" do
        it "is valid" do
          form = NotificationPreferenceForm.new(
            intake,
            {
              sms_phone_number: "1 (415) 553-7865",
              sms_notification_opt_in: "yes",
              email_notification_opt_in: "no",
            }
          )

          expect(form).to be_valid
        end
      end

      context "opted into email" do
        it "is valid" do
          form = NotificationPreferenceForm.new(
            intake,
            {
              sms_notification_opt_in: "no",
              email_notification_opt_in: "yes",
            }
          )

          expect(form).to be_valid
        end
      end

      context "opted into neither" do
        it "is invalid and adds an error to sms_notification_opt_in" do
          form = NotificationPreferenceForm.new(
            intake,
            {
              sms_notification_opt_in: "no",
              email_notification_opt_in: "no",
            }
          )

          expect(form).not_to be_valid
          expect(form.errors[:sms_notification_opt_in]).to be_present
        end
      end
    end

    describe "#need_phone_number_for_sms_opt_in" do
      let(:form) do
        NotificationPreferenceForm.new(
          intake,
          {
            sms_notification_opt_in: sms_opt_in,
            email_notification_opt_in: email_opt_in,
            sms_phone_number: sms_phone_number
          }
        )
      end

      context "when opting into sms notifications" do
        let(:sms_opt_in) { "yes" }
        let(:email_opt_in) { "no" }

        context "when a phone number is given" do
          let(:sms_phone_number) { "500 555 0006" }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "when no phone number is given" do
          let(:sms_phone_number) { "" }

          it "is not valid and adds an error" do
            expect(form).not_to be_valid
            expect(form.errors).to include :sms_phone_number
          end
        end
      end

      context "when not opting into sms notifications" do
        let(:sms_opt_in) { "no" }
        let(:email_opt_in) { "yes" }

        context "when no phone number is given" do
          let(:sms_phone_number) { "" }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end
    end

    describe "#sms_phone_number" do
      let(:form) do
        NotificationPreferenceForm.new(
          intake,
          {
            sms_notification_opt_in: "yes",
            email_notification_opt_in: "no",
            sms_phone_number: sms_phone_number
          }
        )
      end

      context "with a valid e164 format phone number" do
        let(:sms_phone_number) { "+15005550006" }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "with a valid, casually written phone number" do
        let(:sms_phone_number) { "(500) 555-0006" }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "with an invalid phone number" do
        let(:sms_phone_number) { "5423234" }

        it "is not valid and adds one error" do
          expect(form).not_to be_valid
          expect(form.errors).to include :sms_phone_number
          expect(form.errors[:sms_phone_number].length).to eq 1
        end
      end
    end
  end
end
