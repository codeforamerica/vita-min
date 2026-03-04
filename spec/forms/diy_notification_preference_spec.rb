require "rails_helper"

RSpec.describe DiyNotificationPreferenceForm do
  let(:diy_intake) { create :diy_intake, email_address: "test@test.test" }

  context "opted into sms" do
    it "is valid" do
      form = DiyNotificationPreferenceForm.new(
        diy_intake,
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
      form = DiyNotificationPreferenceForm.new(
        diy_intake,
        {
          sms_notification_opt_in: "no",
          email_notification_opt_in: "yes",
        }
      )

      expect(form).to be_valid
    end
  end

  context "opted into neither" do
    it "is still valid" do
      form = DiyNotificationPreferenceForm.new(
        diy_intake,
        {
          sms_notification_opt_in: "no",
          email_notification_opt_in: "no",
        }
      )

      expect(form).to be_valid
    end
  end
end
