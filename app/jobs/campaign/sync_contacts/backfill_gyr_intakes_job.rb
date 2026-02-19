module Campaign
  module SyncContacts
    class BackfillGyrIntakesJob < BackfillSourceJob
      def perform(min_id, max_id, start_date, end_date)
        window_start = start_date.to_date.beginning_of_day
        window_end = end_date.to_date.end_of_day

        Intake::GyrIntake.contactable
                         .where(created_at: window_start..window_end)
                         .where(id: min_id..max_id)
                         .find_each(batch_size: 1000) do |intake|

          email = normalize_email(intake.email_address)
          phone = normalize_phone_number(intake.sms_phone_number)
          next if email.blank? && phone.blank?
          begin
            Campaign::UpsertSourceIntoCampaignContacts.call(
              source: :gyr,
              source_id: intake.id,
              first_name: intake.primary_first_name,
              last_name: intake.primary_last_name,
              email: email,
              phone: phone,
              email_opt_in: intake.email_notification_opt_in == "yes",
              sms_opt_in: intake.sms_notification_opt_in == "yes",
              locale: intake.locale,
              latest_gyr_intake_at: intake.created_at
            )
          rescue => e
            Sentry.capture_exception(e, extra: { job: self.class.name, gyr_id: intake.id, })
            next
          end
        end
      end
    end
  end
end