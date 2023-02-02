require "rails_helper"

RSpec.feature "Visit CTC home page" do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/"
    expect(page).to have_text I18n.t("views.ctc_pages.home.title")
  end

  it "the first tab goes to the skip main content link and the link takes you to maincontent", js: true do
    visit "/"
    find('body').send_keys :tab
    expect(page.driver.browser.switch_to.active_element.attribute('id')).to eq("skip-content-link")
    find('#skip-content-link').send_keys :enter, :tab
    expect(page.driver.browser.switch_to.active_element.attribute('id')).to eq("firstCta")
  end


  context "when the DIY link is disabled" do
    before do
      ENV['CTC_HIDE_DIY_LINK'] = 'true'
    end

    after do
      ENV.delete('CTC_HIDE_DIY_LINK')
    end

    it "doesn't show the DIY link" do
      visit "/"
      expect(page).to have_text I18n.t("views.ctc_pages.home.title")
      expect(page).not_to have_text I18n.t("views.ctc_pages.home.obtain.full_return.gyr_diy_link")
    end
  end

  context "when open for intake" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_intake?).and_return true
    end

    it "shows the button to file a simplified return" do
      visit "/"
      expect(page).to have_text I18n.t("views.ctc_pages.home.title")
      expect(page).not_to have_text I18n.t("views.ctc_pages.home.subheader.launching_soon_html")
      expect(page).to have_text I18n.t("views.ctc_pages.home.subheader.claim.eitc_on")

      expect(page).to have_text I18n.t("views.ctc_pages.home.get_started")
    end
  end
end
