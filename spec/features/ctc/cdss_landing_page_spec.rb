require "rails_helper"

RSpec.feature "Active choice landing page" do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  it "redirects home " do
    visit "/california-benefits"

    expect(page).to have_text I18n.t("views.ctc_pages.home.title")
  end
end
