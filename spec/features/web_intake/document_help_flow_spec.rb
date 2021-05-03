require "rails_helper"

RSpec.feature "Document Help Flow", active_job: true do
  let(:client) do
    create :client,
           intake: (create :intake, bought_health_insurance: "yes", sms_notifications_opt_in: "yes", sms_phone_number: "+15105551234")
  end
  before do
    login_as client, scope: :client
  end

  scenario "getting through documents flow with help pages" do
    visit "documents/ids"
    expect(page).to have_text "Attach a photo of your ID card"

    click_on "I don't have this right now"
    expect(page).to have_text "We know documents can be hard to collect! Let us know how we can help"
    expect do
      click_on "Send a reminder link for this document"
    end.to change(OutgoingTextMessage, :count).by(1)
    expect(page).to have_text "Great! We just sent you a reminder link."
    expect(page).to have_text "Confirm your identity with a photo of yourself holding your ID card"
    click_on "Submit a photo"
    expect(page).to have_text "Share a photo of yourself holding your ID card"

    click_on "I don't have this right now"
    expect(page).to have_text "We know documents can be hard to collect! Let us know how we can help"
    expect do
      click_on "I need help finding this document"
    end.to change(SystemNote, :count).by(1)
    expect(page).to have_text "Thank you! We updated your tax specialist."
    expect(page).to have_text "Attach photos of Social Security Card or ITIN"
    click_on "I don't have this right now"
    expect do
      click_on "I can't get this document"
    end.to change(SystemNote, :count).by(1)
    expect(page).to have_text "Thank you! We updated your tax specialist."
    expect(page).to have_text "Now, let's collect your tax documents!"
    click_on "Continue"
    expect(page).to have_text "Attach your 1095-A's"
    click_on "I don't have this right now"
    expect(page).to have_text "We know documents can be hard to collect! Let us know how we can help"
    expect do
      click_on "This document doesn't apply to me"
    end.to change(SystemNote, :count).by(1)
  end
end