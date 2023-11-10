require "rails_helper"

RSpec.feature "Going through the eligibility screener" do
  include StateFileIntakeHelper

  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
  end

  context "residency requirement" do
    it "NY: shows them the offboarding page if they don't meet the residency requirement" do
      visit "/"
      click_on "Start Test NY"

      expect(page).to have_text "File your New York state taxes for free"
      click_on "Get Started", id: "firstCta"

      expect(page).to have_text "First, let's see if you can use this tool to file your taxes"
      choose "state_file_ny_eligibility_residence_form_eligibility_lived_in_state_no"
      choose "state_file_ny_eligibility_residence_form_eligibility_yonkers_no"
      click_on "Continue"

      expect(page).to have_text "Unfortunately, you can’t use this tool this year. Don’t worry, there are other filing options."
    end

    it "AZ: shows them the offboarding page if they don't meet the residency requirement" do
      visit "/"
      click_on "Start Test AZ"

      expect(page).to have_text "File your Arizona state taxes for free"
      click_on "Get Started", id: "firstCta"

      expect(page).to have_text "First, let's see if you can use this tool to file your taxes"
      choose "state_file_az_eligibility_residence_form_eligibility_lived_in_state_no"
      choose "state_file_az_eligibility_residence_form_eligibility_married_filing_separately_no"
      click_on "Continue"

      expect(page).to have_text "Unfortunately, you can’t use this tool this year. Don’t worry, there are other filing options."
    end
  end
end
