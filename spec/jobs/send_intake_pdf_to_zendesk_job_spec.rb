require "rails_helper"

RSpec.describe SendIntakePdfToZendeskJob, type: :job do
  let(:fake_zendesk_intake_service) { instance_double(ZendeskIntakeService) }

  before do
    allow(ZendeskIntakeService).to receive(:new).and_return fake_zendesk_intake_service
    allow(fake_zendesk_intake_service).to receive(:send_intake_pdf).and_return(true)
  end

  describe "#perform" do
    let(:intake) do
      create :intake, intake_pdf_sent_to_zendesk: intake_pdf_sent_to_zendesk
    end

    before do
      described_class.perform_now(intake.id)
    end

    context "when pdf has already been sent" do
      let(:intake_pdf_sent_to_zendesk) { true }

      it "does not send it again" do
        expect(ZendeskIntakeService).not_to have_received(:new)
      end
    end

    context "when pdf has not been sent" do
      let(:intake_pdf_sent_to_zendesk) { false }

      it "sends the pdf as a comment on the intake ticket" do
        expect(ZendeskIntakeService).to have_received(:new).with(intake)
        expect(fake_zendesk_intake_service).to have_received(:send_intake_pdf)
        intake.reload
        expect(intake.intake_pdf_sent_to_zendesk).to eq true
      end
    end
  end
end
