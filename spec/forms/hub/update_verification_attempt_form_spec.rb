require 'rails_helper'

describe Hub::UpdateVerificationAttemptForm do
  describe "#initialize" do
    let!(:verification_attempt) { create :verification_attempt }
    let!(:user) { create :admin_user }
    subject { described_class.new(verification_attempt, user, { body: "this is a note body."})}
    it "assigns passed params as accessible attrs on the form object" do
      expect(subject.body).to eq "this is a note body."
    end
  end

  describe "#save" do
    context "when a body param is provided" do
      let!(:verification_attempt) { create :verification_attempt }
      let!(:user) { create :admin_user }
      subject { described_class.new(verification_attempt, user, { body: "this is a note body."})}

      it "increases the verification attempt note count by 1" do
        expect {
          subject.save
        }.to change(verification_attempt.verification_attempt_notes, :count).by 1

      end

      it "persists the current_user onto the verification_note as the creating user, and persists the provided body" do
        subject.save
        verification_attempt = verification_attempt.verification_attempt_notes.last
      end
    end
  end
end