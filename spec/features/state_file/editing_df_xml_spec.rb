require "rails_helper"

RSpec.feature "editing direct file XML with the FederalInfoController", active_job: true do
  include MockTwilio
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    Flipper.enable :sms_notifications
  end

  it "does not modify the df xml if nothing was changed" do
    visit "/"
    click_on "Start Test NY"

    expect(page).to have_text I18n.t("state_file.landing_page.edit.ny.title")
    click_on "Get Started", id: "firstCta"

    step_through_eligibility_screener(us_state: "ny")

    step_through_initial_authentication(contact_preference: :text_message)
    check "Email"
    check "Text message"
    fill_in "Your phone number", with: "+12025551212"
    click_on "Continue"

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer("Transfer Javier")

    xml_before = StateFileNyIntake.last.raw_direct_file_data.strip

    expect(page).to have_text I18n.t('state_file.questions.data_review.edit.title')
    click_on I18n.t("general.continue")
    expect(page).to have_text I18n.t('state_file.questions.name_dob.edit.title1')

    xml_after = StateFileNyIntake.last.raw_direct_file_data.strip
    expect(xml_before).to eq(xml_after)
  end

  it "allows you to edit the df xml" do
    visit "/"
    click_on "Start Test AZ"

    expect(page).to have_text I18n.t("state_file.landing_page.edit.az.title")
    click_on "Get Started", id: "firstCta"

    click_on "Continue"

    step_through_initial_authentication(contact_preference: :text_message)
    check "Email"
    check "Text message"
    fill_in "Your phone number", with: "+12025551212"
    click_on "Continue"

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer("Transfer Alexis hoh w2 and 1099")

    expect(page).to have_text I18n.t('state_file.questions.data_review.edit.title')

    xml_before = StateFileAzIntake.last.raw_direct_file_data.strip
    find("#visit_federal_info_controller").click

    expect(page).to have_text "‍💻🛠️ Direct File Data Overrides 🛠️💻"

    fill_in "primary ssn", with: "123-45-6789"
    fill_in "Return header phone number (primary)", with: "5551112222"

    # W2
    fill_in "WagesAmt", with: 1500
    fill_in "WithholdingAmt", with: 300
    fill_in "StateWagesAmt", with: 1000
    fill_in "StateIncomeTaxAmt", with: 100
    fill_in "LocalWagesAndTipsAmt", with: 4000
    fill_in "LocalIncomeTaxAmt", with: 400
    fill_in "LocalityNm", with: "Pelicanville"

    # 1099R
    fill_in "TotalTaxablePensionsAmt", with: 200

    fill_in "payer_name", with: "Rose Apothecary"
    fill_in "payer_name_control", with: "ROSEAPC"
    fill_in "payer_address_line1", with: "123 Schit Street"
    fill_in "payer_city_name", with: "Schitts Creek"
    fill_in "payer_state_code", with: "AZ"
    fill_in "payer_zip", with: "43212"
    fill_in "payer_identification_number", with: "000000003"
    fill_in "phone_number", with: "3025551223"
    fill_in "gross_distribution_amount", with: 3000
    fill_in "taxable_amount", with: 200
    fill_in "federal_income_tax_withheld_amount", with: 150
    fill_in "distribution_code", with: "8"
    fill_in "state_tax_withheld_amount", with: 20
    fill_in "state_code", with: "NC"
    fill_in "payer_state_identification_number", with: "987654321"
    fill_in "state_distribution_amount", with: 200

    click_on "Continue"

    xml_after = StateFileAzIntake.last.raw_direct_file_data.strip
    expect(xml_before).not_to eq(xml_after)

    expect(StateFileAzIntake.last.direct_file_data.w2s[0].WagesAmt).to eq 1500
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].WithholdingAmt).to eq 300
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].StateWagesAmt).to eq 1000
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].StateIncomeTaxAmt).to eq 100
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].LocalWagesAndTipsAmt).to eq 4000
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].LocalIncomeTaxAmt).to eq 400
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].LocalityNm).to eq "Pelicanville"

    expect(StateFileAzIntake.last.direct_file_data.fed_taxable_pensions).to eq 200
    expect(StateFileAzIntake.last.direct_file_data.primary_ssn).to eq "123-45-6789"
    expect(StateFileAzIntake.last.direct_file_data.phone_number).to eq "5551112222"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_name).to eq "Rose Apothecary"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_name_control).to eq "ROSEAPC"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_address_line1).to eq "123 Schit Street"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_city_name).to eq "Schitts Creek"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_state_code).to eq "AZ"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_zip).to eq "43212"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_identification_number).to eq "000000003"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].phone_number).to eq "3025551223"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].gross_distribution_amount).to eq 3000
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].taxable_amount).to eq 200
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].federal_income_tax_withheld_amount).to eq 150
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].distribution_code).to eq "8"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].state_tax_withheld_amount).to eq 20
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].state_code).to eq "NC"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].payer_state_identification_number).to eq "987654321"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].state_distribution_amount).to eq 200

    expect(StateFileAzIntake.last.state_file1099_rs[0].state_tax_withheld_amount).to eq 20
  end

  it "preserves W2 when XML Editor is opened without changes" do
    visit "/"
    click_on "Start Test NC"

    expect(page).to have_text I18n.t("state_file.landing_page.edit.nc.title")
    click_on "Get Started", id: "firstCta"

    step_through_eligibility_screener(us_state: "nc")

    step_through_initial_authentication(contact_preference: :text_message)
    check "Email"
    check "Text message"
    fill_in "Your phone number", with: "+12025551212"
    click_on "Continue"

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer("Transfer Nick")

    expect(page).to have_text I18n.t('state_file.questions.data_review.edit.title')

    xml_before = StateFileNcIntake.last.direct_file_data
    raw_xml_before = StateFileNcIntake.last.raw_direct_file_data.strip
    expect(xml_before.w2s[0].EmployeeSSN).to eq "400000030"

    find("#visit_federal_info_controller").click
    expect(page).to have_text "‍💻🛠️ Direct File Data Overrides 🛠️💻"

    click_on "Continue"
    expect(page).to have_text I18n.t('state_file.questions.name_dob.edit.title1')
    xml_after = StateFileNcIntake.last.direct_file_data
    raw_xml_after = StateFileNcIntake.last.raw_direct_file_data.strip
    expect(raw_xml_before).to eq(raw_xml_after)

    expect(xml_after.w2s[0].EmployeeSSN).to eq "400000030"
  end
end
