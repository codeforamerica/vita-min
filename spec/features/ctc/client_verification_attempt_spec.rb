require "rails_helper"

RSpec.feature "CTC Intake", :js, :active_job, requires_default_vita_partners: true do
  let!(:intake) { create :ctc_intake, client: (create :ctc_client), email_address: "mango@example.com", email_notification_opt_in: "yes", email_address_verified_at: DateTime.now }
  let(:client) { intake.client }
  let!(:efile_submission) do
    create :efile_submission, :fraud_hold, client: client
  end

  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
    allow_any_instance_of(EfileSecurityInformation).to receive(:timezone).and_return("America/Chicago")
    login_as client, scope: :client
  end

  ["pending", "escalated", "restricted"].each do |state|
    context "when the client is in fraud_hold state  and has a verification attempt that is being reviewed in state of #{state}" do
      before do
        create :verification_attempt, state.to_sym, client: client
      end

      scenario "they see the ID Review message on the portal" do
        visit "/en/portal"
        expect(page).to have_content("Reviewing ID Submission")
      end
    end
  end

  context "when the client is in fraud hold and does not have an existing verification attempt" do
    scenario "they see the verification attempt page" do
      visit "/en/portal"
      expect(page).to have_content(I18n.t("views.ctc.portal.verification.title"))
      expect(page).to have_text("We accept: .jpg, .jpeg, .png, .pdf, .heic, .bmp, .txt, .tiff, .gif")
      within "form#file-upload-form" do
        expect(page).to have_text(I18n.t("views.ctc.portal.verification.selfie_label"))
        expect(page).not_to have_text(I18n.t("views.ctc.portal.verification.resubmission"))

        # Add a selfie
        upload_file("verification_attempt_selfie", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
        expect(page).not_to have_text(I18n.t("views.ctc.portal.verification.selfie_label"))

        # See that it exists on the page
        expect(page).to have_text "Uploaded images"
        expect(page).to have_text "picture_id.jpg"
        # Remove the image
        accept_alert do
          click_on("Remove")
        end
        # Now, it asks us to add another selfie
        expect(page).to have_text(I18n.t("views.ctc.portal.verification.selfie_label"))

        upload_file("verification_attempt_selfie", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))

        # We also need to add a photo of the ID alone
        expect(page).to have_text(I18n.t("views.ctc.portal.verification.id_label"))

        upload_file("verification_attempt_photo_identification", Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"))
        expect(page).not_to have_text(I18n.t("views.ctc.portal.verification.id_label"))
      end

      # now we should see a continue button
      click_on I18n.t("general.continue")

      expect(page).to have_content "Reviewing ID Submission"
    end
  end

  context "when the client has a submission in fraud_hold + a verification attempt with photos that hasn't been submitted yet" do
    before do
      create :verification_attempt, :new, client: client
    end

    scenario "they see the verification page with the photos attached and ability to continue" do
      visit "/en/portal"
      expect(page).to have_text I18n.t("views.ctc.portal.verification.title")
      expect(page).not_to have_text(I18n.t("views.ctc.portal.verification.id_label"))
      expect(page).not_to have_text(I18n.t("views.ctc.portal.verification.selfie_label"))

      expect(page).to have_text "Uploaded images"
      click_on I18n.t("general.continue")

      expect(page).to have_content "Reviewing ID Submission"
    end
  end

  context "when the client has identity denied" do
    let!(:verification_attempt) { create :verification_attempt, :escalated, client: client }

    it "shows them data for the cancelled state" do
      visit "/en/portal"

      expect(page).to have_content "Reviewing ID Submission"
      verification_attempt.transition_to(:denied)
      visit "/en"
      visit "/en/portal"
      expect(page).not_to have_content "Reviewing ID Submission"
      expect(page).to have_content "Cancelled"
      expect(page).to have_content "We will no longer attempt to efile this return with the IRS."
      # TODO: The page should have a button to download the PDF
    end
  end
end
