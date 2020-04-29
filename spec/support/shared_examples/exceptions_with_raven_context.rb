shared_examples "catches exceptions with raven context" do |action|
  context "when error occurs" do
    it "sends the intake ticket_id to Sentry" do
      allow(fake_zendesk_intake_service).to receive(action)
        .and_raise("Test Error")
      expect(Raven).to receive(:capture_exception)
        .with(instance_of(RuntimeError), extra: {ticket_id: intake.intake_ticket_id })
      described_class.perform_now(intake.id)
    end
  end
end


