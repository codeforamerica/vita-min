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
        get :show, params: { id: efile_submission.id }

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
        get :show, params: { id: efile_submission.id }

        tempfile = Tempfile.new(['output', '.pdf'])
        tempfile.write(response.body)
        expect(filled_in_values(tempfile.path)).to match(a_hash_including("1a" => "Jerry L"))
      end

      context "when it is after closing" do
        around do |example|
          Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
            example.run
          end
        end
        it "does not redirect them to the about page" do
          get :show, params: { id: efile_submission.id }
          expect(response).not_to have_http_status(:redirect)
        end
      end
    end
  end
end