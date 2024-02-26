require "rails_helper"

RSpec.describe UpdateGyrIntakeSmsOptionsJob, type: :job do
  let!(:intake_too_early) { create :intake, created_at: DateTime.new(2023, 10, 4) }
  let!(:intake_too_late) { create :intake, created_at: DateTime.new(2024, 2, 18) }
  let!(:intake_already_opted_in) { create :intake, created_at: DateTime.new(2024, 2, 2), sms_notification_opt_in: "yes" }
  let!(:intake_in_terminal_state) { create :intake, created_at: DateTime.new(2024, 2, 2) }
  let!(:intake_no_phone_number) { create :intake, created_at: DateTime.new(2024, 2, 2), phone_number: nil }
  let!(:intake_needs_phone_and_opt_in) { create :intake, created_at: DateTime.new(2024, 2, 2), sms_notification_opt_in: "unfilled", phone_number: "+14155537865", sms_phone_number: nil }
  let!(:intake_needs_opt_in_only) { create :intake, created_at: DateTime.new(2024, 2, 2), sms_notification_opt_in: "unfilled", phone_number: "+14155537865", sms_phone_number: "+14155537844" }

  before do
    [intake_too_early, intake_too_late, intake_already_opted_in, intake_no_phone_number, intake_needs_phone_and_opt_in, intake_needs_opt_in_only].each do |intake|
      create :tax_return, :intake_in_progress, year: 2023, client: intake.client
    end
    tax_return = create(:tax_return, year: 2023, client: intake_in_terminal_state.client)
    tax_return.transition_to!(:file_accepted)
  end

  context "when condition" do
    it "updates the right records" do
      expect do
        described_class.perform_now
        intake_needs_phone_and_opt_in.reload
        intake_needs_opt_in_only.reload
      end.to change(intake_needs_phone_and_opt_in, :sms_notification_opt_in)
               .from("unfilled").to("yes")
               .and change(intake_needs_opt_in_only, :sms_notification_opt_in)
                      .from("unfilled").to("yes")
                      .and change(intake_needs_phone_and_opt_in, :sms_phone_number)
                             .from(nil).to("+14155537865")
                             .and not_change(intake_needs_opt_in_only, :sms_phone_number)

      expect(intake_too_early).to eq intake_too_early.reload
      expect(intake_too_late).to eq intake_too_late.reload
      expect(intake_already_opted_in).to eq intake_already_opted_in.reload
      expect(intake_in_terminal_state).to eq intake_in_terminal_state.reload
      expect(intake_no_phone_number).to eq intake_no_phone_number.reload
    end
  end
end