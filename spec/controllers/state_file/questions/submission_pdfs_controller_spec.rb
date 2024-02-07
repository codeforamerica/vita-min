require "rails_helper"

RSpec.describe StateFile::Questions::SubmissionPdfsController do
  include PdfSpecHelper

  describe "#show" do
    context "NY" do
      let(:ny_intake) { create :state_file_ny_intake, primary_first_name: "Jerry" }
      let(:efile_submission) { create :efile_submission, :for_state, data_source: ny_intake }

      before do
        sign_in ny_intake
      end

      it "creates the pdf and then shows it" do
        get :show, params: { us_state: "ny", id: efile_submission.id }

        tempfile = Tempfile.new(['output', '.pdf'])
        tempfile.write(response.body)
        expect(filled_in_values(tempfile.path)).to match(a_hash_including("TP_first_name" => "Jerry"))
      end
    end

    context "AZ" do
      let(:az_intake) { create :state_file_az_intake, primary_first_name: "Jerry", primary_middle_initial: "L" }
      let(:efile_submission) { create :efile_submission, :for_state, data_source: az_intake }

      before do
        sign_in az_intake
      end

      it "creates the pdf and then shows it" do
        get :show, params: { us_state: "az", id: efile_submission.id }

        tempfile = Tempfile.new(['output', '.pdf'])
        tempfile.write(response.body)
        expect(filled_in_values(tempfile.path)).to match(a_hash_including("1a" => "Jerry L"))
      end
    end
  end
end