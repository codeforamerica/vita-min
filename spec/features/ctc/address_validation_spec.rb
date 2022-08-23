require "rails_helper"

RSpec.feature "CTC Intake", active_job: true, requires_default_vita_partners: true, do_not_stub_usps: true do
  include CtcIntakeFeatureHelper
  let(:usps_api_response_body) { file_fixture("usps_address_validation_body.xml").read }
  let!(:intake_with_verified_address) { create(:ctc_intake, usps_address_verified_at: 5.minutes.ago) }

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

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
      choose I18n.t('views.questions.refund_payment.check')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      expect(page).to have_select(I18n.t('views.questions.mailing_address.state'), selected: [])
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

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
      choose I18n.t('views.questions.refund_payment.check')
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

  context "fall back to confirmation page" do
    scenario "API request crashes the first time, client tries again from confirmation page and succeeds" do
      # USPS API times out on mailing address page
      stub_request(:get, /.*secure\.shippingapis\.com.*/).to_timeout

      fill_in_can_use_ctc(filing_status: "single")
      fill_in_eligibility
      fill_in_basic_info
      fill_in_dependents(head_of_household: true)
      fill_in_advance_child_tax_credit
      fill_in_recovery_rebate_credit(third_stimulus_amount: "$2,800")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
      choose I18n.t('views.questions.refund_payment.check')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      fill_in I18n.t('views.questions.mailing_address.street_address'), with: "26 William Street"
      fill_in I18n.t('views.questions.mailing_address.street_address2'), with: "Apt 1234"
      fill_in I18n.t('views.questions.mailing_address.city'), with: "Bel Air"
      select "California", from: I18n.t('views.questions.mailing_address.state')
      fill_in I18n.t('views.questions.mailing_address.zip_code'), with: 90001
      click_on I18n.t('general.continue')

      fill_in_ip_pins

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_information.title"))

      # USPS API request should succeed after this point
      stub_request(:get, /.*secure\.shippingapis\.com.*/).to_return(status: 200, body: file_fixture("usps_address_validation_body.xml").read, headers: {})

      within ".address-info" do
        expect(page).to have_text I18n.t('general.error_found')
      end

      # Disallow submission until the address is fixed
      expect(page).to have_button(I18n.t('general.continue'), disabled: true)

      within ".address-info" do
        click_on "edit"
      end

      expect(page).to have_text I18n.t('views.questions.mailing_address.unable_to_validate')
      click_on I18n.t('general.save')

      # Saves address from USPS API
      expect(page).to have_selector("div", text: "43 VICKSBURG ST UNIT B")
      expect(page).to have_selector("div", text: "SAN FRANCISCO, CA 94114")

      fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Gary Mango III"), with: "12345"
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_payment.title"))
    end

    scenario "API request crashes the first time, client tries again from confirmation page and fails but is allowed to continue" do
      # USPS API times out on mailing address page
      stub_request(:get, /.*secure\.shippingapis\.com.*/).to_timeout

      fill_in_can_use_ctc(filing_status: "single")
      fill_in_eligibility
      fill_in_basic_info
      fill_in_dependents(head_of_household: true)
      fill_in_advance_child_tax_credit
      fill_in_recovery_rebate_credit(third_stimulus_amount: "$2,800")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.refund_payment.title'))
      choose I18n.t('views.questions.refund_payment.check')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.mailing_address.title'))
      fill_in I18n.t('views.questions.mailing_address.street_address'), with: "26 William Street"
      fill_in I18n.t('views.questions.mailing_address.street_address2'), with: "Apt 1234"
      fill_in I18n.t('views.questions.mailing_address.city'), with: "Bel Air"
      select "California", from: I18n.t('views.questions.mailing_address.state')
      fill_in I18n.t('views.questions.mailing_address.zip_code'), with: 90001
      click_on I18n.t('general.continue')

      fill_in_ip_pins

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_information.title"))

      # Displays an error next to address to indicate it wasn't validated
      within ".address-info" do
        expect(page).to have_text I18n.t('general.error_found')
      end

      # Disallow submission until the client attempts to fix address
      expect(page).to have_button(I18n.t('general.continue'), disabled: true)

      within ".address-info" do
        click_on "edit"
      end

      expect(page).to have_text I18n.t('views.questions.mailing_address.unable_to_validate')
      click_on I18n.t('general.save')

      fill_in I18n.t("views.ctc.questions.confirm_information.labels.signature_pin", name: "Gary Mango III"), with: "12345"
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.confirm_payment.title"))
    end
  end
end
