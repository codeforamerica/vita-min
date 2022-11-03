require "rails_helper"

RSpec.describe "Uploading a CSV for bulk messaging of signups", active_job: true do
  let(:user) { create :admin_user, name: "Admin the First" }

  before do
    login_as user
  end

  around do |example|
    @filename = Rails.root.join("tmp", "bulk-signups-message-test-#{SecureRandom.hex}.csv")
    File.write(@filename, <<~CSV)
      id TODO
      email_and_phone_client.id
    CSV
    example.run
    File.unlink(@filename)
  end

  scenario "bulk messaging clients by CSV" do
    visit hub_bulk_signup_messages_path

    attach_file "Select file", @filename
    click_on "Upload"

    expect(page).to have_content(File.basename(@filename))
    expect(page).to have_content "Queued"

    perform_enqueued_jobs
    visit current_path
    expect(page).to have_content "Ready"

    click_on I18n.t("hub.bulk_message_csvs.bulk_message_csv.send_email")
    expect(page).to have_text "Send a Message for 3 signups (only sending email)"
    fill_in "Message", with: "Naranja es la mejor"
    click_on "Submit"

    perform_enqueued_jobs
    visit current_path
    expect(page).to have_text "We are still contacting 2 signups."
    within ".total" do
      expect(page).to have_text I18n.t("hub.bulk_actions.send_a_message.edit.selected_action_qualifier.only_email")
    end
    perform_enqueued_jobs # to finish sending

    expect(page).to have_text "Done contacting 2 signups."

    expect(OutgoingMessageStatus.pluck(:to)).to match_array([email_gyr_signup.email_address, email_ctc_signup.email_address])
  end
end
