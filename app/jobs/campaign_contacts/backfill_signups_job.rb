module CampaignContacts
  class BackfillSignupsJob < ApplicationJob
    queue_as :backfills

    def perform(min_id, max_id, start_date, end_date)
      window_start = start_date.to_date.beginning_of_day
      window_end   = end_date.to_date.end_of_day

      Signup.where(created_at: window_start..window_end)
            .where(id: min_id..max_id)
            .find_each(batch_size: 1_000) do |signup|
        UpsertSourceIntoCampaignContacts.call(
          source: :signup,
          source_id: signup.id,
          first_name: signup.name,
          last_name: nil,
          email: signup.email_address,
          phone: signup.phone_number,
          email_opt_in: signup.email_address.present?,
          sms_opt_in: signup.phone_number.present?,
          locale: nil
        )
      end
    end

    def priority
      PRIORITY_LOW
    end
  end
end
