namespace :send_campaign_messages do
  desc "Send GYR 2025 preseason emails"
  task preseason_emails: :environment do
    next if Rails.env.demo? || Rails.env.staging?
    next unless DateTime.now.year == 2026

    CampaignContacts::SendEmailsBatchJob.perform_later(
      "preseason_outreach",
      batch_size: 100,
      batch_delay: 30.seconds,
      queue_next_batch: true
    )
  end
end
