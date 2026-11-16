require 'rails_helper'

describe TaxReturnCardHelper do
  describe "#tax_return_status_to_props" do
    (TaxReturnStateMachine.states - ['intake_before_consent']).each do |state|
      context "when the tax return is in #{state}" do
        let(:tax_return) { instance_double(TaxReturn) }

        before do
          allow(tax_return).to receive(:current_state).and_return(state)
          allow(tax_return).to receive(:ready_for_8879_signature?).and_return(false)
          allow(tax_return).to receive(:intake).and_return(Intake.new)
          allow(tax_return).to receive(:time_accepted).and_return(DateTime.now)
          allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: false))
          allow(tax_return).to receive(:signed_8879s).and_return(double(any?: false))
          allow(tax_return).to receive(:unsigned_8879s).and_return(double(any?: false))
        end

        it "returns help text to show in the client portal" do
          expect(helper.tax_return_status_to_props(tax_return)).to match(hash_including(:help_text))
        end
      end
    end

    context "when the intake was previously not routed due to all possible partners being at capacity" do
      let(:tax_return) { instance_double(TaxReturn) }
      let(:client) { build(:client, routing_method: :at_capacity) }

      before do
        allow(tax_return).to receive(:current_state).and_return(:intake_in_progress)
        allow(tax_return).to receive(:intake).and_return(intake)
        allow(intake).to receive(:client).and_return(client)
      end

      context "and they still do not have capacity" do
        let(:intake) { build(:intake,
                             zip_code: PartnerRoutingService::TESTING_AT_CAPACITY_ZIP_CODE,
                             current_step: Questions::ChatWithUsController.to_path_helper) }

        it "redirects to the At Capacity page" do
          expect(helper.tax_return_status_to_props(tax_return)[:link]).to eq Questions::AtCapacityController.to_path_helper
        end
      end

      context "but now they have capacity" do
        let(:intake) { build(:intake,
                             zip_code: "11111",
                             current_step: Questions::AtCapacityController.to_path_helper) }
        let(:partner_routing_service) { instance_double(PartnerRoutingService) }

        before do
          allow(PartnerRoutingService).to receive(:new).and_return(partner_routing_service)
          allow(partner_routing_service).to receive(:determine_partner).and_return(build(:organization))
          allow(partner_routing_service).to receive(:routing_method).and_return(:zip_code)
        end

        it "redirects to the Consent page" do
          expect(helper.tax_return_status_to_props(tax_return)[:link]).to eq Questions::ConsentController.to_path_helper
        end
      end
    end

    context "when the tax return is in review_signature_requested" do
      let(:tax_return) { instance_double(TaxReturn) }

      before do
        allow(tax_return).to receive(:current_state).and_return(:review_signature_requested)
        allow(tax_return).to receive(:intake).and_return(Intake.new)
        allow(tax_return).to receive(:time_accepted).and_return(DateTime.now)
      end

      context "when primary signature is ready and both final tax document and 8879 are present" do
        before do
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::PRIMARY_SIGNATURE).and_return(true)
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::SPOUSE_SIGNATURE).and_return(false)

          allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: true))
          allow(tax_return).to receive(:signed_8879s).and_return(double(any?: false))
          allow(tax_return).to receive(:unsigned_8879s).and_return(double(any?: true))
        end

        it "returns the primary signature action" do
          expect(helper.tax_return_status_to_props(tax_return)).to include(
                                                                     button_type: :add_signature_primary
                                                                   )
        end
      end

      context "when spouse signature is ready and both final tax document and 8879 are present" do
        before do
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::PRIMARY_SIGNATURE).and_return(false)
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::SPOUSE_SIGNATURE).and_return(true)

          allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: true))
          allow(tax_return).to receive(:signed_8879s).and_return(double(any?: true))
          allow(tax_return).to receive(:unsigned_8879s).and_return(double(any?: false))
        end

        it "returns the spouse signature action" do
          expect(helper.tax_return_status_to_props(tax_return)).to include(
                                                                     button_type: :add_signature_spouse
                                                                   )
        end
      end

      context "when the final tax document is missing" do
        before do
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::PRIMARY_SIGNATURE).and_return(true)
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::SPOUSE_SIGNATURE).and_return(false)

          allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: false))
          allow(tax_return).to receive(:signed_8879s).and_return(double(any?: false))
          allow(tax_return).to receive(:unsigned_8879s).and_return(double(any?: true))
        end

        it "returns view documents" do
          expect(helper.tax_return_status_to_props(tax_return)).to include(
                                                                     button_type: :view_documents
                                                                   )
        end
      end

      context "when the 8879 is missing" do
        before do
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::PRIMARY_SIGNATURE).and_return(true)
          allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::SPOUSE_SIGNATURE).and_return(false)

          allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: true))
          allow(tax_return).to receive(:signed_8879s).and_return(double(any?: false))
          allow(tax_return).to receive(:unsigned_8879s).and_return(double(any?: false))
        end

        it "returns view documents" do
          expect(helper.tax_return_status_to_props(tax_return)).to include(
                                                                     button_type: :view_documents
                                                                   )
        end
      end
    end
  end

  describe "#tax_return_status_to_props_2" do
    context "when the tax return is in review_signature_requested" do
      let(:primary_signature_ready) { true }
      let(:spouse_signature_ready) { false }
      let(:has_final_tax_document) { true }
      let(:tax_return) { instance_double(TaxReturn) }

      before do
        allow(tax_return).to receive(:current_state).and_return(:review_signature_requested)
        allow(tax_return).to receive(:intake).and_return(Intake.new)
        allow(tax_return).to receive(:id).and_return(42)
        allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::PRIMARY_SIGNATURE).and_return(primary_signature_ready)
        allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::SPOUSE_SIGNATURE).and_return(spouse_signature_ready)
        allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: has_final_tax_document))
      end

      context "when an unsigned 8879 and a final tax document are both present" do
        it "returns the final check badge, notice copy, download link, and primary signature buttons" do
          expect(helper.tax_return_status_to_props_2(tax_return)).to eq(
            badge_text: I18n.t("portal.portal2.home.badge.final_check"),
            help_text: I18n.t("portal.portal2.home.help_text.signature_requested_primary"),
            call_to_action_title: I18n.t("portal.portal2.home.calls_to_action.signature_requested_title"),
            call_to_action_text: I18n.t("portal.portal2.home.calls_to_action.signature_requested"),
            button_type: :sign_return,
            link: portal_tax_return_authorize_signature_path(tax_return_id: 42),
            download_final_tax_documents: true,
            return_status: :review_signature_requested
          )
        end
      end

      context "when the primary has signed a joint return and the spouse has not" do
        let(:primary_signature_ready) { false }
        let(:spouse_signature_ready) { true }

        it "points at the spouse signature flow" do
          expect(helper.tax_return_status_to_props_2(tax_return)).to include(
            button_type: :sign_return,
            link: portal_tax_return_spouse_authorize_signature_path(tax_return_id: 42),
            help_text: I18n.t("portal.portal2.home.help_text.signature_requested_spouse")
          )
        end
      end

      context "when there is no unsigned 8879 to sign" do
        let(:primary_signature_ready) { false }
        let(:spouse_signature_ready) { false }

        it "returns the view documents action" do
          expect(helper.tax_return_status_to_props_2(tax_return)).to eq(
            badge_text: I18n.t("portal.portal2.home.badge.final_check"),
            help_text: I18n.t("portal.portal2.home.help_text.review"),
            button_type: :view_documents,
            return_status: :review_signature_requested
          )
        end
      end

      context "when the final tax document has not been uploaded" do
        let(:has_final_tax_document) { false }

        it "returns the view documents action" do
          expect(helper.tax_return_status_to_props_2(tax_return)).to include(
            button_type: :view_documents,
            help_text: I18n.t("portal.portal2.home.help_text.review")
          )
        end
      end
    end
  end

  describe "#tax_season_deadline_banner" do
    let(:in_window) { true }
    let(:state) { :review_reviewing }
    let(:signature_ready) { true }
    let(:has_final_tax_document) { true }
    let(:tax_return) { instance_double(TaxReturn) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:open_for_finishing_in_progress_intakes?).and_return(in_window)
      end
      allow(tax_return).to receive(:current_state).and_return(state)
      allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::PRIMARY_SIGNATURE).and_return(signature_ready)
      allow(tax_return).to receive(:ready_for_8879_signature?).with(TaxReturn::SPOUSE_SIGNATURE).and_return(false)
      allow(tax_return).to receive(:final_tax_documents).and_return(double(any?: has_final_tax_document))
    end

    [:review_ready_for_qr, :review_reviewing, :review_ready_for_call, :review_info_requested].each do |quality_review_state|
      context "when the tax return is in #{quality_review_state}" do
        let(:state) { quality_review_state }

        it "returns :check_for_updates" do
          expect(helper.tax_season_deadline_banner(tax_return)).to eq :check_for_updates
        end
      end
    end

    context "when the tax return is ready for the client to sign" do
      let(:state) { :review_signature_requested }

      it "returns :sign" do
        expect(helper.tax_season_deadline_banner(tax_return)).to eq :sign
      end
    end

    context "when a signature is requested but the final tax document is missing" do
      let(:state) { :review_signature_requested }
      let(:has_final_tax_document) { false }

      it "returns :check_for_updates" do
        expect(helper.tax_season_deadline_banner(tax_return)).to eq :check_for_updates
      end
    end

    context "when the tax return is outside quality review" do
      let(:state) { :prep_preparing }

      it "returns nil" do
        expect(helper.tax_season_deadline_banner(tax_return)).to be_nil
      end
    end

    context "when it is outside the finishing in-progress intakes window" do
      let(:in_window) { false }

      it "returns nil" do
        expect(helper.tax_season_deadline_banner(tax_return)).to be_nil
      end
    end
  end

  describe "#tax_season_deadline_date" do
    before do
      allow(Rails.configuration).to receive(:end_of_in_progress_intake)
        .and_return(Time.find_zone("America/New_York").parse("2026-10-15 23:59:59"))
    end

    it "formats the end of in-progress intake date" do
      expect(helper.tax_season_deadline_date).to eq "October 15"
      expect(I18n.with_locale(:es) { helper.tax_season_deadline_date }).to eq "15 de octubre"
    end
  end
end