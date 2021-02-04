require "rails_helper"

RSpec.feature "Signing in" do
  context "As a client" do
    let!(:client) do
      create(:intake, primary_first_name: "Carrie", primary_last_name: "Carrot", primary_last_four_ssn: "9876", email_address: "example@example.com").client
    end

    xscenario "requesting a sign-in link" do
      puts(ActiveJob::Base.queue_adapter)
      visit portal_root_path

      expect(page).to have_text "Sign in"
      fill_in "Email", with: client.intake.email_address
      click_on "Sign in"
      # expect(page).to have_text()

      mail = ActionMailer::Base.deliveries.last
      html_body = mail.body.parts[1].decoded
      link = Nokogiri::HTML.parse(html_body).at_css("a")["href"]
      expect(link).to be_present
      # Once this test passes, combine these scenarios into one so we click the link
      # from the email.
    end

    scenario "signing in from a link with confirmation" do
      visit client.generate_login_link
      fill_in "Confirmation number", with: client.id
      click_on "Sign in"

      expect(page).to have_text("Carrie Carrot")
    end

    scenario "signing in from a link with last four" do
      visit client.generate_login_link
      fill_in "Last 4 of SSN/ITIN", with: "9876"
      click_on "Sign in"

      expect(page).to have_text("Carrie Carrot")
    end
  end
end
