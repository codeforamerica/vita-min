require "rails_helper"

RSpec.feature "a client on the improved portal whose return is waiting for a signature" do
  let(:filing_joint) { "no" }
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

    create :document,
           document_type: DocumentTypes::UnsignedForm8879.key,
           tax_return: tax_return,
           client: client,
           upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")

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
        I18n.t("portal.portal2.home.document_link.download_final_tax_papers", year: 2019),
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

    scenario "still shows the signature card, minus the download link" do
      visit portal_root_path

      within "#tax-year-2019" do
        expect(page).to have_text I18n.t("portal.portal2.home.badge.final_check")
        expect(page).to have_text I18n.t("portal.portal2.home.help_text.signature_requested_primary")
        expect(page).to have_link I18n.t("portal.portal2.home.button.sign_your_return")
        expect(page).to have_link I18n.t("portal.portal2.home.button.decline_to_sign")
        expect(page).not_to have_text I18n.t("portal.portal2.home.document_link.download_final_tax_papers", year: 2019)
      end
    end
  end
end
