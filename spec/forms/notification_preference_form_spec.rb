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
  end
end
