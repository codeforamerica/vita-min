require "rails_helper"

RSpec.feature "CTC Intake", active_job: true do
  let!(:intake) { create :ctc_intake, email_address: "mango@example.com", email_notification_opt_in: "yes" }
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
    let!(:intake) { create :ctc_intake, client: create(:client, tax_returns: [build(:tax_return, year: 2020)]), email_address: "mango@example.com"}
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

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.new.label")
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.new.message")
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

      expect(page).to have_selector("h1", text: I18n.t("views.ctc.portal.home.title"))
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.preparing.label")
      expect(page).to have_text I18n.t("views.ctc.portal.home.status.preparing.message")
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
      expect(page).to have_text "We encountered some errors transmitting your return to the IRS. Information about next steps were sent to your contact info."
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
      create(:efile_submission, :rejected, :with_errors, tax_return: create(:tax_return, client: intake.client, year: 2020))
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
      expect(page).to have_text "IND-189: 'DeviceId' in 'AtSubmissionCreationGrp' in 'FilingSecurityInformation' in the Return Header must have a value."
      # only show the first error to the user so as not to overwhelm them
      expect(page).not_to have_text "IND-190: 'DeviceId' in 'AtSubmissionFilingGrp' in 'FilingSecurityInformation' in the Return Header must have a value."
      expect(page).to have_text "Your return has not been accepted by the IRS. We will need to correct your info and resubmit. Please contact your tax preparer to make corrections."
      click_on "Message my tax preparer"
      expect(page).to have_selector "h1", text: "Message your tax preparer"
      fill_in "What's on your mind?", with: "I have some questions about my tax return."
      click_on "Send message"
      expect(page).to have_text "Message sent! Responses will be sent by email to mango@example.com."
    end
  end
end