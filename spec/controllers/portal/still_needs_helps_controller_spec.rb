require 'rails_helper'

describe Portal::StillNeedsHelpsController do
  describe "#update" do
    context "client still needs help" do
      let(:tax_return) { create(:tax_return, status: :intake_in_progress) }
      let(:client) { create :client, tax_returns: [tax_return], triggered_still_needs_help_at: Time.now }
      let(:fake_time) { DateTime.new(2021, 1, 1) }
      before { sign_in client }

      it "saves answer, changes tax return statuses to hold and first_unanswered_incoming_interaction_at to 0 business days, sets triggered_still_needs_help_at to nil" do
        Timecop.freeze(fake_time) { put :update, params: { still_needs_help: "yes" } }

        expect(client.reload.triggered_still_needs_help_at).to be_nil
        # idea is to add a column still_needs_help with enum values "yes" "no"
        # reason: yvonne/nicole want to preserve who has been through the flow
        expect(client.still_needs_help_yes?).to eq true
        expect(client.first_unanswered_incoming_interaction_at).to eq fake_time
        expect(tax_return.reload.status).to eq :file_hold
      end
    end

    context "client no longer needs help" do
      it "keeps their statuses as not filing and adds an internal note" do
        expect {
          put :update, params: { still_needs_help: "no" }
        }.not_to change(tax_return, :status).and change(Note, :count).by(1)

        note = Note.last
        expect(note.body).to eq "Client indicated that they no longer need tax help"
      end
    end
  end
end
