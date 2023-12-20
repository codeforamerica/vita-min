require "rails_helper"

describe Hub::StateFile::EfileSubmissionsController do
  describe '#index' do
    let!(:state_efile_submission) { create :efile_submission, :for_state }
    let!(:non_state_efile_submission) { create :efile_submission }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :an_action_for_state_file_admins_only, action: :index, method: :get

    context "with an authenticated state file admin" do
      before { sign_in(create(:state_file_admin_user)) }

      it "shows all state efile submissions and no other efile submissions" do
        get :index

        expect(assigns(:efile_submissions)).to match_array [state_efile_submission]
      end
    end
  end

  describe '#show' do
    let!(:state_efile_submission) { create :efile_submission, :for_state }
    let!(:non_state_efile_submission) { create :efile_submission }
    let(:params) do
      { id: state_efile_submission.id }
    end
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :an_action_for_state_file_admins_only, action: :index, method: :get

    context "with an authenticated state file admin" do
      before { sign_in(create(:state_file_admin_user)) }

      it "shows the state efile submission" do
        get :show, params: params

        expect(assigns(:efile_submission)).to eq state_efile_submission
      end
    end
  end
end
