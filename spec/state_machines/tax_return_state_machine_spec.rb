require "rails_helper"

describe TaxReturnStateMachine do
  describe "#last_changed_by" do
    context "when the last transition includes an initiated_by_user_id" do
      let(:tax_return) { create :tax_return, :prep_ready_for_prep, metadata: { initiated_by_user_id: (create :user).id}}

      it "returns an instance of user" do
        expect(tax_return.last_changed_by).to be_an_instance_of User
      end
    end

    context "when the last transition does not include an initiated_by_user_id" do
      let(:tax_return) { create :tax_return, :prep_ready_for_prep }

      it "is nil" do
        expect(tax_return.last_changed_by).to be nil
      end
    end
  end

  describe "#previous_transition" do
    before do
      allow(MixpanelService).to receive(:send_status_change_event)
    end

    context "when there are no transitions" do
      let(:tax_return) { create :tax_return }
      it "responds with nil" do
        expect(tax_return.current_state).to eq "intake_before_consent"
        expect(tax_return.previous_transition).to eq nil
      end
    end

    context "when there is only one transition" do
      let(:tax_return) { create :tax_return, :intake_in_progress }
      it "responds with nil" do
        expect(tax_return.current_state).to eq "intake_in_progress"
        expect(tax_return.previous_transition).to eq nil
      end
    end

    context "when there are multiple transitions" do
      let(:tax_return) { create :tax_return, :prep_ready_for_prep }

      before do
        tax_return.transition_to(:file_efiled)
      end

      it "provides the second to last" do
        expect(tax_return.current_state).to eq "file_efiled"
        expect(tax_return.previous_transition.to_state).to eq "prep_ready_for_prep"
      end
    end
  end
end