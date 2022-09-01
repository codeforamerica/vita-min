require "rails_helper"

RSpec.describe "Uploading a CSV for bulk client messaging", active_job: true do
  let(:user) { create :admin_user, name: "Admin the First" }
  let!(:client_es) { create :client_with_intake_and_return, tax_return_state: "prep_info_requested" }
  let!(:client_en) { create :client_with_intake_and_return, tax_return_state: "intake_reviewing" }
  before do
    login_as user
    client_es.intake.update(preferred_name: "Nombre", locale: "es", email_notification_opt_in: "yes", email_address: "someone@example.com")
    client_en.intake.update(preferred_name: "Name", locale: "en", sms_notification_opt_in: "yes", sms_phone_number: "+15005550006")
  end

  around do |example|
    @filename = Rails.root.join("tmp", "bulk-client-message-test-#{SecureRandom.hex}.csv")
    example.run
    File.unlink(@filename)
  end

  scenario "bulk messaging clients by CSV" do
    File.write(@filename, "client_id\n#{client_es.id}\n#{client_en.id}")
    visit hub_bulk_message_csvs_path

    attach_file "Select file", @filename
    click_on "Upload"

    expect(page).to have_content(File.basename(@filename))
  end
end
