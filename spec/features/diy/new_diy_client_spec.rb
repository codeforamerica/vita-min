require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  let(:fake_taxslayer_link) { "http://example.com/fake-taxslayer" }

  before do
    @test_environment_credentials.merge!(tax_slayer_link: fake_taxslayer_link)
  end

  scenario "a new client files through TaxSlayer" do
    allow(MixpanelService).to receive(:send_event)
    visit "/diy"
    expect(page).to have_selector("h1", text: I18n.t('views.public_pages.diy_home.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.file_yourself.edit.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.diy_intakes.new.title'))
    fill_in I18n.t("views.questions.email_address.email_address"), with: "example@example.com"
    fill_in I18n.t("views.questions.email_address.email_address_confirmation"), with: "example@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.tax_slayer.show.title'))
    # should have the button that links to tax slayer and tracks clicks in mixpanel
    expect(page).to have_selector(
                      "a.button[href=\"#{fake_taxslayer_link}\"][data-track-click=\"diy-cfa-taxslayer-link\"]",
                      text: I18n.t('diy.tax_slayer.show.continue_to_tax_slayer'))
  end
end
