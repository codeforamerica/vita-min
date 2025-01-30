require 'rails_helper'

RSpec.describe StateFile::Questions::ConfirmationController do
  describe "#show_xml" do
    context "in az" do
      let(:az_intake) do
        create(
          :state_file_az_intake,
          :with_efile_device_infos,
          primary_first_name: "Jerry",
        )
      end
      let(:efile_submission) { create :efile_submission, :for_state, data_source: az_intake }

      before do
        sign_in az_intake
      end

      it "returns some xml", required_schema: "az" do
        get :show_xml, params: { id: efile_submission.id }
        expect(Nokogiri::XML(response.body).at('Primary FirstName').text).to eq("Jerry")
      end
    end
  end

  describe "#explain_calculations" do
    render_views

    let(:efile_submission) { create :efile_submission, :for_state, data_source: intake }

    before do
      sign_in intake
    end

    context "in az" do
      let(:intake) { create :state_file_az_intake, :with_efile_device_infos, primary_first_name: "Jerry" }

      it "shows a little bit about how each line was calculated" do
        get :explain_calculations, params: { id: efile_submission.id }
        expect(response.body).to include('AZ140_LINE_12')
      end
    end
  end
end
