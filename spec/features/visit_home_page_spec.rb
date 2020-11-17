require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "has most critical content" do
    visit "/"
    expect(page).to have_text "Free tax filing, real human support."
    expect(page).to have_text "Sign up for next tax season now. We’ll notify you as soon as our service is back up in January!"
    expect(page).to have_link "Sign Up"
    click_on "Sign Up"
    expect(page).to have_text "sign up here"
  end

  scenario "it has the correct SEO link tags in English" do
    visit "/?new_locale=en"
    # We are currently viewing the English homepage so the canonical URL is the English version, with no locale
    # because English is the default
    #
    # Note: url_for appends a trailing slash by default to the root URL only, and this is ok because Google treats
    # root URLs as the same regardless of whether they have a trailing slash, unlike URLs with additional path
    # elements!
    #
    # i.e. https://www.getyourrefund.org == https://www.getyourrefund.org/ BUT https://www.getyourrefund.org/es != https://www.getyourrefund.org/es/
    expect(page).to have_css 'link[rel="canonical"][href="http://www.example.com/"]', :visible => false
    # The x-default language alternate does not include the locale, so it will match browser settings
    expect(page).to have_css 'link[rel="alternate"][hreflang="x-default"][href="http://www.example.com/"]', :visible => false
    # The English alternate includes the locale
    expect(page).to have_css 'link[rel="alternate"][hreflang="en"][href="http://www.example.com/en"]', :visible => false
    # The Spanish alternate includes the locale
    expect(page).to have_css 'link[rel="alternate"][hreflang="es"][href="http://www.example.com/es"]', :visible => false
  end

  scenario "it has the correct SEO link tags in Spanish" do
    visit "/?new_locale=es"
    # We are currently viewing the Spanish homepage so the canonical URL is the Spanish version, with locale included
    expect(page).to have_css 'link[rel="canonical"][href="http://www.example.com/es"]', :visible => false
    # The x-default language alternate does not include the locale, so it will match browser settings
    expect(page).to have_css 'link[rel="alternate"][hreflang="x-default"][href="http://www.example.com/"]', :visible => false
    # The English alternate includes the locale
    expect(page).to have_css 'link[rel="alternate"][hreflang="en"][href="http://www.example.com/en"]', :visible => false
    # The Spanish alternate includes the locale
    expect(page).to have_css 'link[rel="alternate"][hreflang="es"][href="http://www.example.com/es"]', :visible => false
  end

  context "in non-production environments" do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)
    end

    scenario "it shows a sign in link" do
      visit "/"
      click_on "Volunteer sign in"
      expect(page).to have_text "Sign in"
    end
  end
end
