require "rails_helper"

RSpec.feature "a client on their portal" do
  context "tax return state is in between intake_ready and intake_ready_for_call" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [create(:tax_return, :intake_reviewing, year: 2019)]
    end
    before do
      login_as client, scope: :client
    end

    scenario "see waiting for review tax return card" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Randall!"

      within "#tax-year-2019" do
        expect(page).to have_text "Your tax team is going to schedule an initial review call with you."
        expect(page).to have_text "45% complete"
        expect(page).to have_link "View documents"
      end
    end
  end

  context "when a client has not yet completed intake questions" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Katie", current_step: Questions::AssetSaleLossController.to_path_helper),
             tax_returns: [create(:gyr_tax_return, :intake_in_progress, year: 2019)]
    end

    before do
      login_as client, scope: :client
    end

    scenario "linking to next step" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Katie!"

      within "#tax-year-2019" do
        expect(page).to have_text "You have not finished answering all the tax questions so we cannot start your tax return."
        expect(page).to have_text "10% complete"
        expect(page).to have_link "Complete tax questions"
      end
    end
  end

  context "when a client has completed intake questions and has started but not finished uploading documents" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", current_step: "/en/documents/overview"),
             tax_returns: [create(:tax_return, :intake_in_progress, year: 2019)]
    end
    before do
      login_as client, scope: :client
    end
    scenario "linking to next step" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Randall!"

      within "#tax-year-2019" do
        expect(page).to have_text "We need more documents from you to start your tax return."
        expect(page).to have_text "30% complete"
        expect(page).to have_link "Add missing documents", href: "/en/documents/overview"
      end
    end
  end

  context "when a client has completed intake and uploaded at least one document" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [create(:tax_return, :intake_ready, year: 2019)]
    end
    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "waiting for review" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Randall!"

      within "#tax-year-2019" do
        expect(page).to have_text "Your tax team is going to schedule an initial review call with you."
        expect(page).to have_text "45% complete"
        expect(page).to have_link "View documents", href: Portal::UploadDocumentsController.to_path_helper(action: :index)
      end
    end
  end

  context "when the client's status is tax ready for prep or preparing" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [(create :gyr_tax_return, :prep_preparing, year: 2019)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "waiting for tax team to prepare the return" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text "Your tax team is preparing the return"
        expect(page).to have_text "75% complete"
        expect(page).to have_link "View documents", href: Portal::UploadDocumentsController.to_path_helper(action: :index)
      end
    end
  end

  context "when the client's status is info requested" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [(create :gyr_tax_return, :prep_info_requested, year: 2019)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "link to submit tax documents" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text "We need more documents from you to start your tax return."
        expect(page).to have_text "65% complete"
        expect(page).to have_link "Add missing documents", href: Portal::UploadDocumentsController.to_path_helper(action: :index)
      end
    end
  end

  context "when the client's status is greeter info requested" do
    let(:client) do
      create :client,
             intake: (create :intake, completed_at: 10.minutes.ago),
             tax_returns: [(create :gyr_tax_return, :intake_greeter_info_requested)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "link to submit tax documents" do
      visit portal_root_path
      expect(page).to have_text I18n.t("portal.portal.home.calls_to_action.add_missing_documents")
    end
  end

  context "when the tax return is being quality reviewed" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [(create :gyr_tax_return, :review_reviewing, year: 2019)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "waiting on quality review" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text "Your return is being reviewed"
        expect(page).to have_text "80% complete"
        expect(page).to have_link "View documents", href: Portal::UploadDocumentsController.to_path_helper(action: :index)
      end
    end
  end

  context "when the tax return is marked not filing" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [(create :gyr_tax_return, :file_not_filing, year: 2019)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

    end

    scenario "shows that the client requested not to file" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text "This return is not being filed. Contact your tax preparer with any questions."
        expect(page).to have_link "View documents", href: Portal::UploadDocumentsController.to_path_helper(action: :index)
      end
    end
  end

  context "when the tax return is on hold" do
    let(:client) do
      create :client,
             intake: (create :intake, completed_at: 7.minutes.ago),
             tax_returns: [(create :gyr_tax_return, :file_hold)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

    end

    scenario "shows that the return is on hold" do
      visit portal_root_path

      expect(page).to have_text "#{MultiTenantService.new(:gyr).current_tax_year} return"
      within "#tax-year-#{MultiTenantService.new(:gyr).current_tax_year}" do
        expect(page).to have_text "Your return is on hold. Your tax preparer will reach out with an update."
      end
    end
  end

  context "when the client needs to review & sign" do
    let(:client) do
      create :client,
             intake: (create :intake, filing_joint: "yes", preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [(create :gyr_tax_return, :review_signature_requested, year: 2019)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

      create :document,
             document_type: DocumentTypes::UnsignedForm8879.key,
             tax_return: client.tax_returns.first,
             client: client,
             upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
    end

    scenario "waiting on review and signature" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text "We are waiting for a final signature from you."
        expect(page).to have_text "90% complete"
        expect(page).to have_link "Add final signature", href: portal_tax_return_authorize_signature_path(tax_return_id: client.tax_returns.first.id)
      end
    end
  end

  context "when the client has finished filing" do
    let(:client) do
      create :client,
             intake: (create :intake, filing_joint: "yes", preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [(create :gyr_tax_return, :file_efiled, :primary_has_signed, year: 2019)]
    end

    before do
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, tax_return: client.tax_returns.first, client: client
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

    end

    scenario "able to download final tax papers" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text "Your return is being filed."
        expect(page).to have_text "95% complete"
        expect(page).to have_link "View documents", href: Portal::UploadDocumentsController.to_path_helper(action: :index)
      end
    end
  end

  context "a CTC client" do
    let(:client) do
      create :client,
        intake: (create :ctc_intake),
        tax_returns: [(create :ctc_tax_return, :file_efiled, :primary_has_signed, is_ctc: true)]
    end

    before do
      login_as client, scope: :client
    end

    scenario "sees something that does not crash" do
      visit portal_root_path

      expect(page).to have_text "Welcome back #{client.intake.preferred_name}"
    end
  end
end
