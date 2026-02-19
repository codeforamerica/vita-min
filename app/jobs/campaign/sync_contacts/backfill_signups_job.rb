module Campaign
  module SyncContacts
    class BackfillSignupsJob < BackfillSourceJob

      def perform(min_id, max_id, start_date, end_date)
        window_start = start_date.to_date.beginning_of_day
        window_end = end_date.to_date.end_of_day

        Signup.where(created_at: window_start..window_end).where(id: min_id..max_id)
              .find_each(batch_size: 1_000) do |signup|

          email = normalize_email(signup.email_address)
          phone = normalize_phone_number(signup.phone_number)
          next if email.blank? && phone.blank?

          begin
            Campaign::UpsertSourceIntoCampaignContacts.call(
              source: :signup,
              source_id: signup.id,
              first_name: signup.name,
              last_name: nil,
              email: email,
              phone: phone,
              email_opt_in: email.present?,
              sms_opt_in: phone.present?,
              locale: nil,
              latest_signup_at: signup.created_at
            )
          rescue => e
            Sentry.capture_exception(e, extra: { job: self.class.name, signup_id: signup.id, })
            next
          end
        end
      end
    end
  end
end
