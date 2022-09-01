require "rails_helper"

RSpec.describe "Uploading a CSV for bulk client messaging", active_job: true do
  let(:user) { create :admin_user, name: "Admin the First" }
  let!(:email_and_phone_client) { create :client_with_intake_and_return, tax_return_state: "prep_info_requested" }
  let!(:email_client) { create :client_with_intake_and_return, tax_return_state: "intake_reviewing" }
  before do
    login_as user
    email_client.intake.update(preferred_name: "Nombre", locale: "es", email_notification_opt_in: "yes", email_address: "someone@example.com")
    email_and_phone_client.intake.update(preferred_name: "Name", locale: "es", sms_notification_opt_in: "yes", sms_phone_number: "+15005550006", email_notification_opt_in: "yes", email_address: "someone_else@example.com")
  end

  around do |example|
    @filename = Rails.root.join("tmp", "bulk-client-message-test-#{SecureRandom.hex}.csv")
    File.write(@filename, "client_id\n#{email_and_phone_client.id}\n#{email_client.id}"
    example.run
    File.unlink(@filename)
  end

  scenario "bulk messaging clients by CSV" do
    visit hub_bulk_message_csvs_path

    attach_file "Select file", @filename
    click_on "Upload"

    expect(page).to have_content(File.basename(@filename))
    expect(page).to have_content "Queued"

    perform_enqueued_jobs
    visit current_path
    expect(page).to have_content "Completed"

    click_on I18n.t("hub.bulk_message_csvs.bulk_message_csv.send_email")
    expect(page).to have_text "You’ve selected Send a Message for 2 clients (only sending email)"
    fill_in "Send message (Spanish)", with: "Naranja es la mejor"
    fill_in "Add an internal note", with: "Bulk message!"
    click_on "Submit"

    perform_enqueued_jobs
    visit current_path
    expect(page).to have_text "We are still contacting 2 clients."
    within ".total" do
      expect(page).to have_text I18n.t("hub.bulk_actions.send_a_message.edit.selected_action_qualifier.only_email")
    end
    perform_enqueued_jobs # to finish sending

    within ".in-progress" do
      click_on "2 clients"
    end
    click_on "Nombre"
    click_on "Messages"
    expect(page).to have_text "Naranja es la mejor"

    expect(OutgoingEmail.pluck(:to)).to match_array([email_client.email_address, email_and_phone_client.email_address])
    expect(OutgoingTextMessage.all).to match_array([])
  end
end
