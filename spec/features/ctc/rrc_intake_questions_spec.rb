require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot, active_job: true do
  # TODO: after we have the RRC calculation based on dependents, set up some cases for routing to owed vs received
  let(:client) { create :client, intake: create(:ctc_intake, primary_active_armed_forces: "yes"), tax_returns: [create(:tax_return, year: 2020)] }

  before do
    login_as client, scope: :client
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  scenario "when the client says they received the amounts calculated on /stimulus-payments, we direct them to /stimulus-received and display the calculated amounts" do
    visit "/questions/stimulus-payments"
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
    click_on I18n.t('views.ctc.questions.stimulus_payments.yes_received')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_received.title'))
    expect(page).to have_text("EIP 1: $2,400")
    expect(page).to have_text("EIP 2: $1,200")

    # Ensure that backing up from /stimulus-received skips all the way back to /stimulus-payments in this case
    click_on I18n.t('general.back')
    expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
  end

  context "when the client says they did not receive the amounts calculated on /stimulus-payments" do
    scenario "when the client's provided amounts (sum) are less than the calculated amounts (sum), we direct them to /stimulus-owed" do
      visit "/questions/stimulus-payments"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
      click_on I18n.t('views.ctc.questions.stimulus_payments.no_did_not_receive')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one.title'))
      click_on I18n.t('general.affirmative')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one_received.title'))
      fill_in I18n.t('views.ctc.questions.stimulus_one_received.eip1_amount_received_label'), with: "1200"
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two.title'))
      click_on I18n.t('general.affirmative')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two_received.title'))
      fill_in I18n.t('views.ctc.questions.stimulus_two_received.eip2_amount_received_label'), with: "600"
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_owed.title'))
      expect(page).to have_text("EIP 1: $1,200")
      expect(page).to have_text("EIP 2: $600")
      expect(page).to have_selector('.stimulus-owed', text: "$1,800")
    end

    xscenario "when the client's provided amounts (sum) is greater than the calculated amounts (sum), we will do something as yet unknown" do; end

    scenario "when the client says they did not receive stimulus 1 or 2, it saves zero as that amount" do
      visit "en/questions/stimulus-payments"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_payments.title'))
      click_on I18n.t('views.ctc.questions.stimulus_payments.no_did_not_receive')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_one.title'))
      click_on I18n.t('general.negative')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.stimulus_two.title'))
      click_on I18n.t('general.negative')

      expect(page).to have_text("EIP 1: $0")
      expect(page).to have_text("EIP 2: $0")
    end
  end

  context "client ends up on /stimulus-owed" do
    before do
      client.intake.update(eip1_amount_received: 0, eip2_amount_received: 0)
    end

    scenario "when the client says they do want to claim the remaining stimulus money" do
      visit "/questions/stimulus-owed"
      click_on "Claim the additional money"
      expect(client.intake.reload.claim_owed_stimulus_money).to eq "yes"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    end

    scenario "when the client says they don't want to claim the remaining stimulus money" do
      visit "/questions/stimulus-owed"
      click_on "Don’t claim the additional money"
      expect(client.intake.reload.claim_owed_stimulus_money).to eq "no"
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
    end
  end
end
