require "rails_helper"

RSpec.feature "Visit home page" do
  scenario "has most critical content", js: true, screenshot: true do
    visit "/"

    screenshot_after do
      within(".main-header") do
        expect(page).to have_link("GetYourRefund", href: root_path)
      end
      expect(page).to have_text "Free tax filing"
      within ".slab--hero" do
        expect(page).to have_link I18n.t('general.get_started')
      end
    end

    within ".slab--hero" do
      click_on I18n.t('general.get_started')
    end
    expect(page).to have_text I18n.t('views.questions.welcome.title')
  end

  context "shows the correct date-dependent banners" do
    let(:current_time) { nil }

    around do |example|
      Timecop.freeze(current_time)
      example.run
      Timecop.return
    end

    before do
      allow(Rails.configuration).to receive(:start_of_open_intake).and_return(DateTime.new(2023, 1, 31))
      allow(Rails.configuration).to receive(:tax_deadline).and_return(DateTime.new(2023, 4, 18))
      allow(Rails.configuration).to receive(:end_of_intake).and_return(DateTime.new(2023, 10, 1))
      allow(Rails.configuration).to receive(:end_of_login).and_return(DateTime.new(2023, 10, 15))
    end

    context "when closed for new intakes" do
      let(:current_time) { DateTime.new(2023, 10, 2) }

      scenario "shows the closed banner" do
        visit "/"

        expect(page).to have_text "GetYourRefund will reopen January 31."
        expect(page.all(:css, '.slab--banner').length).to eq 1
      end
    end

    context "when open for filing and before the tax deadline" do
      let(:current_time) { DateTime.new(2023, 4, 1) }

      scenario "shows the document deadline banner" do
        visit "/"

        expect(page).to have_text "Reminder: You must submit your documents by April 4 in order to meet the federal income tax filing deadline of April 18. You can submit your taxes after the deadline without penalty if you don’t owe. If you aren’t sure whether or not you will owe, you can complete and mail this IRS form requesting an extension."
        expect(page.all(:css, '.slab--banner').length).to eq 1
      end
    end

    context "when open for filing and after the deadline" do
      let(:current_time) { DateTime.new(2023, 4, 20) }

      scenario "shows the banner with closing date and document submission deadline" do
        visit "/"

        expect(page).to have_text "Get started with GetYourRefund by October 1st if you want to file with us in 2023. If your return is in progress, log in and submit your documents by October 8th."
        expect(page.all(:css, '.slab--banner').length).to eq 1
      end

      scenario "shows the banner with closing date and document submission deadline with correctly formatted spanish dates" do
        visit "/es"

        expect(page).to have_text "Comience con GetYourRefund antes del 1 de octubre si desea presentar su declaración con nosotros en 2023. Si su declaración está en curso, inicie sesión y envíe sus documentos antes del 8 de octubre."
      end
    end
  end

  scenario "it has the correct SEO link tags in English" do
    visit "/en?source=test"
    # We are currently viewing the English homepage so the canonical URL is the English version.
    # Params should be ignored since the content is always the same.
    expect(page).to have_css 'link[rel="canonical"][href="http://www.example.com/en"]', :visible => false
    # The x-default language alternate is our default locale English
    expect(page).to have_css 'link[rel="alternate"][hreflang="x-default"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="en"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="es"][href="http://www.example.com/es"]', :visible => false
  end

  scenario "it has the correct SEO link tags in Spanish" do
    visit "/es?source=test"
    # We are currently viewing the Spanish homepage so the canonical URL is the Spanish version, with locale included
    # Params should be ignored since the content is always the same.
    expect(page).to have_css 'link[rel="canonical"][href="http://www.example.com/es"]', :visible => false
    # The x-default language alternate is our default locale English
    expect(page).to have_css 'link[rel="alternate"][hreflang="x-default"][href="http://www.example.com/en"]', :visible => false
    expect(page).to have_css 'link[rel="alternate"][hreflang="en"][href="http://www.example.com/en"]', :visible => false
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
