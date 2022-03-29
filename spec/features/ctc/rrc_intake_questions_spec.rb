require "rails_helper"

RSpec.describe "CTC Intake", :flow_explorer_screenshot_i18n_friendly, active_job: true do
  let(:client) { create :client, intake: create(:ctc_intake, primary_active_armed_forces: "yes"), tax_returns: [create(:tax_return, year: 2021)] }
  let(:calculated_third_stimulus) { 2800 }
  let(:third_stimulus_string) { "$2,800"}

  before do
    login_as client, scope: :client
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(calculated_third_stimulus)
  end

  scenario "when the client says they received the amounts calculated on /stimulus-payments, we direct them to /stimulus-received and display the calculated amounts" do
    visit "/questions/stimulus-payments"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: third_stimulus_string))
    click_on I18n.t('views.ctc.questions.stimulus_payments.this_amount')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_received.title'))
    click_on I18n.t('general.continue')
  end

  context "when the client says they received a different amount than the one shown on on /stimulus-payments" do
    scenario "when the client's provided amounts are less than the calculated amount, we direct them to /stimulus-owed" do
      visit "/questions/stimulus-payments"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: third_stimulus_string))
      click_on I18n.t('views.ctc.questions.stimulus_payments.different_amount')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_three.title'))
      fill_in I18n.t('views.ctc.questions.stimulus_three.how_much'), with: "1800"
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_owed.title'))
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    end

    scenario "when the client's provided amount is greater than the calculated amount, we direct them to /stimulus-received" do
      visit "/questions/stimulus-payments"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: third_stimulus_string))
      click_on I18n.t('views.ctc.questions.stimulus_payments.different_amount')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_three.title'))
      fill_in I18n.t('views.ctc.questions.stimulus_three.how_much'), with: "3800"
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_received.title'))
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    end
  end

  scenario "when the client says they did not receive any amount, we direct them to /stimulus-owed" do
    visit "en/questions/stimulus-payments"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title', third_stimulus_amount: third_stimulus_string))
    click_on I18n.t('views.ctc.questions.stimulus_payments.no_amount')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_owed.title'))
    click_on I18n.t('general.continue')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
  end
end
