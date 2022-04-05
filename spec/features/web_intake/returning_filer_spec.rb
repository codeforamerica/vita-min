require "rails_helper"

RSpec.feature "Web Intake Returning Filer", :flow_explorer_screenshot_i18n_friendly do
  let(:gyr_ssn) { "123-45-6789" }
  let!(:original_gyr_intake) do
    create(
      :intake,
      :filled_out,
      email_address: "original@client.com",
      phone_number: "+14155537865",
      primary_consented_to_service: "yes",
      primary_consented_to_service_at: 15.minutes.ago,
      primary_ssn: gyr_ssn,
      preferred_name: 'Maeby',
      client: build(:client, tax_returns: [build(:tax_return, service_type: "online_intake")])
    )
  end
  let(:ctc_ssn) { "123-45-6788" }
  let!(:original_ctc_intake) do
    create :ctc_intake, primary_consented_to_service: "yes", primary_consented_to_service_at: 15.minutes.ago, primary_ssn: ctc_ssn
  end

  scenario "returning client with GYR intake with matching ssn sees duplicate guard page" do
    visit personal_info_questions_path
    fill_out_personal_information(name: "Dupe", zip_code: "20121")

    fill_in I18n.t("attributes.primary_ssn"), with: gyr_ssn
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: gyr_ssn
    click_on I18n.t('general.continue')

    # backtaxes
    check "2019"
    click_on I18n.t('general.continue')

    # start with current year
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t('views.questions.returning_client.title')
    expect(current_path).to eq(returning_client_questions_path)

    within "main" do
      click_on(I18n.t('general.sign_in'))
    end
    expect(current_path).to eq(new_portal_client_login_path)
  end

  scenario "client with completed intake in session who tries to start a new intake is returned to portal" do
    login_as original_gyr_intake.client, scope: :client

    visit root_path
    click_on I18n.t("general.get_started"), id: "firstCta"

    expect(page).to have_text(I18n.t('portal.portal.home.title', name: "Maeby"))
  end

  #scenario for a matching ITIN

  scenario "returning client with CTC intake with matching SSN does not see duplicate guard" do
    visit personal_info_questions_path
    fill_out_personal_information(name: "Dupe", zip_code: "20121")

    fill_in I18n.t("attributes.primary_ssn"), with: ctc_ssn
    fill_in I18n.t("attributes.confirm_primary_ssn"), with: ctc_ssn
    click_on I18n.t('general.continue')

    # backtaxes
    check "2019"
    click_on I18n.t('general.continue')

    # start with current year
    click_on I18n.t('general.continue')

    expect(page).to have_text I18n.t("views.questions.interview_scheduling.title")
  end
end
