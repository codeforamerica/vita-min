require "rails_helper"

RSpec.feature "Add a new intake case from the website" do
  scenario "new client" do
    visit "/questions/identity"
    click_on "Sign in with ID.me"

    # the ID.me flow would occur here. They should end up back on a success page.

    expect(page).to have_selector("h1", text: "Overview")
    click_on "Continue"

    select "3 jobs", from: "In 2019, how many jobs did you have?"
    click_on "Next"

    expect(page).to have_selector("h1", text: "In 2019, did you receive wages or salary?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any tips?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from contract or self-employment work?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you report a business loss on your 2018 tax return?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from a retirement account, pension, or annuity proceeds?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from Social Security or Railroad Retirement Benefits?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any unemployment benefits?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any disability benefits?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from interest or dividends?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from the sale of stocks, bonds, or real estate?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you report a loss from the sale of stocks, bonds, or real estate on your 2018 return?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any income from alimony?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from rental properties?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from farm activity?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have any income from gambling winnings, including the lottery?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive a state or local income tax refund?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any other money?")
    click_on "Yes"

    fill_in "What were the other types of income that you received?", with: "cash from gardening"
    click_on "Next"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any mortgage interest?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any state, local, real estate, sales, or other taxes?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any medical, dental, or prescription expenses?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any charitable contributions?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any student loan interest?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay any child or dependent care expenses?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any contributions to a retirement account?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you pay for any eligible school supplies as a teacher, teacher's aide, or other educator?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any alimony payments?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, was someone in your family a college or other post high school student?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you sell a home?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have a Health Savings Account?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you purchase health insurance through the marketplace or exchange?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Did you receive the First Time Homebuyer Credit in 2008?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have debt cancelled or forgiven by a lender?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you have a loss related to a declared Federal Disaster Area?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you adopt a child?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "Have you had the Earned Income Credit, Child Tax Credit, American Opportunity Credit, or Head of Household filing status disallowed in a prior year?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you receive any letter or bill from the IRS?")
    click_on "Yes"

    expect(page).to have_selector("h1", text: "In 2019, did you make any estimated tax payments or apply your 2018 refund to your 2019 taxes?")
    click_on "Yes"

    fill_in "Is there any additional information you think we should know?", with: "One of my kids moved away for college, should I include them as a dependent?"
    # we don't have anywhere to go yet
    #click_on "Next"
  end
end
