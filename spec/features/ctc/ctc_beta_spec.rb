require "rails_helper"

def begin_intake
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
  click_on I18n.t('general.continue')

  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.main_home.title', current_tax_year: current_tax_year))
  choose I18n.t('views.ctc.questions.main_home.options.military_facility')
  click_on I18n.t('general.continue')

  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filing_status.title',current_tax_year: current_tax_year))
  click_on I18n.t('general.affirmative')

  within "h1" do
    expect(page.source).to include(I18n.t('views.ctc.questions.income.title.other', current_tax_year: current_tax_year))
  end
  click_on I18n.t('general.continue')

  expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title_eitc"))
  click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.claim_eitc.title'))
  click_on I18n.t('views.ctc.questions.claim_eitc.buttons.dont_claim')
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.restrictions.title'))
  click_on I18n.t('general.continue')

  # =========== ELIGIBILITY ===========
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.already_filed.title', current_tax_year: current_tax_year))
  click_on I18n.t('general.negative')

  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations.title', current_tax_year: current_tax_year))
  click_on I18n.t('general.negative')
end

RSpec.feature "CTC Beta intake", :flow_explorer_screenshot, active_job: true, requires_default_vita_partners: true do
  around do |example|
    freeze_time do
      example.run
    end
  end

  let(:past) { 1.minute.ago }
  let(:future) { Time.now + 110.minute }
  before do
    allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_intake?).and_call_original
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow(Rails.application.config).to receive(:ctc_end_of_login).and_return(future)

    allow(Rails.application.config).to receive(:ctc_soft_launch).and_return(past)
    allow(Rails.application.config).to receive(:ctc_full_launch).and_return(future)
    Capybara.current_session.reset!
  end

  context "without locale path prefix" do
    context "with beta param" do
      context "with source param" do
        it "shows intake in English and stores the source param" do
          visit "/partner_source?ctc_beta=1"
          # =========== BASIC INFO ===========
          expect(page.current_path).to eq("/en")
          expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
          within ".ctc-home" do
            click_on(I18n.t("views.ctc_pages.home.get_started"))
          end
          begin_intake
          expect(Intake.last.source).to eq("partner_source")
        end
      end

      context "without source param" do
        it "shows homepage with get started link and stores nil source" do
          visit "/?ctc_beta=1"
          # =========== BASIC INFO ===========
          expect(page.current_path).to eq("/en")
          expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
          within ".ctc-home" do
            click_on(I18n.t("views.ctc_pages.home.get_started"))
          end
          begin_intake
          expect(Intake.last.source).to be_nil
        end
      end
    end

    context "without beta param" do
      context "with source param" do
        it "doesnt show the get started button" do
          visit "/partner_source"
          expect(page.current_path).to eq("/en")
          expect(page).not_to have_selector("a", text: I18n.t("views.ctc_pages.home.get_started"))
        end
      end

      context "without source param" do
        it "doesn't show intake" do
          visit "/"
          expect(page.current_path).to eq("/en")
          expect(page).not_to have_selector("a", text: I18n.t("views.ctc_pages.home.get_started"))
        end
      end
    end
  end

  context "with Spanish locale prefix" do
    it "shows get started button in spanish" do
      visit "/es/partner_source?ctc_beta=1"
      # =========== BASIC INFO ===========
      expect(page.current_path).to eq("/es")
      within ".ctc-home" do
        expect(page).to have_selector("a", text: I18n.t('views.ctc_pages.home.get_started', locale: :es))
      end
    end

    context "ctc beta param with garbage value" do
      it "does not show the get started button" do
        visit "/es/partner_source?ctc_beta=something"
        # =========== BASIC INFO ===========
        expect(page.current_path).to eq("/es")
        expect(page).not_to have_selector("a", text: I18n.t('views.ctc_pages.home.get_started', locale: :es))
      end
    end
  end
end
