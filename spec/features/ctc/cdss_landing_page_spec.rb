require "rails_helper"

RSpec.feature "Active choice landing page" do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  it "has content" do
    visit "/california-benefits"

    expect(page).to have_text I18n.t("views.ctc_pages.california_benefits.title")
  end

  context "when using special source code links" do
    it "redirects to the /california-benefits page" do
      visit "/claim"

      expect(page).to have_text I18n.t("views.ctc_pages.california_benefits.title")
    end

    it "redirects to the /california-benefits page" do
      visit "/file"

      expect(page).to have_text I18n.t("views.ctc_pages.california_benefits.title")
    end
  end
end
