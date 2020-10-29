require "rails_helper"

RSpec.describe Questions::FinalInfoController do
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    let(:params) do
      { final_info_form: { final_info: "I moved here from Alaska." } }
    end

    context "for any intake" do
      before do
        example_pdf = Tempfile.new("example.pdf")
        example_pdf.write("example pdf contents")
        allow(intake).to receive(:pdf).and_return(example_pdf)
        allow(intake).to receive(:create_original_13614c_document)
      end

      let(:intake) { create :intake, intake_ticket_id: 1234 }
      let(:client) { intake.client }

      it "should trigger the creation of the 13614c document" do
        post :update, params: params
        expect(intake).to have_received(:create_original_13614c_document)
      end
    end

    context "for a full intake" do
      before do
        example_pdf = Tempfile.new("example.pdf")
        example_pdf.write("example pdf contents")
        allow(intake).to receive(:pdf).and_return(example_pdf)
      end

      let(:intake) { create :intake, intake_ticket_id: 1234 }

      it "enqueues a job to update the zendesk ticket", active_job: true do
        post :update, params: params

        expect(SendCompletedIntakeToZendeskJob).to have_been_enqueued.with(intake.id)
        expect(SendCompletedEipIntakeToZendeskJob).not_to have_been_enqueued
      end

      it "updates completed_intake_at" do
        post :update, params: params

        expect(intake.completed_at).to be_within(2.seconds).of(Time.now)
      end
    end

    context "for an EIP-only intake" do
      let(:intake) { create :intake, :eip_only, intake_ticket_id: 1234 }

      it "enqueues a job to update the zendesk ticket", active_job: true do
        post :update, params: params

        expect(SendCompletedEipIntakeToZendeskJob).to have_been_enqueued.with(intake.id)
        expect(SendCompletedIntakeToZendeskJob).not_to have_been_enqueued
      end
    end
  end
end
