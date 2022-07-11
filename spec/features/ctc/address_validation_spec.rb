require "rails_helper"

RSpec.feature "CTC Intake", :flow_explorer_screenshot_i18n_friendly, active_job: true, requires_default_vita_partners: true, do_not_stub_usps: true do
  include CtcIntakeFeatureHelper
  
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    stub_request(:get, /.*secure\.shippingapis\.com.*/).to_return(status: 200, body: usps_api_response_body, headers: {})
  end

  context "showing an inline validation error" do
    let(:usps_api_response_body) { file_fixture("usps_address_validation_error_body__city.xml").read }

    scenario "client with invalid city error" do
      fill_in_can_use_ctc
      fill_in_eligibility
      fill_in_basic_info
      fill_in_spouse_info
      fill_in_dependents
      fill_in_advance_child_tax_credit
      fill_in_recovery_rebate_credit
      # =========== BANK AND MAILING INFO ===========
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
      choose I18n.t('views.questions.refund_payment.direct_deposit')
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.bank_account.title'))
      fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
      choose I18n.t('views.questions.bank_details.account_type.checking')
      check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')
      fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "123456789"
      fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "123456789"
      fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
      fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_bank_account.title'))
      expect(page).to have_selector("h2", text: I18n.t('views.ctc.questions.confirm_bank_account.bank_information'))
      expect(page).to have_selector("li", text: "Bank of Two Melons")
      expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
      expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 123456789")
      expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.account_number')}: ●●●●●6789")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      fill_in I18n.t('views.questions.mailing_address.street_address'), with: "26 William Street"
      fill_in I18n.t('views.questions.mailing_address.street_address2'), with: "Apt 1234"
      fill_in I18n.t('views.questions.mailing_address.city'), with: "Bel Air"
      select "California", from: I18n.t('views.questions.mailing_address.state')
      fill_in I18n.t('views.questions.mailing_address.zip_code'), with: 90001
      click_on I18n.t('general.continue')

      # see validation error
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      expect(page).to have_selector("#ctc_mailing_address_form_city__errors")
      expect(page).to have_text("Error: Invalid City")
    end
  end

  context "showing an error notice" do
    let(:usps_api_response_body) { file_fixture("usps_address_validation_error_body.xml").read }

    scenario "client with address not found error" do
      fill_in_can_use_ctc(filing_status: "single")
      fill_in_eligibility
      fill_in_basic_info
      fill_in_dependents(head_of_household: true)
      fill_in_advance_child_tax_credit
      fill_in_recovery_rebate_credit(third_stimulus_amount: "$2,800")
      # =========== BANK AND MAILING INFO ===========
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
      choose I18n.t('views.questions.refund_payment.direct_deposit')
      click_on I18n.t('general.continue')
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.portal.bank_account.title'))
      fill_in I18n.t('views.questions.bank_details.bank_name'), with: "Bank of Two Melons"
      choose I18n.t('views.questions.bank_details.account_type.checking')
      check I18n.t('views.ctc.questions.direct_deposit.my_bank_account.label')
      fill_in I18n.t('views.ctc.questions.routing_number.routing_number'), with: "123456789"
      fill_in I18n.t('views.ctc.questions.routing_number.routing_number_confirmation'), with: "123456789"
      fill_in I18n.t('views.ctc.questions.account_number.account_number'), with: "123456789"
      fill_in I18n.t('views.ctc.questions.account_number.account_number_confirmation'), with: "123456789"
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_bank_account.title'))
      expect(page).to have_selector("h2", text: I18n.t('views.ctc.questions.confirm_bank_account.bank_information'))
      expect(page).to have_selector("li", text: "Bank of Two Melons")
      expect(page).to have_selector("li", text: "#{I18n.t('general.type')}: Checking")
      expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.routing_number')}: 123456789")
      expect(page).to have_selector("li", text: "#{I18n.t('general.bank_account.account_number')}: ●●●●●6789")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      fill_in I18n.t('views.questions.mailing_address.street_address'), with: "26 William Street"
      fill_in I18n.t('views.questions.mailing_address.street_address2'), with: "Apt 1234"
      fill_in I18n.t('views.questions.mailing_address.city'), with: "Bel Air"
      select "California", from: I18n.t('views.questions.mailing_address.state')
      fill_in I18n.t('views.questions.mailing_address.zip_code'), with: 90001
      click_on I18n.t('general.continue')

      # see error notice
      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      within ".notice--error" do
        expect(page).to have_text I18n.t('views.ctc.questions.mailing_address.error_notice')
        expect(page).to have_text I18n.t('forms.errors.mailing_address.not_found')
      end
    end
  end
end
