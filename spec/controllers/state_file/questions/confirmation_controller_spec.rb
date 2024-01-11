require 'rails_helper'

RSpec.describe StateFile::Questions::ConfirmationController do
  describe "#show_xml" do
    context "in ny" do
      let(:ny_intake) do
        create(
          :state_file_ny_intake,
          :with_efile_device_infos,
          primary_first_name: "Jerry",
          school_district_id: 441,
          school_district: "Bellmore-Merrick CHS",
          school_district_number: 46
        )
      end
      let(:efile_submission) { create :efile_submission, :for_state, data_source: ny_intake }

      before do
        session[:state_file_intake] = ny_intake.to_global_id
      end

      it "returns some xml" do
        get :show_xml, params: { us_state: "ny", id: efile_submission.id }
        expect(Nokogiri::XML(response.body).at('Primary FirstName').text).to eq("Jerry")
      end
    end
  end

  describe "#explain_calculations" do
    render_views

    let(:efile_submission) { create :efile_submission, :for_state, data_source: intake }

    before do
      session[:state_file_intake] = intake.to_global_id
    end

    context "in ny" do
      let(:intake) { create :state_file_ny_intake, :with_efile_device_infos, primary_first_name: "Jerry" }

      it "shows a little bit about how each line was calculated" do
        get :explain_calculations, params: { us_state: "ny", id: efile_submission.id }
        expect(response.body).to include('IT201_LINE_1')
        expect(response.body).to include('IT213_LINE_14')
      end
    end

    context "in az" do
      let(:intake) { create :state_file_az_intake, :with_efile_device_infos, primary_first_name: "Jerry" }

      it "shows a little bit about how each line was calculated" do
        get :explain_calculations, params: { us_state: "az", id: efile_submission.id }
        expect(response.body).to include('AZ140_LINE_12')
      end
    end
  end
end
