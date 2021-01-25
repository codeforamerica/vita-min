require "rails_helper"

feature "Intake Routing Spec" do
  let!(:vita_partner) { create :vita_partner, name: "Cobra Academy" }
  let!(:vita_partner2) { create :vita_partner, name: "Other Location" }
  let!(:source_parameter) { create :source_parameter, code: "cobra", vita_partner: vita_partner }
  let!(:zip_code) { "94606" }
  let!(:vita_partner_zip_code) { create :vita_partner_zip_code, zip_code: zip_code, vita_partner: vita_partner2 }

  let(:default_vita_partner) { create :vita_partner, name: "Default Organization", national_overflow_location: true }

  scenario "routing by source param" do
    visit "/"
    expect(page).to have_text "Free tax filing, real human support."

    visit "/cobra"
    # expect redirect to locale path
    # expect that this sets a cookie that routes to cobra.

    expect(page).to have_text "Free tax filing, made simple."

    visit "/questions/welcome"
    click_on "File taxes with help"

    expect(page).to have_text "File with the help of a tax expert!"
    click_on "Continue"

    expect(page).to have_text "What years do you need to file for?"
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq "cobra"
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Let’s check a few things"
    check "None of the above"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "Preferred name", with: "Betty Banana"
    fill_in "ZIP code", with: zip_code
    click_on "Continue"

    expect(page.html).to have_text "Our team at Cobra Academy is here to help!"
  end

  scenario "routing by zip code" do
    visit "/questions/welcome"
    click_on "File taxes with help"

    expect(page).to have_text "File with the help of a tax expert!"
    click_on "Continue"

    expect(page).to have_text "What years do you need to file for?"
    check "2020"
    click_on "Continue"

    expect(Intake.last.source).to eq nil
    expect(page).to have_text "Thanks for visiting the GetYourRefund demo application!"
    click_on "Continue to example"

    expect(page).to have_text "Let's get started"
    click_on "Continue"

    expect(page).to have_text "Let’s check a few things"
    check "None of the above"
    click_on "Continue"

    expect(page).to have_text "Just a few simple steps to file!"
    click_on "Continue"

    expect(page).to have_text "let's get some basic information"
    fill_in "Preferred name", with: "Minerva Mcgonagall"
    fill_in "ZIP code", with: zip_code
    click_on "Continue"

    expect(page.html).to have_text "Our team at Other Location is here to help!"
  end
end