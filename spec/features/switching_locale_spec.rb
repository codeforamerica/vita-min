require "rails_helper"

RSpec.feature "Switching Locale" do
  include StateFileIntakeHelper

  scenario "client switches between Spanish and English versions of website using the header link" do
    visit root_path

    within(".main-header") do
      click_on "Español"
    end
    expect(page).to have_content(I18n.t("views.public_pages.home.header", locale: :es))

    within(".main-header") do
      click_on "English"
    end
    expect(page).to have_content(I18n.t("views.public_pages.home.header", locale: :en))
  end

  context "from eligibility offboarding pages, when client switches between Spanish and English" do
    before do
      allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    end

    context "ID" do
      scenario "from the id_eligibility_residence_controller" do
        visit "/en"
        click_on "Start Test ID"

        expect(page).to have_text I18n.t("state_file.landing_page.edit.id.title")
        click_on I18n.t('general.get_started'), id: "firstCta"

        expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.title", filing_year: filing_year)
        expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.emergency_rental_assistance", filing_year: filing_year)
        expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.withdrew_msa_fthb", filing_year: filing_year)

        find_by_id('state_file_id_eligibility_residence_form_eligibility_withdrew_msa_fthb_yes').click
        find_by_id('state_file_id_eligibility_residence_form_eligibility_emergency_rental_assistance_yes').click
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")
        click_on "Go back to correct."

        expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.title", filing_year: filing_year)

        find_by_id('state_file_id_eligibility_residence_form_eligibility_withdrew_msa_fthb_yes').click
        find_by_id('state_file_id_eligibility_residence_form_eligibility_emergency_rental_assistance_yes').click
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")

        within(".main-header") do
          click_on "Español"
        end

        click_on "Regresa para corregirlo."
        expect(page).to have_text I18n.t("state_file.questions.id_eligibility_residence.edit.title", filing_year: filing_year)
      end
    end

    context "MD" do
      scenario "from the md_eligibility_filing_status controller" do
        visit "/en"
        click_on "Start Test MD"

        expect(page).to have_text I18n.t("state_file.landing_page.edit.md.title")
        click_on I18n.t('general.get_started'), id: "firstCta"

        expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
        choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_filing_status_mfj_yes"
        choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_homebuyer_withdrawal_mfj_yes"
        choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_home_different_areas_yes"
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")
        click_on "Go back to correct."

        expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
        choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_filing_status_mfj_yes"
        choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_homebuyer_withdrawal_mfj_yes"
        choose I18n.t("general.affirmative"), id: "state_file_md_eligibility_filing_status_form_eligibility_home_different_areas_yes"
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")

        within(".main-header") do
          click_on "Español"
        end

        click_on "Regresa para corregirlo."
        expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
      end

      scenario "from the md_permanent_address controller" do
        visit "/en"
        click_on "Start Test MD"

        expect(page).to have_text I18n.t("state_file.landing_page.edit.md.title")
        click_on I18n.t('general.get_started'), id: "firstCta"

        expect(page).to have_text I18n.t("state_file.questions.md_eligibility_filing_status.edit.title", year: filing_year)
        click_on I18n.t("general.continue")

        step_through_eligibility_screener(us_state: "md")

        step_through_initial_authentication(contact_preference: :email)

        check "Email"
        check "Text message"
        fill_in "Your phone number", with: "+12025551212"
        click_on "Continue"

        expect(page).to have_text I18n.t('state_file.questions.sms_terms.edit.title')
        click_on I18n.t("general.accept")

        expect(page).to have_text I18n.t('state_file.questions.terms_and_conditions.edit.title')
        click_on I18n.t("state_file.questions.terms_and_conditions.edit.accept")

        step_through_df_data_transfer("Transfer Frodo hoh cdcc")

        expect(page).to have_text I18n.t("state_file.questions.md_permanent_address.edit.title", filing_year: filing_year)
        choose I18n.t("general.affirmative")
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")
        click_on "Go back to correct."

        expect(page).to have_text I18n.t("state_file.questions.md_permanent_address.edit.title", filing_year: filing_year)
        choose I18n.t("general.affirmative")
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")
        within(".main-header") do
          click_on "Español"
        end
        click_on "Regresa para corregirlo."
        expect(page).to have_text I18n.t("state_file.questions.md_permanent_address.edit.title", filing_year: filing_year)
      end
    end

    context "NC" do
      scenario "from nc_eligibility controller" do
        visit "/en"
        click_on "Start Test NC"

        expect(page).to have_text I18n.t("state_file.landing_page.edit.nc.title")
        click_on I18n.t('general.get_started'), id: "firstCta"

        expect(page).to have_text I18n.t("state_file.questions.nc_eligibility.edit.title", filing_year: filing_year)
        check I18n.t("state_file.questions.nc_eligibility.edit.eligibility_ed_loan_emp_payment")
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")
        click_on "Go back to correct."

        expect(page).to have_text I18n.t("state_file.questions.nc_eligibility.edit.title", filing_year: filing_year)
        check I18n.t("state_file.questions.nc_eligibility.edit.eligibility_ed_loan_cancelled")
        click_on I18n.t("general.continue")

        expect(page).to have_text I18n.t("state_file.questions.eligibility_offboarding.edit.title.default")

        within(".main-header") do
          click_on "Español"
        end

        click_on "Regresa para corregirlo."
        expect(page).to have_text I18n.t("state_file.questions.nc_eligibility.edit.title", filing_year: filing_year)
      end
    end
  end
end
