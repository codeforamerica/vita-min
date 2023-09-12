require "rails_helper"

RSpec.describe StateFile::Questions::SubmissionPdfsController do
  include PdfSpecHelper

  describe "#show" do
    let(:ny_intake) { create :state_file_ny_intake, primary_first_name: "Jerry" }
    let(:efile_submission) { create :efile_submission, :for_state, data_source: ny_intake }

    before do
      session[:state_file_intake] = ny_intake.to_global_id
      allow(CreateSubmissionPdfJob).to receive(:perform_now).and_call_original
    end

    it "creates the pdf and then shows it" do
      get :show, params: { us_state: "ny", id: efile_submission.id }

      tempfile = Tempfile.new(['output', '.pdf'])
      tempfile.write(response.body)
      expect(filled_in_values(tempfile.path)).to match(a_hash_including("TP_first_name" => "Jerry"))
    end
  end
end