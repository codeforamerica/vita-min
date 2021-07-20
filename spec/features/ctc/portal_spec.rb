require "rails_helper"

RSpec.feature "CTC Intake", active_job: true do
  let!(:intake) { create :ctc_intake, email_address: "mango@example.com"}
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  context "when the client has not verified" do
    before do
      intake.update(email_address_verified_at: nil)
    end

    scenario "they get the no match found email" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("It looks like you attempted to sign in to GetCTC, but we did not find any matching contact information.")
    end
  end

  context "when the client has verified the contact, intake is in progress" do
    before do
      intake.update(email_address_verified_at: DateTime.now, current_step: "/en/questions/spouse-info")
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "More information needed"
      expect(page).to have_text "We need more information from you before we can file your return."
      click_on "Complete CTC form"
      expect(page).to have_text "Tell us about your spouse"
    end
  end

  context "when the client has verified the contact, efile submission is status new" do
    before do
      intake.update(email_address_verified_at: DateTime.now, current_step: "/en/questions/spouse-info")
      create(:efile_submission, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Submission in progress"
      expect(page).to have_text "We are preparing your return. We'll continue to update you on the status of your submission."
    end
  end

  context "when the client has verified the contact, efile submission is status preparing" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :preparing, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Submission in progress"
      expect(page).to have_text "We are preparing your return. We'll continue to update you on the status of your submission."
    end
  end

  context "when the client has verified the contact, efile submission is status failed" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :failed, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Submission error"
      expect(page).to have_text "We encountered some errors trasmitting your return to the IRS. Information about next steps were sent to your contact info."
    end
  end

  context "when the client has verified the contact, efile submission is status transmitted" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :transmitted, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Electronically filed"
      expect(page).to have_text "Your return has been submitted to the IRS. You will know in 48 hours if your return has been accepted."
    end
  end

  context "when the client has verified the contact, efile submission is status accepted" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :accepted, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Accepted"
      expect(page).to have_text "Your return has been accepted by the IRS. You should receive a payment within 1-4 weeks."
    end
  end

  context "when the client has verified the contact, efile submission is status rejected" do
    before do
      intake.update(email_address_verified_at: DateTime.now)
      create(:efile_submission, :rejected, tax_return: create(:tax_return, client: intake.client, year: 2020))
    end

    scenario "a client sees and can click on a link to continue their intake" do
      visit "/en/portal/login"

      expect(page).to have_selector("h1", text: "To view your progress, we’ll send you a secure code.")
      fill_in "Email address", with: "mango@example.com"
      click_on "Send code"

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last
      expect(mail.html_part.body.to_s).to have_text("Your 6-digit GetCTC verification code is: ")
      code = mail.html_part.body.to_s.match(/Your 6-digit GetCTC verification code is: (\d+)/)[1]
      fill_in "Enter 6 digit code", with: code
      click_on "Verify"
      expect(page).to have_selector("h1", text: "Authentication needed to continue.")
      fill_in "Client ID or Last 4 of SSN/ITIN", with: intake.client.id
      click_on "Continue"

      expect(page).to have_selector("h1", text: "Thank you for filing with GetCTC!")
      expect(page).to have_text "Rejected"
      expect(page).to have_text "Your return has not been accepted by the IRS. We will need to correct your info and resubmit. Information about next steps were sent to your contact info."
    end
  end
end