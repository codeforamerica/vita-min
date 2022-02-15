require "rails_helper"

RSpec.feature "a client on their portal" do
  context "when a client has not yet completed intake questions" do
    let(:client) do
      create :client,
             intake: (create :intake, preferred_name: "Katie", current_step: "/en/questions/asset-loss"),
             tax_returns: [create(:tax_return, :intake_in_progress)]
    end

    before do
      login_as client, scope: :client
    end

    scenario "linking to next step" do
      visit portal_root_path
      expect(page).to have_text "Welcome back Katie!"
      expect(page).to have_link("Complete all tax questions", href: "/en/questions/asset-loss")
      expect(page).to have_link "Message my tax specialist"

      expect(page).not_to have_text "Answered initial tax questions"
      expect(page).to have_link "Submit additional documents"
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
      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_link("Submit remaining tax documents", href: "/en/documents/overview")
      expect(page).to have_link "Message my tax specialist"

      expect(page).to have_link "Submit additional documents"
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

      # status
      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"
      expect(page).to have_text "2019 Tax Return"

      within "#tax-year-2019" do
        expect(page).to have_text "Your tax team is waiting for an initial review with you"
      end
    end
  end

  context "when the client's status is tax ready for prep or preparing" do
    let(:client) do
      create :client,
             intake: (create :intake),
             tax_returns: [(create :tax_return, :prep_preparing, year: 2021)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "waiting for tax team to prepare the return" do
      visit portal_root_path

      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"

      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).to have_text "Completed review"
        expect(page).to have_text "Your tax team is preparing the return"
      end
    end
  end

  context "when the client's status is info requested" do
    let(:client) do
      create :client,
             intake: (create :intake),
             tax_returns: [(create :tax_return, :prep_info_requested, year: 2021)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "link to submit tax documents" do
      visit portal_root_path

      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"

      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).to have_text "Completed review"
        expect(page).to have_text "Submit requested tax documents"
      end
    end
  end

  context "when the client's status is greeter info requested" do
    let(:client) do
      create :client,
             intake: (create :intake, current_step: "/en/questions/asset-loss"),
             tax_returns: [(create :tax_return, :intake_greeter_info_requested, year: 2021)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "link to submit tax documents" do
      visit portal_root_path
      expect(page).to have_link("Complete all tax questions", href: "/en/questions/asset-loss")

      expect(page).to have_text "Shared initial tax documents"
      expect(page).not_to have_text "Submit remaining tax documents"
      expect(page).to have_text "Submit additional documents"
    end
  end

  context "when the tax return is being quality reviewed" do
    let(:client) do
      create :client,
             intake: (create :intake),
             tax_returns: [(create :tax_return, :review_reviewing, year: 2021)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client
    end

    scenario "waiting on quality review" do
      visit portal_root_path

      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"

      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).to have_text "Completed review"
        expect(page).to have_text "Return prepared"
        expect(page).to have_text "Your tax team is waiting to discuss your final #{TaxReturn.current_tax_year} return with you"
      end
    end
  end

  context "when the tax return is marked not filing" do
    let(:client) do
      create :client,
             intake: (create :intake),
             tax_returns: [(create :tax_return, :file_not_filing, year: 2021)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

    end

    scenario "shows that the client requested not to file" do
      visit portal_root_path

      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"

      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).not_to have_text "Completed review"
        expect(page).not_to have_text "Return prepared"
        expect(page).not_to have_text "Completed quality review"
        expect(page).to have_text "This return is not being filed. Contact your tax preparer with any questions."
      end
    end
  end

  context "when the tax return is on hold" do
    let(:client) do
      create :client,
             intake: (create :intake, current_step: "/en/questions/asset-loss"),
             tax_returns: [(create :tax_return, :file_hold, year: 2021)]
    end

    before do
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

    end

    scenario "shows that the return is on hold" do
      visit portal_root_path

      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).not_to have_text "Completed review"
        expect(page).not_to have_text "Return prepared"
        expect(page).not_to have_text "Completed quality review"
        expect(page).to have_text "Your return is on hold. Your tax preparer will reach out with an update."
      end
    end
  end

  context "when the client needs to review & sign" do
    let(:client) do
      create :client,
             intake: (create :intake, filing_joint: "yes"),
             tax_returns: [(create :tax_return, :review_signature_requested, year: 2021)]
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

      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"

      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).to have_text "Completed review"
        expect(page).to have_text "Return prepared"
        expect(page).to have_text "Completed quality review for #{TaxReturn.current_tax_year}"
        expect(page).to have_link "Add final primary taxpayer signature for #{TaxReturn.current_tax_year}"
        expect(page).to have_link "Add final spouse signature for #{TaxReturn.current_tax_year}"
      end
    end
  end

  context "when the client has finished filing" do
    let(:client) do
      create :client,
             intake: (create :intake),
             tax_returns: [(create :tax_return, :file_efiled, :primary_has_signed, year: 2021)]
    end

    before do
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, tax_return: client.tax_returns.first, client: client
      login_as client, scope: :client
      create :document, client: client, uploaded_by: client

    end

    scenario "able to download final tax papers" do
      visit portal_root_path

      expect(page).to have_text "Answered initial tax questions"
      expect(page).to have_text "Shared initial tax documents"
      expect(page).to have_text "Completed review"


      expect(page).to have_text "#{TaxReturn.current_tax_year} Tax Return"
      within "#tax-year-#{TaxReturn.current_tax_year}" do
        expect(page).to have_text "Return prepared"
        expect(page).to have_text "Completed quality review for #{TaxReturn.current_tax_year}"
        expect(page).to have_text "Final signature added for #{TaxReturn.current_tax_year}"
        expect(page).to have_link("Download final tax papers #{TaxReturn.current_tax_year}")
      end
    end
  end

  context "a client with tax returns ready that have actions to take" do
    let(:client) { create :client, intake: (create :intake, preferred_name: "Martha", primary_first_name: "Martha", primary_last_name: "Mango", filing_joint: "yes") }
    let(:tax_return2019) { create :tax_return, :ready_to_sign, year: 2019, client: client }
    let(:tax_return2018) { create :tax_return, :ready_to_file_solo, year: 2018, client: client }
    before do
      create :document, display_name: "Another 8879", document_type: DocumentTypes::UnsignedForm8879.key, upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"), tax_return: tax_return2019, client: tax_return2019.client
      create :tax_return, :intake_in_progress, year: 2017, client: client
      create :document, client: client, uploaded_by: client

      create :document, document_type: DocumentTypes::FinalTaxDocument.key, tax_return: tax_return2019, client: tax_return2019.client
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, display_name: "Some final tax document", tax_return: tax_return2018, client: tax_return2018.client
      create :document, document_type: DocumentTypes::FinalTaxDocument.key, display_name: "Another final tax document", tax_return: tax_return2018, client: tax_return2018.client
      login_as client, scope: :client
    end

    scenario "viewing their tax return statuses", :js do
      visit portal_root_path
      expect(page).to have_text "Welcome back Martha!"

      expect(page).to have_text "2019 Tax Return"
      expect(page).to have_text "2018 Tax Return"
      expect(page).to have_text "2017 Tax Return"

      within "#tax-year-2019" do
        expect(page).to have_link "View or download Another 8879"
        expect(page).to have_link "View or download " + tax_return2019.unsigned_8879s.first.display_name

        expect(page).to have_link "Download final tax papers 2019"
        expect(page).to have_link "Add final primary taxpayer signature for 2019"
        expect(page).to have_link "Add final spouse signature for 2019"
      end

      within "#tax-year-2018" do
        expect(page).to have_link "View or download signed form 8879"
        expect(page).to have_link "View or download Some final tax document"
        expect(page).to have_link "View or download Another final tax document"
        expect(page).not_to have_link "Add final primary taxpayer signature for 2018"
      end

      expect(client.documents.where(document_type: "Other").length).to eq 0

      click_link "Submit additional documents"
      expect(page).to have_text "Please share any additional documents."

      upload_file("requested_document_upload_form[document]", Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))
      expect(page).to have_content("test-pattern.png")

      expect(client.documents.where(document_type: "Other").length).to eq 1
      page.accept_alert 'Are you sure you want to remove "test-pattern.png"?' do
        click_on "Remove"
      end

      expect(page).to have_text "Please share any additional documents."
      expect(client.documents.where(document_type: "Other").length).to eq 0

      click_on "Continue"
      expect(page).to have_text "Welcome back"
      click_on "Submit additional documents"

      expect(page).not_to have_content("test-pattern.png")

      expect(page).to have_text "Please share any additional documents"
      expect(page).not_to have_text "I don't have this right now."
      click_on "Go back"
      expect(page).to have_text "Welcome back"

      expect(page).to have_link "Message my tax specialist"
    end
  end

  context "with an ITIN client ready to mail their forms" do
    let(:intake) { create :intake, state_of_residence: 'CA', primary_ssn: '555-11-2222', preferred_interview_language: 'en', preferred_name: "Martha", primary_first_name: "Martha", primary_last_name: "Mango", filing_joint: "no", triage: build(:triage, id_type: "need_itin_help") }
    let(:client) { create :client, intake: intake }
    let(:tax_return) { create :tax_return, :file_mailed, year: TaxReturn.current_tax_year, client: client }

    before do
      create(:document, document_type: DocumentTypes::Form1040, tax_return: tax_return, client: client)
      create(:document, document_type: DocumentTypes::FormW7, tax_return: tax_return, client: client)

      login_as client, scope: :client
    end

    it "shows where to mail the Form 1040 and W7" do
      visit portal_root_path
      expect(page).to have_text("Welcome back Martha!")
      expect(page).to have_text("2021 Tax Return")
      expect(page).to have_text("Austin Service Center") # Part of the IRS's ITINs by mail address
      within "#tax-year-2021" do
        expect(page).to have_link I18n.t('portal.portal.home.document_link.view_1040')
        expect(page).to have_link I18n.t('portal.portal.home.document_link.view_w7')
      end
    end

    context "when the client was helped by a certifying acceptance agent" do
      before do
        create(:document, document_type: DocumentTypes::FormW7Coa, tax_return: tax_return, client: client)

        login_as create :admin_user
        visit hub_client_path(id: client.id)
        within ".client-profile" do
          click_on "Edit"
        end

        check "Used a Certifying Acceptance Agent"
        click_on "Save"
        expect(client.reload.intake.used_itin_certifying_acceptance_agent?).to be_truthy
      end

      it "includes additional instructions" do
        login_as client, scope: :client
        visit portal_root_path
        expect(page).to have_text("Welcome back Martha!")
        expect(page).to have_text("2021 Tax Return")
        expect(page).to have_text("Austin Service Center") # Part of the IRS's ITINs by mail address
        expect(page).to have_text(I18n.t('portal.portal.itin_instructions.caa.in_person'))
        within "#tax-year-2021" do
          expect(page).to have_link I18n.t('portal.portal.home.document_link.view_1040')
          expect(page).to have_link I18n.t('portal.portal.home.document_link.view_w7')
          expect(page).to have_link I18n.t('portal.portal.home.document_link.view_w7_coa')
        end
      end
    end
  end

  context "a CTC client" do
    let(:client) do
      create :client,
        intake: (create :ctc_intake),
        tax_returns: [(create :tax_return, :file_efiled, :primary_has_signed, year: 2021, is_ctc: true)]
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
