require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  scenario "a new client files through My Free Taxes", js: true do
    allow(MixpanelService).to receive(:send_event)

    visit "/questions/welcome"
    click_on "File taxes myself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Continue through MyFreeTaxes"
    expect(current_url).to eq("https://www.myfreetaxes.com/?utm_source=GYR&utm_medum=web&utm_campaign=Partner-referral")

    expect(MixpanelService).to have_received(:send_event).with(hash_including({event_name: "click_mft-diy-referral"}))
  end
end
