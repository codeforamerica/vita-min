require 'rails_helper'

describe Portal::StillNeedsHelpsController do
  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit

    context "with an authenticated client" do
      before { sign_in client }

      context "when the client has triggered still needs help" do
        let(:client) { create :client, triggered_still_needs_help_at: Time.now, intake: build(:intake) }

        it "renders ok" do
          get :edit

          expect(response).to be_ok
        end
      end

      context "when the client has not triggered still needs help" do
        let(:client) { create :client, triggered_still_needs_help_at: nil, intake: build(:intake) }

        it "redirects to portal home" do
          get :edit

          expect(response).to redirect_to portal_root_path
        end
      end
    end
  end

  describe "#update" do
    let(:params) { { still_needs_help: "yes" } }
    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :update

    context "with an authenticated client" do
      before do
        allow(InteractionTrackingService).to receive(:record_incoming_interaction)
        allow(MixpanelService).to receive(:send_tax_return_event)
      end

      context "when the client has triggered still needs help" do
        let(:tax_return_in_progress) { build(:tax_return, :intake_in_progress, year: 2018) }
        let(:tax_return_not_filing) { build(:tax_return, :file_not_filing, year: 2019) }
        let(:client) { create :client, tax_returns: [tax_return_in_progress, tax_return_not_filing], triggered_still_needs_help_at: Time.now, intake: build(:intake) }
        let(:fake_time) { DateTime.new(2021, 1, 1) }
        before { sign_in client }

        context "client indicates they still need help" do
          it "saves answer, tax return statuses, first_unanswered_incoming_interaction_at, and clears triggered_still_needs_help_at" do
            Timecop.freeze(fake_time) { put :update, params: { still_needs_help: "yes" } }

            # updates client still needs help fields
            expect(client.reload.triggered_still_needs_help_at).to be_nil
            expect(client.still_needs_help_yes?).to eq true

            # updates tax return statuses
            expect(tax_return_in_progress.reload.state).to eq "intake_in_progress"
            expect(tax_return_not_filing.reload.state).to eq "file_hold"
            expect(MixpanelService).to have_received(:send_tax_return_event).with(tax_return_not_filing, 'status_change', { from_status: "intake_before_consent" })

            # tracks interaction
            expect(InteractionTrackingService).to have_received(:record_incoming_interaction).with(client)

            # redirects
            expect(response).to redirect_to portal_still_needs_help_upload_documents_path
          end
        end

        context "client indicates they longer needs help" do
          it "keeps their statuses as not filing and adds an internal note" do
            expect {
              Timecop.freeze(fake_time) { put :update, params: { still_needs_help: "no" } }
            }.to(change(SystemNote, :count).by(1))

            # updates client still needs help fields
            expect(client.reload.triggered_still_needs_help_at).to be_nil
            expect(client.still_needs_help_no?).to eq true

            # does not update tax return statuses
            expect(client.reload.tax_returns.pluck(:state)).to match_array %w[file_not_filing intake_in_progress]

            # tracks interaction and creates internal note
            expect(InteractionTrackingService).to have_received(:record_incoming_interaction).with(client)
            note = SystemNote.last
            expect(note.body).to eq "Client indicated that they no longer need tax help"

            # redirects
            expect(response).to redirect_to portal_still_needs_help_no_longer_needs_help_path
          end
        end
      end

      context "when the client has not triggered still needs help" do
        let(:client) { create :client, triggered_still_needs_help_at: nil }
        before { sign_in client }

        it "does nothing and redirects to portal home" do
          put :update, params: { still_needs_help: "irrelevant" }

          expect(response).to redirect_to portal_root_path
        end
      end
    end
  end

  describe "#chat_later" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :chat_later
  end

  describe "#no_longer_needs_help" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :no_longer_needs_help
  end

  describe "#experience_survey" do
    let(:params) { { client: { experience_survey: "neutral" } } }
    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :experience_survey

    context "with an authenticated client" do
      let(:client) { create :client_with_intake_and_return }
      before { sign_in client }

      it "updates client's experience_survey value and reloads the page" do
        put :experience_survey, params: params

        expect(client.reload.experience_survey_neutral?).to eq true
        expect(response).to redirect_to(portal_still_needs_help_no_longer_needs_help_path)
      end
    end
  end
end
