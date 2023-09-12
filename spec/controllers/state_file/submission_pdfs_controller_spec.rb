require "rails_helper"

RSpec.describe StateFile::SubmissionPdfsController do
  include PdfSpecHelper

  describe "#show" do
    let(:ny_intake) { create :state_file_ny_intake, primary_ssn: "222334444" }
    let(:efile_submission) { create :efile_submission, :for_state, data_source: ny_intake }

    before do
      allow(CreateSubmissionPdfJob).to receive(:perform_now).and_call_original
    end

    context "when the pdf has already been created" do
      before do
        ny_intake.submission_pdf.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "it201.pdf")),
          filename: 'it201.pdf',
          content_type: 'application/pdf'
        )
      end

      it "shows the pdf" do
        get :show, params: { id: efile_submission.id }

        expect(CreateSubmissionPdfJob).not_to have_received(:perform_now)

        tempfile = Tempfile.new('output.pdf')
        tempfile.write(response.body)
        expect(filled_in_values(tempfile.path)).to match(a_hash_including("TP_first_name" => "Jerry"))
      end
    end

    context "when the pdf has not been created" do
      it "creates the pdf and then shows it" do
        get :show, params: { id: efile_submission.id }

        expect(CreateSubmissionPdfJob).to have_received(:perform_now)

        tempfile = Tempfile.new('output.pdf')
        tempfile.write(response.body)
        expect(filled_in_values(tempfile.path)).to match(a_hash_including("TP_first_name" => "Jerry"))
      end
    end
  end
end