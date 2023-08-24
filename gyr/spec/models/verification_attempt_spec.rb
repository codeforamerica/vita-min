# == Schema Information
#
# Table name: verification_attempts
#
#  id                    :bigint           not null, primary key
#  client_bypass_request :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  client_id             :bigint
#
# Indexes
#
#  index_verification_attempts_on_client_id  (client_id)
#
require 'rails_helper'

RSpec.describe VerificationAttempt, type: :model do
  context "validations" do
    let(:client) { create :client, intake: (build :ctc_intake) }
    context "only one open attempt at a time" do
      open_states = ["new", "pending", "escalated", "restricted"]
      open_states.each do |state|
        context "when the client has an attempt in #{state} state" do
          before do
            create :verification_attempt, state.to_sym, client: client
          end

          it "adds an error to the object" do
            new_attempt = build :verification_attempt, :pending, client: client
            expect(new_attempt.valid?).to eq false
            expect(new_attempt.errors[:client]).to include("only one open attempt is allowed per client")
          end
        end
      end

      closed_states = VerificationAttemptStateMachine.states - open_states
      closed_states.each do |state|
        context "when the client is in #{state} state" do
          before do
            create :verification_attempt, state.to_sym, client: client
          end

          it "is valid to create another object" do
            new_attempt = build :verification_attempt, :pending, client: client
            expect(new_attempt.valid?).to eq true
          end
        end
      end
    end

    context "validate both document file types" do
      context "type is html (invalid)" do
        it "adds an error" do
          verification_attempt = build :verification_attempt
          verification_attempt.selfie.attach(
            io: File.open(Rails.root.join("spec", "fixtures", "files", "test-pattern.html")),
            filename: 'test-pattern.html',
            content_type: 'text/html'
          )
          verification_attempt.photo_identification.attach(
            io: File.open(Rails.root.join("spec", "fixtures", "files", "test-pattern.html")),
            filename: 'test-pattern.html',
            content_type: 'text/html'
          )

          expect(verification_attempt.valid?).to eq false
          expect(verification_attempt.errors[:selfie]).to include(I18n.t("validators.file_type", valid_types: FileTypeAllowedValidator.extensions(VerificationAttempt).to_sentence))
          expect(verification_attempt.errors[:photo_identification]).to include(I18n.t("validators.file_type", valid_types: FileTypeAllowedValidator.extensions(VerificationAttempt).to_sentence))
        end
      end

      context "type is jpg (valid)" do
        it "does not add an error" do
          verification_attempt = build :verification_attempt

          expect(verification_attempt.valid?).to eq true
          expect(verification_attempt.errors[:selfie]).to be_empty
          expect(verification_attempt.errors[:photo_identification]).to be_empty
        end
      end
    end
  end
end
