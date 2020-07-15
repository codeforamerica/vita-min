require "rails_helper"

RSpec.describe SendIntakePdfToZendeskJob, type: :job do
  let(:fake_zendesk_intake_service) { instance_double(ZendeskIntakeService) }

  before do
    allow(ZendeskIntakeService).to receive(:new).and_return fake_zendesk_intake_service
    allow(fake_zendesk_intake_service).to receive(:send_preliminary_intake_and_consent_pdfs).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:assign_requester).and_return(true)
  end

  describe "#perform" do
    let(:intake_ticket_id) { rand(2**(8 * 7)) }
    let(:intake) do
      create :intake,
             intake_pdf_sent_to_zendesk: intake_pdf_sent_to_zendesk,
             intake_ticket_id: intake_ticket_id
    end

    context "without errors" do
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

        it "sends the intake pdf and the consent pdf to the intake ticket" do
          expect(ZendeskIntakeService).to have_received(:new).with(intake)
          expect(fake_zendesk_intake_service).to have_received(:send_preliminary_intake_and_consent_pdfs)
          intake.reload
          expect(intake.intake_pdf_sent_to_zendesk).to eq true
        end

        it "creates a completed_intake_questions client_effort for the intake" do
          client_effort = ClientEffort.last
          expect(client_effort.effort_type_completed_intake_questions?).to eq true
          expect(client_effort.intake).to eq intake
          expect(client_effort.ticket_id).to eq intake.intake_ticket_id
          expect(client_effort.made_at).to be_within(1.second).of(Time.now)
        end
      end
    end

    it_behaves_like "catches exceptions with raven context", :send_preliminary_intake_and_consent_pdfs do
      let(:intake_pdf_sent_to_zendesk) { false }
    end
    it_behaves_like "a ticket-dependent job", ZendeskIntakeService
  end
end
