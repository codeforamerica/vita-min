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

  describe "#state_counts" do
    context "when authenticated as an admin" do
      let(:user) { create :state_file_admin_user }
      let(:state_counts) { { "accepted" => 1, "rejected" => 2 } }
      before do
        sign_in user
        allow(EfileSubmission).to receive(:statefile_state_counts).and_return state_counts
      end

      it "loads most recent submissions for tax returns" do
        get :state_counts, format: :js, xhr: true
        expect(assigns(:efile_submission_state_counts)).to eq state_counts
      end
    end
  end
end
