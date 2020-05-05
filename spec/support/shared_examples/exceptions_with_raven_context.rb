shared_examples "catches exceptions with raven context" do |action|
  context "when error occurs" do
    it "sends the intake ticket_id to Sentry" do
      allow(fake_zendesk_intake_service).to receive(action)
        .and_raise("Test Error")
      expect(Raven).to receive(:extra_context)
        .with(hash_including(ticket_id: intake.intake_ticket_id))
      expect { described_class.perform_now(intake.id) }
        .to raise_error(/Test Error/)
    end
  end
end


