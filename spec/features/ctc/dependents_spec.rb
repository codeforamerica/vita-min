require "rails_helper"

def fill_in_dependent_info(dependent_birth_year)
  expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.info.title'))
  fill_in I18n.t('views.ctc.questions.dependents.info.first_name'), with: "Jessie"
  fill_in I18n.t('views.ctc.questions.dependents.info.middle_initial'), with: "M"
  fill_in I18n.t('views.ctc.questions.dependents.info.last_name'), with: "Pepper"
  fill_in "ctc_dependents_info_form[birth_date_month]", with: "11"
  fill_in "ctc_dependents_info_form[birth_date_day]", with: "01"
  fill_in "ctc_dependents_info_form[birth_date_year]", with: dependent_birth_year
  select "Social Security Number (SSN)"
  fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin', name: "Jessie"), with: "222-33-4445"
  fill_in I18n.t('views.ctc.questions.dependents.tin.ssn_or_atin_confirmation', name: "Jessie"), with: "222-33-4445"
end

RSpec.feature "Dependents in CTC intake", :flow_explorer_screenshot, active_job: true do
  let(:client) { create :client, intake: create(:ctc_intake), tax_returns: [create(:tax_return, year: 2021)] }

  before do
    login_as client, scope: :client
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)

    visit "/questions/had-dependents"
    click_on I18n.t('general.affirmative')
  end

  context "adding people who count as dependents" do
    scenario "a minor child" do
      dependent_birth_year = 15.years.ago.year
      fill_in_dependent_info(dependent_birth_year)

      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence_exceptions.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')


      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      within "[data-automation='ctc-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a child over 18 who qualifies as a dependent by being a student" do
      dependent_birth_year = 20.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')

      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_qualifiers.title', name: 'Jessie'))
      check I18n.t('views.ctc.questions.dependents.child_qualifiers.full_time_student', name: "Jessie")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence_exceptions.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a qualified relative adult" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.uncle'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.relative_financial_support.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.dependents.relative_qualifiers.title"))
      check I18n.t("views.ctc.questions.dependents.relative_qualifiers.claimable", name: "Jessie")
      check I18n.t("views.ctc.questions.dependents.relative_qualifiers.income_requirement", name: "Jessie")
      click_on I18n.t("general.continue")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))

      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "qualifying relative who needs member of household question" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.other'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.relative_member_of_household.title', name: "Jessie", current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.relative_financial_support.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.dependents.relative_qualifiers.title"))
      check I18n.t("views.ctc.questions.dependents.relative_qualifiers.claimable", name: "Jessie")
      check I18n.t("views.ctc.questions.dependents.relative_qualifiers.income_requirement", name: "Jessie")
      click_on I18n.t("general.continue")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))

      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "an older child who is permanently disabled, does not pay half living expenses" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.son'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_qualifiers.title', name: 'Jessie'))
      check I18n.t('views.ctc.questions.dependents.child_qualifiers.permanently_totally_disabled', name: "Jessie")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_claim_anyway.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      # Too old for CTC, but still qualify for other credits
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "an older child who is a student" do
      dependent_birth_year = TaxReturn.current_tax_year - 22
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.son'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_qualifiers.title', name: 'Jessie'))
      check I18n.t('views.ctc.questions.dependents.child_qualifiers.full_time_student', name: "Jessie")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_claim_anyway.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      # Too old for CTC, but still qualify for other credits
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a middle-aged son who is a qualified relative" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.son'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_qualifiers.title', name: 'Jessie'))
      check I18n.t('general.none_of_these')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.relative_financial_support.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.relative_qualifiers.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      check I18n.t("views.ctc.questions.dependents.relative_qualifiers.income_requirement", name: "Jessie")
      check I18n.t("views.ctc.questions.dependents.relative_qualifiers.claimable", name: "Jessie")
      click_on I18n.t("general.continue")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "an infant born within the last 6 months of the tax year" do
      fill_in_dependent_info(TaxReturn.current_tax_year)
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: "Jessie", current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: "Jessie", current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.affirmative")

      within "[data-automation='ctc-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{TaxReturn.current_tax_year}")
      end
    end

    scenario "a child who could be claimed by another but we are claiming them" do
      fill_in_dependent_info(2019)
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_residence.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_claim_anyway.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      within "[data-automation='ctc-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/2019")
      end
    end
  end

  context "adding people who don't count as dependents" do
    scenario "an uncle who does not get 50% support from client" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.uncle'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.dependents.relative_financial_support.title", name: "Jessie", current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.dependents.does_not_qualify_ctc.title", name: "Jessie"))
      click_on I18n.t("general.negative")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.confirm_dependents.title'))
      expect(page).not_to have_content("Jessie M Pepper")
    end

    scenario "a child who paid for over half their support" do
      fill_in_dependent_info(TaxReturn.current_tax_year - 14)
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_expenses.title', name: 'Jessie', current_tax_year: TaxReturn.current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.does_not_qualify_ctc.title', name: 'Jessie'))
    end

    scenario "a child who is married and filed with their spouse" do
      fill_in_dependent_info(2005)
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      check I18n.t("views.ctc.questions.dependents.info.filed_joint_return")
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.does_not_qualify_ctc.title', name: 'Jessie'))
    end

    scenario "a child that was born after the current tax year" do
      fill_in_dependent_info(TaxReturn.current_tax_year + 1)
      select I18n.t('general.dependent_relationships.daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.does_not_qualify_ctc.title', name: 'Jessie'))
    end
  end
end
