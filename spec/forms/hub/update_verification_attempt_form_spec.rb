require 'rails_helper'

describe Hub::UpdateVerificationAttemptForm do
  subject { described_class.new(verification_attempt, user, { note: "this is a note body.", state: "approved" })}

  let!(:verification_attempt) { create :verification_attempt }

  describe "#initialize" do

    let!(:user) { create :admin_user }

    it "assigns passed params as accessible attrs on the form object" do
      expect(subject.note).to eq "this is a note body."
      expect(subject.state).to eq "approved"
    end
  end

  describe "validations" do
    subject { described_class.new(verification_attempt, user, params) }

    let!(:verification_attempt) { create :verification_attempt }
    let!(:user) { create :admin_user }
    let(:params) do
      {
        note: "this is a note body.",
        state: "approved"
      }
    end

    context "state" do
      context "without a state indicated" do
        before do
          params[:state] = nil
        end

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:state]).to include "Can't be blank."
        end
      end

      context "with a state indicated" do
        it "is valid" do
          expect(subject).to be_valid
          expect(subject.errors[:state]).to eq []
        end
      end
    end

    context "note" do
      context "when state is escalated" do
        let(:params) do
          {
              note: "",
              state: "escalated"
          }
        end

        it "requires a note" do
          expect(subject).not_to be_valid
          expect(subject.errors[:note]).to include "A note is required when escalating a verification attempt."
        end
      end

      context "when state is approved" do
        context "when there is a client bypass request" do
          before do
            verification_attempt.update(client_bypass_request: "I do not have ID.")
          end
          let(:params) do
            {
                note: "",
                state: "approved",
            }
          end
          it "requires a note" do
            expect(subject).not_to be_valid
            expect(subject.errors[:note]).to include "A note is required when approving a client with a bypass request."
          end
        end

        context "when there is no client bypass request" do
          let(:params) do
            {
                note: "",
                state: "approved",
            }
          end
          it "is valid without the presence of a note" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end

  describe "#can_handle_escalations?" do
    context "when the current user is an admin" do
      let!(:user) { create :admin_user }
      it "returns true" do
        expect(subject.can_handle_escalations?).to eq true
      end
    end

    context "when the current user is client success role" do
      let!(:user) { create :client_success_user }
      it "returns true" do
        expect(subject.can_handle_escalations?).to eq true
      end
    end

    context "when any other role" do
      let!(:user) { create :organization_lead_user }
      it "returns false" do
        expect(subject.can_handle_escalations?).to eq false
      end
    end
  end

  describe "#save" do
    context "when required params are provided" do
      let!(:verification_attempt) { create :verification_attempt }
      let!(:user) { create :admin_user }

      it "increases the verification transitions count by 1" do
        expect {
          subject.save
        }.to change(verification_attempt.transitions, :count).by 1

      end

      it "persists the current_user onto the transition as the initiating user, and persists the provided body" do
        subject.save
        transition = verification_attempt.transitions.last
        expect(transition.initiated_by).to eq user
        expect(transition.note).to eq "this is a note body."
        expect(transition.to_state).to eq "approved"
      end
    end
  end
end