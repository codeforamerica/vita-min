require "rails_helper"

describe TaxReturnStateMachine do
  describe "#last_changed_by" do
    context "when the last transition includes an initiated_by_user_id" do
      let(:tax_return) { create :gyr_tax_return, :prep_ready_for_prep, metadata: { initiated_by_user_id: (create :user).id}}

      it "returns an instance of user" do
        expect(tax_return.last_changed_by).to be_an_instance_of User
      end
    end

    context "when the last transition does not include an initiated_by_user_id" do
      let(:tax_return) { create :gyr_tax_return, :prep_ready_for_prep }

      it "is nil" do
        expect(tax_return.last_changed_by).to be nil
      end
    end
  end

  describe "#previous_transition" do
    before do
      allow(MixpanelService).to receive(:send_tax_return_event)
    end

    context "when there are no transitions" do
      let(:tax_return) { create :gyr_tax_return }
      it "responds with nil" do
        expect(tax_return.current_state).to eq "intake_before_consent"
        expect(tax_return.previous_transition).to eq nil
      end
    end

    context "when there is only one transition" do
      let(:tax_return) { create :gyr_tax_return, :intake_in_progress }
      it "responds with nil" do
        expect(tax_return.current_state).to eq "intake_in_progress"
        expect(tax_return.previous_transition).to eq nil
      end
    end

    context "when there are multiple transitions" do
      let(:tax_return) { create :gyr_tax_return, :prep_ready_for_prep }

      before do
        tax_return.transition_to(:file_efiled)
      end

      it "provides the second to last" do
        expect(tax_return.current_state).to eq "file_efiled"
        expect(tax_return.previous_transition.to_state).to eq "prep_ready_for_prep"
      end
    end
  end

  describe ".available_states_for" do
    context "when role_type is GreeterRole type" do
      it "only provides limited statuses" do
        result = described_class.available_states_for(role_type: GreeterRole::TYPE)
        expect(result.keys.length).to eq 2
        expect(result.keys.first).to eq "intake"
        expect(result.keys.last).to eq "file"
        expect(result["intake"]).to eq [
          "intake_ready",
          "intake_greeter_info_requested",
          "intake_needs_doc_help"
        ]
        expect(result["file"]).to eq ["file_not_filing", "file_hold"]
      end
    end

    context "when role is anything else" do
      it "provides all statuses" do
        result = described_class.available_states_for(role_type: AdminRole::TYPE)
        expect(result).to eq TaxReturnStateMachine::STATES_BY_STAGE
      end
    end
  end

  describe ".states_to_show_for_client_filter" do
    context "when role_type is GreeterRole type" do
      it "only provides limited not including the excluded few" do
        result = described_class.states_to_show_for_client_filter(role_type: GreeterRole::TYPE)
        expect(result.keys.length).to eq 2
        expect(result.keys.first).to eq "intake"
        expect(result.keys.last).to eq "file"
        expect(result["intake"]).to eq [
                                         "intake_ready",
                                         "intake_greeter_info_requested",
                                         "intake_needs_doc_help"
                                       ]
        expect(result["file"]).to eq ["file_not_filing", "file_hold"]
        expect(result.values.flatten).not_to include("file_fraud_hold", "file_needs_review")
      end
    end

    context "when role is anything else" do
      it "provides all statuses except the excluded few" do
        result = described_class.states_to_show_for_client_filter(role_type: AdminRole::TYPE)

        expect(result["file"]).to eq ["file_ready_to_file", "file_efiled", "file_mailed", "file_rejected", "file_accepted", "file_not_filing", "file_hold"]
        expect(result["intake"]).to eq ["intake_in_progress", "intake_needs_doc_help", "intake_info_requested", "intake_greeter_info_requested", "intake_ready", "intake_reviewing", "intake_ready_for_call"]
        expect(result["prep"]).to eq ["prep_ready_for_prep", "prep_preparing", "prep_info_requested"]
        expect(result["review"]).to eq ["review_ready_for_qr", "review_reviewing", "review_ready_for_call", "review_signature_requested", "review_info_requested"]
        expect(result.values.flatten).not_to include("file_fraud_hold", "file_needs_review")
      end
    end
  end

  context "transitions" do
    let(:tax_return) { create(:gyr_tax_return) }

    it "updates the filterable properties" do
      expect do
        tax_return.transition_to!(:file_accepted)
      end.to change { tax_return.reload.client.filterable_tax_return_properties }.from([a_hash_including("current_state" => "intake_before_consent")]).to([a_hash_including("current_state" => "file_accepted")])
    end

    context "to file_accepted" do
      before do
        allow(MixpanelService).to receive(:send_file_completed_event)
      end

      it "sets current_state and status as well" do
        tax_return.transition_to(:file_accepted)
        expect(tax_return.current_state).to eq "file_accepted"
      end

      it "sends a Mixpanel event" do
        tax_return.transition_to(:file_accepted)
        expect(MixpanelService).to have_received(:send_file_completed_event).with(tax_return, "filing_completed")
      end
    end

    context "to file_mailed" do
      before do
        allow(MixpanelService).to receive(:send_tax_return_event)
      end

      it "sends a mixpanel event" do
        tax_return.transition_to(:file_mailed)
        expect(MixpanelService).to have_received(:send_tax_return_event).with(tax_return, "filing_filed", { filing_type: "mail"})
      end
    end

    context "to file_rejected" do
      before do
        allow(MixpanelService).to receive(:send_file_completed_event)
      end

      it "sends a mixpanel event" do
        tax_return.transition_to(:file_rejected)
        expect(MixpanelService).to have_received(:send_file_completed_event).with(tax_return, "filing_rejected")
      end
    end

    context "to file_not_filing" do
      before do
        allow(MixpanelService).to receive(:send_file_completed_event)
      end

      it "sends a mixpanel event" do
        tax_return.transition_to(:file_not_filing)
        expect(MixpanelService).to have_received(:send_file_completed_event).with(tax_return, "not_filing")
      end
    end

    context "to file_efiled" do
      before do
        allow(MixpanelService).to receive(:send_tax_return_event)
      end

      it "sends a mixpanel event" do
        tax_return.transition_to(:file_efiled)
        expect(MixpanelService).to have_received(:send_tax_return_event).with(tax_return, "filing_filed", filing_type: "efile" )
      end
    end

    context "to prep_ready_for_prep" do
      before do
        allow(MixpanelService).to receive(:send_tax_return_event)
      end

      it "sends a mixpanel event" do
        tax_return.transition_to(:prep_ready_for_prep)
        expect(MixpanelService).to have_received(:send_tax_return_event).with(tax_return, "ready_for_prep")
      end
    end
  end
end
