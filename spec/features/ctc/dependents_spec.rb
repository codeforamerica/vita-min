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

      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
      check I18n.t('general.none')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_lived_with_you.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')


      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='ctc-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a child over 18 who qualifies as a dependent by being a student" do
      dependent_birth_year = 20.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      check I18n.t('views.ctc.questions.dependents.info.full_time_student')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
      check I18n.t('general.none')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_lived_with_you.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')


      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a disabled adult" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.08_uncle'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      check I18n.t('views.ctc.questions.dependents.info.permanently_totally_disabled')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.qualifying_relative.title', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a middle-aged uncle who earns little money, lives with the client, and has a SSN" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.08_uncle'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.qualifying_relative.title', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "a middle-aged son who earns little money, lives with the client, and has a SSN" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.01_son'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.qualifying_relative.title', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='other-credits-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/#{dependent_birth_year}")
      end
    end

    scenario "an infant born in late 2020" do
      fill_in_dependent_info(2020)
      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
      check I18n.t('general.none')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='ctc-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/2020")
      end
    end

    scenario "a child who could be claimed by another but we are claiming them" do
      fill_in_dependent_info(2019)
      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
      check I18n.t('general.none')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_lived_with_you.title', name: 'Jessie', current_tax_year: current_tax_year))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_can_be_claimed_by_other.title', name: 'Jessie'))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.claim_child_anyway.title', name: 'Jessie'))
      click_on I18n.t('general.affirmative')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      within "[data-automation='ctc-dependents']" do
        expect(page).to have_content("Jessie M Pepper")
        expect(page).to have_selector("div", text: "#{I18n.t('general.date_of_birth')}: 11/1/2019")
      end
    end
  end

  context "adding people who don't count as dependents" do
    scenario "a middle-aged adult who earns a bunch of money and isn't disabled" do
      dependent_birth_year = 40.years.ago.year
      fill_in_dependent_info(dependent_birth_year)
      select I18n.t('general.dependent_relationships.08_uncle'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.qualifying_relative.title', current_tax_year: current_tax_year))
      click_on I18n.t('general.negative')

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.questions.dependents.does_not_qualify_ctc.title", name: "Jessie"))
      click_on I18n.t("views.ctc.questions.dependents.does_not_qualify_ctc.done_button")

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.confirm_dependents.title'))
      expect(page).not_to have_content("Jessie M Pepper")
    end

    scenario "a child who paid for over half their support" do
      fill_in_dependent_info(2008)
      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
      check I18n.t('views.ctc.questions.dependents.child_disqualifiers.provided_over_half_own_support', name: 'Jessie')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.does_not_qualify_ctc.title', name: 'Jessie'))
    end

    scenario "a child who is married and filed with their spouse" do
      fill_in_dependent_info(2005)
      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.child_disqualifiers.title', name: 'Jessie'))
      check I18n.t('views.ctc.questions.dependents.child_disqualifiers.filed_joint_return', name: 'Jessie')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.does_not_qualify_ctc.title', name: 'Jessie'))
    end

    scenario "a child that was born in 2021" do
      fill_in_dependent_info(2021)
      select I18n.t('general.dependent_relationships.00_daughter'), from: I18n.t('views.ctc.questions.dependents.info.relationship_to_you')
      click_on I18n.t('general.continue')

      expect(page).to have_selector("h1", text: I18n.t('views.ctc.questions.dependents.does_not_qualify_ctc.title', name: 'Jessie'))
    end
  end
end
