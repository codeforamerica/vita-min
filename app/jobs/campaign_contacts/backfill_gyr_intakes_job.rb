module CampaignContacts
  class BackfillGyrIntakesJob < ApplicationJob
    queue_as :backfills

    def perform(min_id, max_id, start_date, end_date)
      window_start = start_date.to_date.beginning_of_day
      window_end = end_date.to_date.end_of_day

      Intake::GyrIntake.contactable
                       .where(created_at: window_start..window_end)
                       .where(id: min_id..max_id)
                       .find_each(batch_size: 1000) do |intake|
        UpsertSourceIntoCampaignContacts.call(
          source: :gyr,
          source_id: intake.id,
          first_name: intake.primary_first_name,
          last_name: intake.primary_last_name,
          email: intake.email_address,
          phone: intake.sms_phone_number,
          email_opt_in: intake.email_notification_opt_in == "yes",
          sms_opt_in: intake.sms_notification_opt_in == "yes",
          locale: intake.locale
        )
      end
    end

    def priority
      PRIORITY_LOW
    end
  end
end
