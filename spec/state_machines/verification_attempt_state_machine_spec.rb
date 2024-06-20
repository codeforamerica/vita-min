require "rails_helper"

describe VerificationAttemptStateMachine do

  context "transitions" do
    context "from restricted" do
      let(:verification_attempt) { create :verification_attempt, :restricted }
      allowed_states = ["approved", "denied"]
      allowed_states.each do |state|
        it "can transition to #{state}" do
          expect(verification_attempt.transition_to(state)).to eq true
        end
      end
      (VerificationAttemptStateMachine.states - allowed_states).each do |state|
        it "cannot transition to #{state}" do
          expect(verification_attempt.transition_to(state)).to eq false
        end
      end
    end
  end
  context "after transitions" do
    let(:verification_attempt) { create :verification_attempt, :pending }
    let(:user) { create :admin_user }

    context "to pending" do
      let(:verification_attempt) { create :verification_attempt, :new }

      it "can transition from new to pending" do
        verification_attempt.transition_to!(:pending)
        expect(verification_attempt.current_state).to eq "pending"
      end

      context "when a client has a value for restricted_at set" do
        before do
          verification_attempt.client.touch(:restricted_at)
        end
        it "transitions the object to state restricted" do
          verification_attempt.transition_to!(:pending)
          expect(verification_attempt.current_state).to eq "restricted"
        end
      end
    end

    context "to restricted" do
      let!(:verification_attempt) { create :verification_attempt, :pending }
      let(:job_double) { double }

      around do |example|
        Timecop.freeze(Date.new(2021, 1, 1)) do
          example.run
        end
      end

      before do
        allow(DenyRestrictedVerificationAttemptJob).to receive(:set).with({ wait_until: 72.hours.from_now }).and_return(job_double)
        allow(job_double).to receive(:perform_later)
      end

      it "can transition from pending to restricted" do
        verification_attempt.transition_to!(:restricted)
        expect(verification_attempt.current_state).to eq "restricted"
      end

      it "enqueues a job to transition it to denied later" do
        verification_attempt.transition_to!(:restricted)
        expect(job_double).to have_received(:perform_later).with(verification_attempt.reload)
      end
    end

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
        create :efile_submission, :fraud_hold, client: verification_attempt.client, tax_return: verification_attempt.client.tax_returns.last
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

      it "transitions the clients efile submission to cancelled" do
        verification_attempt.transition_to(:denied)
        expect(verification_attempt.client.efile_submissions.last.current_state).to eq "cancelled"
      end
    end

    context "request new photos" do
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