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
      end

      let(:intake) { create :intake, intake_ticket_id: 1234 }
      let(:client) { intake.client }

      it "adds the initial 13614-C PDF as a Document", active_job: true do
        # TODO: test that this calls the "after save trigger" that creates the doc
        expect { post :update, params: params }.to change(Document, :count).by(1)
        expect(intake).to have_received(:pdf)

        doc = Document.last
        expect(doc.intake).to eq(intake)
        expect(doc.client).to eq(client)
        expect(doc.document_type).to eq("Original 13614-C")
        blob = doc.upload.blob
        expect(blob.content_type).to eq("application/pdf")
        expect(blob.download).to eq("example pdf contents")
        expect(blob.filename).to eq("Original 13614-C.pdf")
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
