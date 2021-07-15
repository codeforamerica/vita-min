require "rails_helper"

RSpec.feature "CTC Intake", :js, active_job: true do
  # TODO: after we have the RRC calculation based on dependents, set up some cases for routing to owed vs received
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  def create_intake
    visit "/en/questions/overview"
    expect(page).to have_selector(".toolbar", text: "GetCTC") # Check for appropriate header
    expect(page).to have_selector("h1", text: "Let's get started!")
    click_on "Continue"
    expect(page).to have_selector("h1", text: "Did you earn any income in 2020?")

    click_on "No"
    click_on "Continue"
  end

  scenario "when the client says they received the amounts calculated on /stimulus-payments, we direct them to /stimulus-received and display the calculated amounts" do
    create_intake

    visit "en/questions/stimulus-payments"
    expect(page).to have_selector("h1", text: "Based on your info, we believe you should have received this much in stimulus payments.")
    click_on "Yes, I received this amount."
    expect(page).to have_selector("h1", text: "Based on your info, it looks like you’ve received your full stimulus payments.")
    expect(page).to have_text("EIP 1: $TBD")
    expect(page).to have_text("EIP 2: $TBD")
  end

  context "when the client says they did not receive the amounts calculated on /stimulus-payments" do
    xscenario "when the client's provided amounts (sum) are less than the calculated amounts (sum), we direct them to /stimulus-owed" do; end
    xscenario "when the client's provided amounts (sum) are greater than or equal to the calculated amounts (sum), we direct them to /stimulus-received" do; end

    scenario "when the client says they did not receive stimulus 1 or 2, it saves zero as that amount" do
      create_intake

      visit "en/questions/stimulus-payments"
      expect(page).to have_selector("h1", text: "Based on your info, we believe you should have received this much in stimulus payments.")
      click_on "No, I didn’t receive this amount."
      expect(page).to have_selector("h1", text: "Did you receive any of the first stimulus payment?")
      click_on "No"
      expect(page).to have_selector("h1", text: "Did you receive any of the second stimulus payment?")
      click_on "No"

      expect(page).to have_text("EIP 1: $0")
      expect(page).to have_text("EIP 2: $0")
    end
  end

  context "client ends up on /stimulus-owed" do
    scenario "when the client says they do want to claim the remaining stimulus money" do
      create_intake
      intake = Intake.last

      visit "en/questions/stimulus-owed"
      click_on "Claim the additional money"
      expect(intake.reload.claim_owed_stimulus_money).to eq "yes"
      expect(page).to have_selector("h1", text: "If you are supposed to get money, how would you like to receive it?")
    end

    scenario "when the client says they don't want to claim the remaining stimulus money" do
      create_intake
      intake = Intake.last

      visit "en/questions/stimulus-owed"
      click_on "Don’t claim the additional money"
      expect(intake.reload.claim_owed_stimulus_money).to eq "no"
      expect(page).to have_selector("h1", text: "If you are supposed to get money, how would you like to receive it?")
    end
  end
end