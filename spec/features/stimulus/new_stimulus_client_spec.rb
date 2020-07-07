require "rails_helper"

RSpec.feature "Stimulus Triage Flow" do
  scenario "new stimulus triage client might be helped by filing chooses to file" do
    visit "/questions/welcome"
    expect(page).to have_selector("h2", text: "Get your Stimulus")
    click_on("Get your Stimulus")
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("No")
    expect(page).to have_selector("h1", text: "Have you already filed for 2016 and 2017?")
    click_on("No")
    expect(page).to have_selector("h1", text: "We can help increase your cash support, by filing your taxes in addition to the stimulus")
    click_on("Yes! Help me file my taxes.")
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
  end

  scenario "new stimulus triage client might be helped by filing chooses only stimulus" do
    visit "/questions/welcome"
    expect(page).to have_selector("h2", text: "Get your Stimulus")
    click_on("Get your Stimulus")
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("No")
    expect(page).to have_selector("h1", text: "Have you already filed for 2016 and 2017?")
    click_on("No")
    expect(page).to have_selector("h1", text: "We can help increase your cash support, by filing your taxes in addition to the stimulus")
    click_on("No. I only want my stimulus.")
    expect(page).to have_selector("h1", text: "Get your Stimulus Payment (EIP)")
  end

  scenario "new stimulus triage client visits the stimulus FAQ" do
    visit "/questions/welcome"
    expect(page).to have_selector("h2", text: "Get your Stimulus")
    click_on("Get your Stimulus")
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("No")
    expect(page).to have_selector("h1", text: "Have you already filed for 2016 and 2017?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Get your stimulus check!")
    click_on("Visit Stimulus FAQ")
    expect(page).to have_selector("h1", text: "Get your Stimulus Payment (EIP)")
  end

  scenario "new stimulus triage client needs to correct" do
    visit "/questions/welcome"
    expect(page).to have_selector("h2", text: "Get your Stimulus")
    click_on("Get your Stimulus")
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "Do you need to correct your 2019 taxes?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "We’ll help you collect your stimulus check by filing!")
    click_on("Continue")
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
  end

  scenario "new stimulus triage client needs to file" do
    visit "/questions/welcome"
    expect(page).to have_selector("h2", text: "Get your Stimulus")
    click_on("Get your Stimulus")
    expect(page).to have_selector("h1", text: "Have you already filed for 2018 and 2019?")
    click_on("No")
    expect(page).to have_selector("h1", text: "Do you need to file this year?")
    click_on("Yes")
    expect(page).to have_selector("h1", text: "We’ll help you collect your stimulus check by filing!")
    click_on("Continue")
    expect(page).to have_selector("h1", text: "What years do you need to file for?")
  end
end

