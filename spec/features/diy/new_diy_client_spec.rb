require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  let(:fake_taxslayer_link) { "http://example.com/fake-taxslayer" }

  before do
    @test_environment_credentials.merge!(tax_slayer_link: fake_taxslayer_link)
  end

  scenario "a new client files through TaxSlayer" do
    allow(MixpanelService).to receive(:send_event)
    visit "/diy"
    expect(page).to have_selector("h1", text: "File taxes on your own for free!")
    expect(page).to have_selector("p", text: "We provide free access to an online tax prep site called TaxSlayer. We'll send you a link to create your own TaxSlayer login, so you can file on your own.")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "To access this site, please provide your e-mail address.")
    fill_in "Email address", with: "example@example.com"
    fill_in "Confirm email address", with: "example@example.com"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "File taxes on your own!")
    # should have the button that links to tax slayer and tracks clicks in mixpanel
    expect(page).to have_selector(
                      "a.button[href=\"#{fake_taxslayer_link}\"][data-track-click=\"diy-cfa-taxslayer-link\"]",
                      text: "Continue to TaxSlayer")
  end
end
