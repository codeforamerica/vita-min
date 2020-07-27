require "rails_helper"

RSpec.describe SendCompletedIntakeToZendeskJob, type: :job do
  let(:fake_zendesk_intake_service) { instance_double(ZendeskIntakeService) }

  before do
    allow(ZendeskIntakeService).to receive(:new).and_return fake_zendesk_intake_service
    allow(fake_zendesk_intake_service).to receive(:send_final_intake_pdf).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:send_bank_details_png).and_return(true)
    allow(fake_zendesk_intake_service).to receive(:send_all_docs).and_return(true)
  end

  describe "#perform" do
    let(:intake) do
      create :intake, intake_ticket_id: rand(2**(7 * 8))
    end

    context "without errors" do
      it "sends the intake pdf and all of the docs as comments on the intake ticket" do
        described_class.perform_now(intake.id)

        expect(ZendeskIntakeService).to have_received(:new).with(intake)
        expect(fake_zendesk_intake_service).to have_received(:send_final_intake_pdf)
        expect(fake_zendesk_intake_service).to have_received(:send_bank_details_png)
        expect(fake_zendesk_intake_service).to have_received(:send_all_docs)
        intake.reload
        expect(intake.completed_intake_sent_to_zendesk).to eq true
      end

      it "creates a new client effort" do
        expect {
          described_class.perform_now(intake.id)
        }.to change(ClientEffort, :count).by(1)

        client_effort = ClientEffort.last
        expect(client_effort.effort_type).to eq "completed_full_intake"
        expect(client_effort.intake).to eq intake
        expect(client_effort.ticket_id).to eq intake.intake_ticket_id
        expect(client_effort.made_at).to be_within(1.second).of(Time.now)
      end
    end

    context "when one of the three tasks fails" do
      before do
        allow(fake_zendesk_intake_service).to receive(:send_final_intake_pdf).and_return(false)
      end

      it "raises an error" do
        expect do
          described_class.perform_now(intake.id)
        end.to raise_error(/Unable to send everything to Zendesk/)

        expect(ZendeskIntakeService).to have_received(:new).with(intake)
        expect(fake_zendesk_intake_service).to have_received(:send_final_intake_pdf)
        expect(fake_zendesk_intake_service).to have_received(:send_bank_details_png)
        expect(fake_zendesk_intake_service).to have_received(:send_all_docs)
        intake.reload
        expect(intake.completed_intake_sent_to_zendesk).to eq false
      end
    end

    it_behaves_like "catches exceptions with raven context", :send_final_intake_pdf
    it_behaves_like "a ticket-dependent job", ZendeskIntakeService
  end
end
