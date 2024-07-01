require "rails_helper"

describe "AZ Questions Controllers minimal tests", type: :controller do
  Navigation::StateFileAzQuestionNavigation.controllers.each do |controller|
    next if [StateFile::Questions::W2Controller,
             StateFile::Questions::UnemploymentController,
             StateFile::Questions::DataReviewController].include? controller
    describe controller do
      render_views

      let(:intake) { create :state_file_az_owed_intake }
      before do
        sign_in intake
      end

      it 'succeeds' do
        if controller == StateFile::Questions::WaitingToLoadDataController
          intake.update(consented_to_terms_and_conditions: "yes")
          intake.update(raw_direct_file_data: nil)
        else
          create :efile_submission, :for_state, data_source: intake
        end

        get :edit, params: { us_state: "az", authorizationCode: "abcde" }
        expect(response).to be_successful
      end
    end
  end
end