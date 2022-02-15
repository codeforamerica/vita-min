require 'rails_helper'

describe Hub::UpdateVerificationAttemptForm do
  describe "#initialize" do
    let!(:verification_attempt) { create :verification_attempt }
    let!(:user) { create :admin_user }
    subject { described_class.new(verification_attempt, user, { note: "this is a note body.", state: "approved"})}

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
  end

  describe "#save" do
    context "when required params are provided" do
      let!(:verification_attempt) { create :verification_attempt }
      let!(:user) { create :admin_user }
      subject { described_class.new(verification_attempt, user, { note: "this is a note body.", state: "approved" })}

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