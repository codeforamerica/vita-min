require "rails_helper"

RSpec.describe SendCompletedIntakeToZendeskJob, type: :job do
  let(:fake_zendesk_intake_service) { instance_double(ZendeskIntakeService) }

  before do
    allow(ZendeskIntakeService).to receive(:new).and_return fake_zendesk_intake_service
    allow(fake_zendesk_intake_service).to receive(:send_final_intake_pdf).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:send_consent_pdf).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:send_additional_info_document).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:send_all_docs).and_return(true)
  end

  describe "#perform" do
    let(:intake) do
      create :intake
    end

    before do
      described_class.perform_now(intake.id)
    end

    it "sends the intake pdf and all of the docs as comments on the intake ticket" do
      expect(ZendeskIntakeService).to have_received(:new).with(intake)
      expect(fake_zendesk_intake_service).to have_received(:send_final_intake_pdf)
      expect(fake_zendesk_intake_service).to have_received(:send_consent_pdf)
      expect(fake_zendesk_intake_service).to have_received(:send_additional_info_document)
      expect(fake_zendesk_intake_service).to have_received(:send_all_docs)
      intake.reload
      expect(intake.completed_intake_sent_to_zendesk).to eq true
    end
  end
end
