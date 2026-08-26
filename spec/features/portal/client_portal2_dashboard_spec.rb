require "rails_helper"

RSpec.feature 'client in the portal' do
  context 'tax return state' do
    let(:client) do
      create :client,
        intake: (build :intake, preferred_name: 'Gertrude', completed_at: DateTime.current),
        tax_returns: [build(:tax_return, year: 2019)]
    end
    before do
      login_as client, scope: :client
      Flipper.enable(:client_portal_improvements)
    end

    #####################
    ## Intake statuses ##
    #####################

    scenario 'with return status :intake_in_progress' do
      client.tax_returns.last.transition_to!(:intake_in_progress)
      client.intake.current_step = Questions::AssetSaleLossController.to_path_helper
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'You\'re still filling out your tax form.'
      expect(page).to have_link 'Complete tax questions', href: Questions::AssetSaleLossController.to_path_helper
    end

    scenario 'with return status :intake_needs_doc_help' do
      client.tax_returns.last.transition_to!(:intake_needs_doc_help)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'You\'re still filling out your tax form.'
      expect(page).to have_link 'Complete tax questions', href: Portal::UploadDocumentsController.to_path_helper(action: :index)
    end

    scenario 'with return status :intake_info_requested' do
      client.tax_returns.last.transition_to!(:intake_info_requested)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'We need a few more documents to finish your tax return.'
      expect(page).to have_link 'Add documents', href: Portal::UploadDocumentsController.to_path_helper(action: :index)
    end

    scenario 'with return status :intake_greeter_info_requested' do
      client.tax_returns.last.transition_to!(:intake_greeter_info_requested)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'We need a few more documents to finish your tax return.'
      expect(page).to have_link 'Add documents', href: Portal::UploadDocumentsController.to_path_helper(action: :index)
    end

    scenario 'with return status :intake_ready' do
      client.tax_returns.last.transition_to!(:intake_ready)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'Your tax team is reviewing your information.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :intake_reviewing' do
      client.tax_returns.last.transition_to!(:intake_reviewing)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'Your tax team is reviewing your information.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :intake_ready_for_call' do
      client.tax_returns.last.transition_to!(:intake_ready_for_call)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'Your tax team is reviewing your information.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    ###################
    ## Prep statuses ##
    ###################

    scenario 'with return status :prep_ready_for_prep' do
      client.tax_returns.last.transition_to!(:prep_ready_for_prep)
      visit '/portal/portal2'

      expect(page).to have_text 'Tax prep'
      expect(page).to have_text 'Your tax team is preparing your return.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :prep_preparing' do
      client.tax_returns.last.transition_to!(:prep_preparing)
      visit '/portal/portal2'

      expect(page).to have_text 'Tax prep'
      expect(page).to have_text 'Your tax team is preparing your return.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    xscenario 'with return status :prep_info_requested' do
      client.tax_returns.last.transition_to!(:prep_info_requested)
      allow_any_instance_of(TaxReturnCardHelper).to receive(:contact_method_of_last_tax_team_message).
        with(client.intake).
        and_return('email')
      visit '/portal/portal2'

      expect(page).to have_text 'Tax prep'
      expect(page).to have_text 'We need more information to prepare your return.'
      # Special test here: check for correct contact method (email, in this case).
      expect(page).to have_text 'Your tax team sent a question via email.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    #####################
    ## Review statuses ##
    #####################

    scenario 'with return status :review_ready_for_qr' do
      client.tax_returns.last.transition_to!(:review_ready_for_qr)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :review_reviewing' do
      client.tax_returns.last.transition_to!(:review_reviewing)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :review_ready_for_call' do
      client.tax_returns.last.transition_to!(:review_ready_for_call)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    # TODO once GYR1-1085 is merged.
    xscenario 'with return status :review_signature_requested' do
      client.tax_returns.last.transition_to!(:review_signature_requested)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      # expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    xscenario 'with return status :review_info_requested' do
      client.tax_returns.last.transition_to!(:review_info_requested)
      allow_any_instance_of(TaxReturnCardHelper).to receive(:contact_method_of_last_tax_team_message).
        with(client.intake).
        and_return('email')
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your tax team needs one more thing before finalizing your return.'
      # Special test here: check for correct contact method (email, in this case).
      expect(page).to have_text 'Your tax team sent a question via email.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    ###################
    ## File statuses ##
    ###################

    scenario 'with return status :file_needs_review' do
      client.tax_returns.last.transition_to!(:file_needs_review)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_ready_to_file' do
      client.tax_returns.last.transition_to!(:file_ready_to_file)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_efiled' do
      client.tax_returns.last.transition_to!(:file_efiled)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_mailed' do
      client.tax_returns.last.transition_to!(:file_mailed)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_rejected' do
      client.tax_returns.last.transition_to!(:file_rejected)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_accepted' do
      client.tax_returns.last.transition_to!(:file_accepted)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_not_filing' do
      client.tax_returns.last.transition_to!(:file_not_filing)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_hold' do
      client.tax_returns.last.transition_to!(:file_hold)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_fraud_hold' do
      client.tax_returns.last.transition_to!(:file_fraud_hold)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end
  end
end

