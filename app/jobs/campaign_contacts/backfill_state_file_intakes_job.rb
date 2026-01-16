module CampaignContacts
  class BackfillStateFileIntakesJob < BackfillSourceJob
    def perform(intake_class_name, min_id, max_id, start_date, end_date)
      window_start = start_date.to_date.beginning_of_day
      window_end = end_date.to_date.end_of_day
      klass = intake_class_name.constantize

      klass.contactable.where(created_at: window_start..window_end)
           .where(id: min_id..max_id).find_each(batch_size: 1_000) do |intake|

        email = normalize_email(intake.email_address)
        phone = normalize_phone_number(intake.phone_number)
        next if email.blank? && phone.blank?

        begin
          UpsertSourceIntoCampaignContacts.call(
            source: :state_file,
            source_id: intake.id,
            first_name: intake.primary_first_name,
            last_name: intake.primary_last_name,
            email: email,
            phone: phone,
            email_opt_in: intake.email_notification_opt_in == "yes",
            sms_opt_in: intake.sms_notification_opt_in == "yes",
            locale: intake.locale,
            state_file_ref: {
              id: intake.id,
              type: klass.name,
              state: intake.state_code,
              tax_year: intake.tax_return_year
            }
          )
        rescue => e
          Sentry.capture_exception(e, extra: { job: self.class.name, state_file_intake_id: intake.id, state: intake.state_code })
          next
        end
      end
    end
  end
end
