require "rails_helper"

RSpec.feature "Still Needs Help" do
  context "When a client has triggered the Still Needs Help flow", active_job: true do
    let(:tax_return) { create(:tax_return, :intake_in_progress) }
    let(:client) { create :client, tax_returns: [tax_return], triggered_still_needs_help_at: Time.now }
    let!(:intake) { create :intake, :primary_consented, preferred_name: "Carrie", primary_first_name: "Carrie", primary_last_name: "Carrot", primary_last_four_ssn: "9876", email_address: "example@example.com", sms_phone_number: "+15005550006", client: client }

    context "As a client visiting the portal" do
      before do
        login_as client, scope: :client
      end

      scenario "telling us they do not need help" do
        visit portal_root_path

        expect(page).to have_text "Are you still interested in filing your taxes with us?"

        click_on "No, I'm not interested"

        expect(page).to have_text "Thank you for using GetYourRefund."
        expect(page).to have_text "How was your experience with GetYourRefund?"
        click_on "Ok"
        click_on "Return to home"

        expect(page).to have_text "Welcome back Carrie!"
      end

      scenario "telling us they still need help" do
        visit portal_root_path

        expect(page).not_to have_text "Welcome back Carrie!"
        expect(page).to have_text "Are you still interested in filing your taxes with us?"

        click_on "Yes, I still need help"

        expect(page).to have_text I18n.t("portal.still_needs_helps.upload_documents.title")

        click_on I18n.t("portal.still_needs_helps.upload_documents.no_additional_documents")
        expect(page).to have_text "Welcome back Carrie!"
        expect(client.system_notes.last.body).to eq "Client indicated that they do not have any more documents to upload."
      end
    end
  end
end
