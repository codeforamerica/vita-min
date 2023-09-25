require 'rails_helper'

RSpec.describe StateFile::Questions::ConfirmationController do
  describe "#show_xml" do
    let(:ny_intake) { create :state_file_ny_intake, primary_first_name: "Jerry" }
    let(:efile_submission) { create :efile_submission, :for_state, data_source: ny_intake }

    before do
      session[:state_file_intake] = ny_intake.to_global_id
    end

    it "returns some xml" do
      get :show_xml, params: { us_state: "ny", id: efile_submission.id }
      expect(Nokogiri::XML(response.body).at('Primary FirstName').text).to eq("Jerry")
    end
  end

  describe "#explain_calculations" do
    let(:ny_intake) { create :state_file_ny_intake, primary_first_name: "Jerry" }
    let(:efile_submission) { create :efile_submission, :for_state, data_source: ny_intake }

    render_views

    before do
      session[:state_file_intake] = ny_intake.to_global_id
    end

    it "shows a little bit about how each line was calculated" do
      get :explain_calculations, params: { us_state: "ny", id: efile_submission.id }
      expect(response.body).to include('AMT_1')
    end
  end
end
