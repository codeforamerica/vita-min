require "rails_helper"

RSpec.feature "Unsubscribing from email", active_job: true do
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    Flipper.enable :state_file_notification_emails
  end

  scenario "the link in the email unsubscribes the client" do
    visit "/"
    click_on "Start Test AZ"

    expect(page).to have_text I18n.t("state_file.landing_page.edit.az.title")
    click_on I18n.t('general.get_started'), id: "firstCta"

    step_through_eligibility_screener(us_state: "az")

    intake = StateFileAzIntake.last
    expect(intake.unsubscribed_from_email).to eq false

    step_through_initial_authentication(contact_preference: :email)

    check "Email"
    click_on I18n.t("general.continue")

    perform_enqueued_jobs
    email = ActionMailer::Base.deliveries.last

    html = Nokogiri::HTML(email.html_part.body.to_s)
    target_link = html.at("a:contains('here')")
    visit target_link["href"]

    expect(intake.reload.unsubscribed_from_email).to eq true

    click_on "Opt in again."

    expect(intake.reload.unsubscribed_from_email).to eq false
  end
end
