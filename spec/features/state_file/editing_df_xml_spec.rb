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

    step_through_eligibility_screener(us_state: "az")

    step_through_initial_authentication(contact_preference: :text_message)

    expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
    click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

    step_through_df_data_transfer("Transfer Alexis hoh w2 and 1099")

    expect(page).to have_text I18n.t('state_file.questions.data_review.edit.title')

    xml_before = StateFileAzIntake.last.raw_direct_file_data.strip
    find("#visit_federal_info_controller").click

    expect(page).to have_text "‍💻🛠️ Direct File Data Overrides 🛠️💻"

    # W2
    fill_in "WagesAmt", with: 500
    fill_in "WithholdingAmt", with: 300
    fill_in "StateWagesAmt", with: 300
    fill_in "StateIncomeTaxAmt", with: 600
    fill_in "LocalWagesAndTipsAmt", with: 3000
    fill_in "LocalIncomeTaxAmt", with: 4400
    fill_in "LocalityNm", with: "Pelicanville"

    # 1099R
    fill_in "PayerName", with: "Rose Apothecary"
    fill_in "PayerNameControlTxt", with: "ROSEAPC"
    fill_in "AddressLine1Txt", with: "123 Schit Street"
    fill_in "CityNm", with: "Schitts Creek"
    fill_in "StateAbbreviationCd", with: "AZ"
    fill_in "ZIPCd", with: "43212"
    fill_in "PayerEIN", with: "000000003"
    fill_in "PhoneNum", with: "3025551223"
    fill_in "GrossDistributionAmt", with: "3000"
    fill_in "TaxableAmt", with: "200"
    fill_in "FederalIncomeTaxWithheldAmt", with: "150"
    fill_in "F1099RDistributionCd", with: "8"

    click_on "Continue"

    xml_after = StateFileAzIntake.last.raw_direct_file_data.strip
    expect(xml_before).not_to eq(xml_after)

    expect(StateFileAzIntake.last.direct_file_data.w2s[0].WagesAmt).to eq 500
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].WithholdingAmt).to eq 300
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].StateWagesAmt).to eq 300
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].StateIncomeTaxAmt).to eq 600
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].LocalWagesAndTipsAmt).to eq 3000
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].LocalIncomeTaxAmt).to eq 4400
    expect(StateFileAzIntake.last.direct_file_data.w2s[0].LocalityNm).to eq "Pelicanville"

    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].PayerName).to eq "Rose Apothecary"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].PayerNameControlTxt).to eq "ROSEAPC"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].AddressLine1Txt).to eq "123 Schit Street"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].CityNm).to eq "Schitts Creek"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].StateAbbreviationCd).to eq "AZ"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].ZIPCd).to eq "43212"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].PayerEIN).to eq "000000003"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].PhoneNum).to eq "3025551223"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].GrossDistributionAmt).to eq "3000"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].TaxableAmt).to eq "200"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].FederalIncomeTaxWithheldAmt).to eq "150"
    expect(StateFileAzIntake.last.direct_file_data.form1099rs[0].F1099RDistributionCd).to eq "8"
  end
end
