class UpdateGyrIntakeSmsOptionsJob < ApplicationJob
  def perform
    start_time = DateTime.new(2024, 1, 1)
    end_time = DateTime.new(2024, 2, 16, 16).in_time_zone("America/Los_Angeles")
    intakes = Intake::GyrIntake
                .includes(:tax_returns)
                .where("intakes.created_at > ?", start_time)
                .where("intakes.created_at < ?", end_time)
                .where.not(intakes: { sms_notification_opt_in: "yes" })
                .where.not(tax_returns: { current_state: ["file_accepted", "file_not_filing", "file_mailed"] }) # excludes intakes with no tax returns
                .where.not(phone_number: nil)
    intakes.where(sms_phone_number: nil).in_batches.update_all("sms_phone_number=phone_number")
    intakes.in_batches.update_all(sms_notification_opt_in: "yes")
  end

  def priority
    PRIORITY_LOW
  end
end