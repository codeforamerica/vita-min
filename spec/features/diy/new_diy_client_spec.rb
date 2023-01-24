require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  scenario "a new client files through TaxSlayer", :flow_explorer_screenshot do
    allow(MixpanelService).to receive(:send_event)
    visit "/diy"
    expect(page).to have_selector("h1", text: I18n.t('views.public_pages.diy_home.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.file_yourself.edit.title'))
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.email.edit.title'))
    fill_in I18n.t("views.questions.email_address.email_address"), with: "example@example.com"
    fill_in I18n.t("views.questions.email_address.email_address_confirmation"), with: "example@example.com"
    click_on I18n.t('general.continue')

    expect(page).to have_selector("h1", text: I18n.t('diy.continue_to_fsa.edit.title'))
    expect(page).to have_text(I18n.t('diy.continue_to_fsa.edit.continue_to_tax_slayer'))
  end
end
