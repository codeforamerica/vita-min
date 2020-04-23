require "rails_helper"

RSpec.describe SendSpouseAuthDocsToZendeskJob, type: :job do
  let(:fake_zendesk_intake_service) { instance_double(ZendeskIntakeService) }

  before do
    allow(ZendeskIntakeService).to receive(:new).and_return fake_zendesk_intake_service
    allow(fake_zendesk_intake_service).to receive(:send_intake_pdf_with_spouse).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:send_consent_pdf_with_spouse).and_return(true)
  end

  describe "#perform" do
    let(:completed_intake_sent_to_zendesk) { nil }
    let(:intake) { create :intake, completed_intake_sent_to_zendesk: completed_intake_sent_to_zendesk }

    before do
      described_class.perform_now(intake.id)
    end

    context "when the primary user has not yet completed intake" do
      let(:completed_intake_sent_to_zendesk) { false }

      it "doesn't send anything" do
        expect(ZendeskIntakeService).not_to have_received(:new)
      end
    end

    context "when the primary user has already completed intake" do
      let(:completed_intake_sent_to_zendesk) { true }

      it "resends the intake pdf, consent pdf, and additional info document as comments on the intake ticket" do
        expect(ZendeskIntakeService).to have_received(:new).with(intake)
        expect(fake_zendesk_intake_service).to have_received(:send_intake_pdf_with_spouse)
        expect(fake_zendesk_intake_service).to have_received(:send_consent_pdf_with_spouse)
      end
    end
  end
end
