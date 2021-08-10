require "rails_helper"

def begin_intake
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
  click_on I18n.t('general.continue')
  within "h1" do
    expect(page.source).to include(I18n.t('views.ctc.questions.income.title', tax_year: 2020))
  end
  click_on I18n.t('general.negative')

  expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.file_full_return.title"))
  click_on I18n.t("views.ctc.questions.file_full_return.simplified_btn")

  # =========== ELIGIBILITY ===========
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed2020.title'))
  click_on I18n.t('general.negative')
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.filed2019.title'))
  choose I18n.t('views.ctc.questions.filed2019.did_not_file')
  click_on "Continue"
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
  check I18n.t('views.ctc.questions.home.options.fifty_states')
  check I18n.t('views.ctc.questions.home.options.foreign_address')
  click_on I18n.t('general.continue')
  expect(page).to have_selector("h1", text:  I18n.t('views.ctc.questions.use_gyr.title'))
  click_on I18n.t('general.back')
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.home.title'))
  check I18n.t('views.ctc.questions.home.options.fifty_states')
  check I18n.t('views.ctc.questions.home.options.military_facility')
  click_on I18n.t('general.continue')
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.life_situations2020.title'))
  click_on I18n.t('general.negative')
end

RSpec.feature "CTC Beta intake", :flow_explorer_screenshot_i18n_friendly, active_job: true do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow(Rails.env).to receive(:production?).and_return(true)
  end

  context "without locale path prefix" do
    context "with beta param" do
      context "with source param" do
        it "shows intake in English and stores the source param" do
          visit "/partner_source?ctc_beta=1"
          # =========== BASIC INFO ===========
          expect(page.current_path).to eq("/en/questions/overview")
          expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
          expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
          begin_intake
          expect(Intake.last.source).to eq("partner_source")
        end
      end

      context "without source param" do
        it "shows intake in English and stores nil source" do
          visit "/?ctc_beta=1"
          # =========== BASIC INFO ===========
          expect(page.current_path).to eq("/en/questions/overview")
          expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
          expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
          begin_intake
          expect(Intake.last.source).to be_nil
        end
      end
    end

    context "without beta param" do
      context "with source param" do
        it "doesn't show intake" do
          visit "/partner_source"
          expect(page.current_path).to eq("/en")
          expect(page).not_to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
        end
      end

      context "without source param" do
        it "doesn't show intake" do
          visit "/"
          expect(page.current_path).to eq("/en")
          expect(page).not_to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title'))
        end
      end
    end
  end

  context "with Spanish locale prefix" do
    it "shows intake in spanish" do
      visit "/es/partner_source?ctc_beta=1"
      # =========== BASIC INFO ===========
      expect(page.current_path).to eq("/es/questions/overview")
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.overview.title', locale: :es))
    end
  end
end
