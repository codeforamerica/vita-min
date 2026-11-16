require "rails_helper"

RSpec.feature "tax season deadline banners on the improved portal" do
  let(:eastern) { Time.find_zone("America/New_York") }
  let(:now) { eastern.parse("2026-10-05 12:00:00") }
  let(:state) { :review_reviewing }
  let(:tax_return) { build(:gyr_tax_return, state, year: 2025) }
  let(:client) do
    create :client,
           intake: (build :intake, preferred_name: "Randall", completed_at: DateTime.current),
           tax_returns: [tax_return]
  end
  let(:info_heading) { "This tax season ends October 15" }
  let(:info_body) { "Check for updates from your tax team." }
  let(:warning_heading) { "Sign by October 15" }
  let(:warning_body) { "We need your signature to file your return." }

  before do
    allow(Rails.configuration).to receive(:end_of_intake).and_return(eastern.parse("2026-10-01 23:59:59"))
    allow(Rails.configuration).to receive(:end_of_in_progress_intake).and_return(eastern.parse("2026-10-15 23:59:59"))
    allow(Rails.configuration).to receive(:end_of_login).and_return(eastern.parse("2026-10-22 23:59:59"))
    travel_to now
    Flipper.enable(:client_portal_improvements)
    login_as client, scope: :client
  end

  [:review_ready_for_qr, :review_reviewing, :review_ready_for_call, :review_info_requested].each do |quality_review_state|
    context "when the return is in #{quality_review_state}" do
      let(:state) { quality_review_state }

      scenario "shows the info banner above the return card" do
        visit portal_root_path

        within "[data-testid='deadline-alert-info']" do
          expect(page).to have_text info_heading
          expect(page).to have_text info_body
        end
        within "#tax-year-2025" do
          expect(page).not_to have_css "[data-testid='deadline-alert-info']"
        end
        expect(page).not_to have_css "[data-testid='deadline-alert-warning']"
      end
    end
  end

  context "when the return is waiting for the client's signature" do
    let(:state) { :review_signature_requested }

    before do
      [DocumentTypes::UnsignedForm8879, DocumentTypes::FinalTaxDocument].each do |document_type|
        create :document,
               document_type: document_type.key,
               tax_return: tax_return,
               client: client,
               upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
      end
    end

    scenario "shows the warning banner inside the return card in place of the signature notice" do
      visit portal_root_path

      within "#tax-year-2025 [data-testid='deadline-alert-warning']" do
        expect(page).to have_text warning_heading
        expect(page).to have_text warning_body
      end
      expect(page).not_to have_text I18n.t("portal.portal2.home.calls_to_action.signature_requested_title")
      expect(page).not_to have_css "[data-testid='deadline-alert-info']"
    end

    scenario "shows the Spanish copy and date" do
      visit portal_root_path(locale: :es)

      within "[data-testid='deadline-alert-warning']" do
        expect(page).to have_text "Firme antes del 15 de octubre"
      end
    end
  end

  context "when the return is waiting for a signature but the final tax papers are not uploaded" do
    let(:state) { :review_signature_requested }

    scenario "shows the info banner" do
      visit portal_root_path

      expect(page).to have_css "[data-testid='deadline-alert-info']"
      expect(page).not_to have_css "[data-testid='deadline-alert-warning']"
    end
  end

  context "when one return needs a signature and another is in quality review" do
    let(:state) { :review_signature_requested }
    let(:other_tax_return) { build(:gyr_tax_return, :review_reviewing, year: 2024) }
    let(:client) do
      create :client,
             intake: (build :intake, preferred_name: "Randall", completed_at: DateTime.current),
             tax_returns: [tax_return, other_tax_return]
    end

    before do
      [DocumentTypes::UnsignedForm8879, DocumentTypes::FinalTaxDocument].each do |document_type|
        create :document,
               document_type: document_type.key,
               tax_return: tax_return,
               client: client,
               upload_path: Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")
      end
    end

    scenario "only shows the warning banner" do
      visit portal_root_path

      expect(page).to have_css "[data-testid='deadline-alert-warning']", count: 1
      expect(page).not_to have_css "[data-testid='deadline-alert-info']"
    end
  end

  context "when the return is not in quality review" do
    let(:state) { :prep_preparing }

    scenario "shows no banner" do
      visit portal_root_path

      expect(page).not_to have_css "[data-testid^='deadline-alert']"
    end
  end

  context "before the end of open intake" do
    let(:now) { eastern.parse("2026-09-30 12:00:00") }

    scenario "shows no banner" do
      visit portal_root_path

      expect(page).not_to have_css "[data-testid^='deadline-alert']"
    end
  end

  context "after the end of finishing in-progress intakes" do
    let(:now) { eastern.parse("2026-10-16 00:00:01") }

    scenario "shows no banner" do
      visit portal_root_path

      expect(page).not_to have_css "[data-testid^='deadline-alert']"
    end
  end
end
