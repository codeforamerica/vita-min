require "rails_helper"

RSpec.feature "CTC Intake", :js, :active_job, requires_default_vita_partners: true do
  let!(:intake) { create :ctc_intake, client: (create :ctc_client), email_address: "mango@example.com", email_notification_opt_in: "yes", email_address_verified_at: DateTime.now }
  let(:client) { intake.client }
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow_any_instance_of(EfileSecurityInformation).to receive(:timezone).and_return("America/Chicago")
    login_as client, scope: :client
  end

  context "when the client is in fraud_hold state and has a verification attempt that is being reviewed" do
    before do
      create :verification_attempt, :pending, client: client
    end

    scenario "they see the ID Review message on the portal" do
      visit "/en/portal"
      expect(page).to have_content("Reviewing ID Sumbission")
    end
  end

end
