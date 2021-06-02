require 'rails_helper'

describe Portal::StillNeedsHelpsController do
  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
  end

  describe "#update" do
    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :update

    context "with an authenticated client" do
      before do
        allow(InteractionTrackingService).to receive(:record_incoming_interaction)
        allow(MixpanelService).to receive(:send_status_change_event)
      end

      context "when the client has triggered still needs help" do
        let(:tax_return_in_progress) { build(:tax_return, status: :intake_in_progress, year: 2018) }
        let(:tax_return_not_filing) { build(:tax_return, status: :file_not_filing, year: 2019) }
        let(:client) { create :client, tax_returns: [tax_return_in_progress, tax_return_not_filing], triggered_still_needs_help_at: Time.now, intake: build(:intake) }
        let(:fake_time) { DateTime.new(2021, 1, 1) }
        before { sign_in client }

        context "client indicates they still need help" do
          it "saves answer, tax return statuses, first_unanswered_incoming_interaction_at, and clears triggered_still_needs_help_at" do
            Timecop.freeze(fake_time) { put :update, params: { still_needs_help: "yes" } }

            expect(tax_return_in_progress.reload.status).to eq "intake_in_progress"
            expect(tax_return_not_filing.reload.status).to eq "file_hold"
            expect(client.reload.triggered_still_needs_help_at).to be_nil
            expect(client.still_needs_help_yes?).to eq true
            expect(InteractionTrackingService).to have_received(:record_incoming_interaction).with(client)
            expect(MixpanelService).to have_received(:send_status_change_event).with(tax_return_not_filing)
          end
        end

        context "client indicates they longer needs help" do
          it "keeps their statuses as not filing and adds an internal note" do
            expect {
              Timecop.freeze(fake_time) { put :update, params: { still_needs_help: "no" } }
            }.to(change(SystemNote, :count).by(1))
            expect(client.reload.tax_returns.pluck(:status)).to match_array %w[file_not_filing intake_in_progress]
            expect(InteractionTrackingService).to have_received(:record_incoming_interaction).with(client)

            note = SystemNote.last
            expect(note.body).to eq "Client indicated that they no longer need tax help"
          end
        end
      end

      context "when the client has not triggered still needs help" do
        let(:tax_return_in_progress) { build(:tax_return, status: :intake_in_progress, year: 2018) }
        let(:tax_return_not_filing) { build(:tax_return, status: :file_not_filing, year: 2019) }
        let(:client) { create :client, tax_returns: [tax_return_in_progress, tax_return_not_filing], triggered_still_needs_help_at: nil }
        before { sign_in client }

        context "client indicates they still need help" do
          let(:fake_time) { DateTime.new(2021, 1, 1) }

          it "makes no changes and redirects to /yes" do
            expect { put :update, params: { still_needs_help: "yes" } }.not_to change(Note, :count)

            expect(tax_return_in_progress.reload.status).to eq "intake_in_progress"
            expect(tax_return_not_filing.reload.status).to eq "file_not_filing"
            expect(client.reload.triggered_still_needs_help_at).to be_nil
            expect(client.still_needs_help).to eq "unfilled"
            expect(response).to redirect_to(portal_still_needs_help_yes_path)
          end
        end

        context "client indicates they longer needs help" do
          it "makes no changes and redirects to /no" do
            expect {
              put :update, params: { still_needs_help: "no" }
            }.not_to change(Note, :count)
            expect(tax_return_in_progress.reload.status).to eq "intake_in_progress"
            expect(tax_return_not_filing.reload.status).to eq "file_not_filing"
            expect(client.reload.triggered_still_needs_help_at).to be_nil
            expect(client.still_needs_help).to eq "unfilled"
            expect(response).to redirect_to(portal_still_needs_help_no_path)
          end
        end
      end
    end
  end
end
