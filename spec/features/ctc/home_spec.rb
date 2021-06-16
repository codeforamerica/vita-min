require "rails_helper"

RSpec.feature "Visit CTC home page" do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/"
    expect(page).to have_text I18n.t("views.ctc_pages.home.header")
    expect(page).to have_text I18n.t("views.ctc_pages.home.obtain.full_return.gyr_diy_link")
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
      expect(page).to have_text I18n.t("views.ctc_pages.home.header")
      expect(page).not_to have_text I18n.t("views.ctc_pages.home.obtain.full_return.gyr_diy_link")
    end
  end
end
