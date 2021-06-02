require 'rails_helper'

describe Portal::StillNeedsHelpsController do
  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
  end

  describe "#update" do
    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :update

    context "with an authenticated client" do
      context "when the client has triggered still needs help" do
        let(:tax_return_in_progress) { build(:tax_return, status: :intake_in_progress, year: 2018) }
        let(:tax_return_not_filing) { build(:tax_return, status: :file_not_filing, year: 2019) }
        let(:client) { create :client, tax_returns: [tax_return_in_progress, tax_return_not_filing], triggered_still_needs_help_at: Time.now }
        before { sign_in client }

        context "client indicates they still need help" do
          let(:fake_time) { DateTime.new(2021, 1, 1) }

          it "saves answer, tax return statuses, first_unanswered_incoming_interaction_at, and clears triggered_still_needs_help_at" do
            Timecop.freeze(fake_time) { put :update, params: { still_needs_help: "yes" } }

            expect(tax_return_in_progress.reload.status).to eq "intake_in_progress"
            expect(tax_return_not_filing.reload.status).to eq "file_not_filing"
            expect(client.reload.triggered_still_needs_help_at).to be_nil
            # idea is to add a column still_needs_help with enum values "yes" "no"
            # reason: yvonne/nicole want to preserve who has been through the flow
            expect(client.still_needs_help_yes?).to eq true
            expect(client.first_unanswered_incoming_interaction_at).to eq fake_time
          end
        end

        context "client indicates they longer needs help" do
          it "keeps their statuses as not filing and adds an internal note" do
            expect {
              put :update, params: { still_needs_help: "no" }
            }.to(change(Note, :count).by(1)).and.not_to(change(tax_return, :status))

            note = Note.last
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
