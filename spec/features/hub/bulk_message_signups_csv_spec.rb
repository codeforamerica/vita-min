require "rails_helper"

RSpec.describe "Uploading a CSV for bulk messaging of signups", active_job: true do
  let(:user) { create :admin_user, name: "Admin the First" }
  let!(:gyr_email_and_phone_signup) { create :signup }
  let!(:ctc_email_and_phone_signup) { create :ctc_signup }

  before do
    login_as user
  end

  around do |example|
    @filename = Rails.root.join("tmp", "bulk-signups-message-test-#{SecureRandom.hex}.csv")
    File.write(@filename, <<~CSV)
      id
      #{gyr_email_and_phone_signup.id}
    CSV
    example.run
    File.unlink(@filename)
  end

  scenario "bulk messaging signups by CSV" do
    visit hub_signup_selections_path

    attach_file "Select file", @filename
    choose 'GYR'
    click_on "Upload"

    expect(page).to have_content(File.basename(@filename))

    click_on I18n.t("hub.bulk_message_csvs.bulk_message_csv.send_email")
    expect(page).to have_text "Sending email to 1 signup record(s)"
    fill_in "Message", with: "Naranja es la mejor"
    fill_in "Subject", with: "my great email subject"
    click_on "Submit"

    perform_enqueued_jobs
    visit current_path
    expect(page).to have_text "Contacting 1 signups over email (1 pending, 0 failed, 0 succeeded)"
    perform_enqueued_jobs # to finish sending

    OutgoingMessageStatus.last.update(delivery_status: 'delivered') # pretend we got a webhook status update from mailgun
    visit current_path
    expect(page).to have_text "Done contacting 1 signups over email (0 failed, 1 succeeded)"

    expect(OutgoingMessageStatus.count).to eq 1
    expect(OutgoingMessageStatus.last.parent.email_address).to eq(gyr_email_and_phone_signup.email_address)
    expect(BulkSignupMessage.last.subject).to eq 'my great email subject'

    click_on I18n.t("hub.bulk_message_csvs.bulk_message_csv.send_text")
    expect(page).to have_text "Sending sms to 1 signup record(s)"
    fill_in "Message", with: "Naranja es la mejor"
    click_on "Submit"

    perform_enqueued_jobs
    visit current_path
    expect(page).to have_text "Contacting 1 signups over sms (1 pending, 0 failed, 0 succeeded)"
    perform_enqueued_jobs # to finish sending

    OutgoingMessageStatus.last.update(delivery_status: 'sent') # pretend we got a webhook status update from twilio
    visit current_path
    expect(page).to have_text "Done contacting 1 signups over sms (0 failed, 1 succeeded)"

    expect(OutgoingMessageStatus.count).to eq 2
    expect(OutgoingMessageStatus.last.parent.phone_number).to eq(gyr_email_and_phone_signup.phone_number)
  end
end

