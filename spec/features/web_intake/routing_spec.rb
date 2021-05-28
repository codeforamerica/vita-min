require "rails_helper"

feature "Intake Routing Spec" do
  let!(:expected_source_param_vita_partner) { create :vita_partner, name: "Cobra Academy" }
  let!(:expected_zip_code_vita_partner) { create :vita_partner, name: "Diagon Alley" }
  let!(:expected_state_vita_partner) { create :vita_partner, name: "Hogwarts", capacity_limit: 10 }
  let!(:source_parameter) { create :source_parameter, code: "cobra", vita_partner: expected_source_param_vita_partner }
  let!(:zip_code) { "94606" }
  let!(:vita_partner_zip_code) { create :vita_partner_zip_code, zip_code: zip_code, vita_partner: expected_zip_code_vita_partner }
  let!(:vita_partner_state) { create :vita_partner_state, state: "NC", vita_partner: expected_state_vita_partner, routing_fraction: 0.2 }

  scenario "routing by source param" do
    visit "/cobra"
    # expect redirect to locale path
    # expect that this sets a cookie that routes to cobra.

    expect(page).to have_text "Free tax filing, made simple."

    # clients with matching vita partner source param skip triage questions
    click_on "Get started", id: "firstCta"
    expect(page).to have_text "Welcome"
    click_on "Continue"

    expect(page).to have_text "Our full service option is right for you!"
    click_on "Continue"

    expect(page).to have_text "What years would you like to file for?"
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq "cobra"
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "What is your preferred first name?", with: "Betty Banana"
    fill_in "ZIP code", with: zip_code
    click_on "Continue"

    expect(page.html).to have_text "Our team at Cobra Academy is here to help!"
  end

  scenario "routing by zip code" do
    visit "/questions/file-with-help"

    expect(page).to have_text "Our full service option is right for you!"
    click_on "Continue"

    expect(page).to have_text "What years would you like to file for?"
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq nil
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "What is your preferred first name?", with: "Minerva Mcgonagall"
    fill_in "ZIP code", with: zip_code
    click_on "Continue"

    expect(page.html).to have_text "Our team at Diagon Alley is here to help!"
  end

  scenario "routing by state" do
    visit "/questions/file-with-help"

    expect(page).to have_text "Our full service option is right for you!"
    click_on "Continue"

    expect(page).to have_text "What years would you like to file for?"
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq nil
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "What is your preferred first name?", with: "Luna Lovegood"
    fill_in "ZIP code", with: "28806"
    click_on "Continue"

    expect(page.html).to have_text "Our team at Hogwarts is here to help!"
  end

  context "vita partner is at capacity" do
    let!(:default_vita_partner) { create :vita_partner, name: "Default Organization", national_overflow_location: true }

    before do
      expected_state_vita_partner.update(capacity_limit: 0)
    end

    scenario "would have been routed by state, redirects to at capacity page" do
      visit "/questions/file-with-help"

      expect(page).to have_text "Our full service option is right for you!"
      click_on "Continue"

      expect(page).to have_text "What years would you like to file for?"
      check "2020"
      click_on "Continue"

      expect(Intake.last.source).to eq nil
      expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
      click_on "Continue to example"

      expect(page).to have_text "Let's get started"
      click_on "Continue"

      expect(page).to have_text "Just a few simple steps to file!"
      click_on "Continue"

      expect(page).to have_text "let's get some basic information"
      fill_in "What is your preferred first name?", with: "Luna Lovegood"
      fill_in "ZIP code", with: "28806"
      click_on "Continue"

      expect(page.html).to have_text "Wow, it looks like we are at capacity right now."
    end
  end
end