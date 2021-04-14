require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  let(:fake_taxslayer_link) { "http://example.com/fake-taxslayer" }

  before do
    allow(EnvironmentCredentials).to receive(:dig).with(:tax_slayer_link).and_return fake_taxslayer_link
  end

  scenario "a new client files through TaxSlayer" do
    allow(MixpanelService).to receive(:send_event)

    visit "/diy/file-yourself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "To access this site, please provide your e-mail address.")
    fill_in "E-mail address", with: "example@example.com"
    fill_in "Confirm e-mail address", with: "example@example.com"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "File taxes on your own!")
    # should have the button that links to tax slayer and tracks clicks in mixpanel
    expect(page).to have_selector(
                      "a.button[href=\"#{fake_taxslayer_link}\"][data-track-click=\"diy-cfa-taxslayer-link\"]",
                      text: "Continue to TaxSlayer")
    # should show a telephone link to call 211 direct line for TaxSlayer help
    expect(page).to have_selector("a[href=\"tel:+18666989435\"][data-track-click=\"call-211-hotline\"]")
  end
end
