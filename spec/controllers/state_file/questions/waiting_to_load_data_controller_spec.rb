require 'rails_helper'

RSpec.describe StateFile::Questions::WaitingToLoadDataController do
  let!(:intake) { create(:state_file_ny_intake) }

  before do
    session[:state_file_intake] = intake.to_global_id
  end

  describe '#edit' do
    context 'when there is no authorization code' do
      it 'raises an error' do
        expect do
          get :edit, params: { us_state: :ny }
        end.to raise_error(ActionController::RoutingError)
      end
    end

    context 'when the current intake has not yet had data imported' do
      before do
        intake.update(raw_direct_file_data: nil)
      end

      it 'queues a job to import the data' do
        expect do
          get :edit, params: { authorizationCode: 'abcde', us_state: :ny }
        end.to have_enqueued_job(StateFile::ImportFromDirectFileJob).with(token: 'abcde', intake: intake)
      end
    end

    context 'when the current intake has already had data imported' do
      before do
        expect(intake.raw_direct_file_data).not_to be_nil
      end

      it 'redirects to the next page' do
        get :edit, params: { authorization_code: 'abcde', us_state: :ny }
        expect(response).to redirect_to(StateFile::Questions::DataReviewController.to_path_helper(us_state: :ny))
      end
    end
  end
end
