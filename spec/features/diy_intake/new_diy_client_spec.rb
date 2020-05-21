require "rails_helper"

RSpec.feature "Web Intake New Client wants to file on their own" do
  scenario "new client wants to use FSA to file" do
    visit "/diy/file-yourself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Continue"

    expect(page).to have_selector("h1", text: "First, let's get some basic information.")
    fill_in "Preferred name", with: "Gary"
    select "California", from: "State of residence"
    click_on "Continue"

    expect(page).to have_selector("h1", text: "Please share your e-mail address.")
    fill_in "E-mail address", with: "do.it@your"
    fill_in "Confirm e-mail address", with: "do.it@your.self"
    click_on "Continue"
    expect("E-mail address").to have_error("Please enter a valid email address.")
    expect("Confirm e-mail address").to have_error("Please double check that the email addresses match.")
    fill_in "E-mail address", with: "do.it@your.self"
    click_on "Continue"

    # Remove this when next page is created
    expect(page).to have_selector("h1", text: "Please check your e-mail for a confirmation link.")
    click_on "Return to home"

    expect(current_path).to eq(root_path)
  end

  scenario "new client thinks they want DIY but changes their mind" do
    visit "/diy/file-yourself"

    expect(page).to have_selector("h1", text: "File your taxes yourself!")
    click_on "Actually, I need assistance filing"

    expect(page).to have_selector("h1", text: "File with the help of a tax expert!")
  end
end

