require "rails_helper"

describe VerificationAttemptStateMachine do
  context "after transitions" do
    let(:verification_attempt) { create :verification_attempt }
    let(:user) { create :admin_user }

    context "to approved" do
      before do
        verification_attempt.client.touch(:identity_verification_denied_at)
      end

      it "sets identity_verified_at onto the associated client" do
        verification_attempt.transition_to(:approved)
        expect(verification_attempt.client.identity_verified_at).not_to be_nil
        expect(verification_attempt.client.identity_verification_denied_at).to be_nil
      end
    end

    context "to denied" do
      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
        verification_attempt.client.touch(:identity_verified_at)
      end

      it "sets identity_verification_denied_at onto the associated client" do
        verification_attempt.transition_to(:denied)
        expect(verification_attempt.client.identity_verification_denied_at).not_to be_nil
        expect(verification_attempt.client.identity_verified_at).to be_nil

      end

      it "sends a message to the client" do
        verification_attempt.transition_to(:denied)
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: verification_attempt.client,
          locale: verification_attempt.client.intake.locale,
          message: AutomatedMessage::VerificationAttemptDenied
        )
      end
    end

    context " request new photos" do
      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      end

      it "sends a message to the client" do
        verification_attempt.transition_to(:requested_replacements)
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: verification_attempt.client,
          locale: verification_attempt.client.intake.locale,
          message: AutomatedMessage::NewPhotosRequested
        )
      end

    end
  end
end