RSpec.feature "a client on the improved portal whose return is waiting for a signature" do
  let(:filing_joint) { "no" }
  let(:unsigned_8879_uploaded) { true }
  let(:final_tax_document_uploaded) { true }
  let(:tax_return) { build(:gyr_tax_return, :review_signature_requested, year: 2019) }
  let(:client) do
    create :client,
           intake: (build :intake, filing_joint: filing_joint, preferred_name: "Randall", completed_at: DateTime.current),
           tax_returns: [tax_return]
  end

  before do
    Flipper.enable(:client_portal_improvements)
    login_as client, scope: :client

    if unsigned_8879_uploaded
      create :document,
             document_type: DocumentTypes::UnsignedForm8879.key,
             tax_return: tax_return,
             client: client,
             upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
    end

    if final_tax_document_uploaded
      create :document,
             document_type: DocumentTypes::FinalTaxDocument.key,
             tax_return: tax_return,
             client: client,
             upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
    end
  end

  scenario "shows the final check badge, notice, download link, and both signature CTAs" do
    visit portal_root_path

    within "#tax-year-2019" do
      expect(page).to have_text I18n.t("portal.portal2.home.badge.final_check")
      expect(page).to have_text I18n.t("portal.portal2.home.help_text.signature_requested_primary")
      expect(page).to have_text I18n.t("portal.portal2.home.calls_to_action.signature_requested_title")
      expect(page).to have_text I18n.t("portal.portal2.home.calls_to_action.signature_requested")
      expect(page).to have_link(
        I18n.t("portal.portal2.home.document_link.download_final_tax_papers"),
        href: portal_document_path(id: tax_return.final_tax_documents.first.id)
      )
      expect(page).to have_link(
        I18n.t("portal.portal2.home.button.sign_your_return"),
        href: portal_tax_return_authorize_signature_path(tax_return_id: tax_return.id)
      )
      expect(page).to have_link(
        I18n.t("portal.portal2.home.button.decline_to_sign"),
        href: portal_tax_return_decline_signature_path(tax_return_id: tax_return.id)
      )
      expect(page).to have_text I18n.t("portal.portal2.home.decline_to_sign_help")
      expect(page).not_to have_link I18n.t("portal.portal2.home.button.message_tax_team")
    end
  end

  scenario "tags the tracked CTAs with the return status for Mixpanel" do
    visit portal_root_path

    within "#tax-year-2019" do
      expect(page).to have_css(
        "a[data-track-click='client_portal_sign_return_button'][data-track-attribute-return_status='review_signature_requested']"
      )
      expect(page).to have_css(
        "a[data-track-click='client_portal_decline_to_sign_button'][data-track-attribute-return_status='review_signature_requested']"
      )
      expect(page).to have_css(
        "a[data-track-click='client_portal_download_tax_papers'][data-track-attribute-return_status='review_signature_requested']"
      )
    end
  end

  scenario "declining to sign moves the return to waiting for a call, flags the client, and notes it in the hub" do
    visit portal_root_path

    within "#tax-year-2019" do
      click_on I18n.t("portal.portal2.home.button.decline_to_sign")
    end

    expect(page).to have_text I18n.t("portal.tax_returns.decline_signature.confirmation")
    expect(tax_return.reload.current_state).to eq "review_ready_for_call"
    expect(client.reload.flagged?).to eq true
    expect(SystemNote::ClientDeclinedSignature.where(client: client).count).to eq 1
  end

  context "when the primary has signed and the spouse has not" do
    let(:filing_joint) { "yes" }

    before do
      tax_return.update!(
        primary_signature: "Randall Rando",
        primary_signed_at: DateTime.current + 1.minute,
        primary_signed_ip: "127.0.0.1"
      )
    end

    scenario "shows the spouse signature CTA" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text I18n.t("portal.portal2.home.help_text.signature_requested_spouse")
        expect(page).to have_link(
          I18n.t("portal.portal2.home.button.sign_your_return"),
          href: portal_tax_return_spouse_authorize_signature_path(tax_return_id: tax_return.id)
        )
      end
    end
  end

  context "when the final tax document has not been uploaded yet" do
    let(:final_tax_document_uploaded) { false }

    scenario "shows the view documents action instead of the signature CTAs" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text I18n.t("portal.portal2.home.badge.final_check")
        expect(page).to have_text I18n.t("portal.portal2.home.help_text.review")
        expect(page).to have_link(
          I18n.t("portal.portal2.home.button.view_documents"),
          href: Portal::UploadDocumentsController.to_path_helper(action: :index)
        )
        expect(page).not_to have_link I18n.t("portal.portal2.home.button.sign_your_return")
        expect(page).not_to have_link I18n.t("portal.portal2.home.button.decline_to_sign")
        expect(page).not_to have_text I18n.t("portal.portal2.home.document_link.download_final_tax_papers")
      end
    end
  end

  context "when the 8879 has not been uploaded yet" do
    let(:unsigned_8879_uploaded) { false }

    scenario "shows the view documents action instead of the signature CTAs" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text I18n.t("portal.portal2.home.badge.final_check")
        expect(page).to have_text I18n.t("portal.portal2.home.help_text.review")
        expect(page).to have_link(
          I18n.t("portal.portal2.home.button.view_documents"),
          href: Portal::UploadDocumentsController.to_path_helper(action: :index)
        )
        expect(page).not_to have_link I18n.t("portal.portal2.home.button.sign_your_return")
        expect(page).not_to have_link I18n.t("portal.portal2.home.button.decline_to_sign")
      end
    end
  end

  context "when everyone who needs to sign has already signed the 8879" do
    before do
      tax_return.update!(
        primary_signature: "Randall Rando",
        primary_signed_at: DateTime.current + 1.minute,
        primary_signed_ip: "127.0.0.1"
      )
    end

    scenario "shows the view documents action instead of the signature CTAs" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text I18n.t("portal.portal2.home.help_text.review")
        expect(page).to have_link I18n.t("portal.portal2.home.button.view_documents")
        expect(page).not_to have_link I18n.t("portal.portal2.home.button.sign_your_return")
      end
    end
  end
end

