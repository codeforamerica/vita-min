require "rails_helper"

describe Hub::EfileSubmissionsController do
  describe '#index' do
    it_behaves_like :an_action_for_admins_only, action: :index, method: :get

    context "when authenticated as an admin" do
      let(:user) { create :admin_user }
      let!(:initial_efile_submission) { create :efile_submission }
      let!(:later_efile_submission) { create :efile_submission, tax_return: initial_efile_submission.tax_return }
      let!(:another_file_submission) { create :efile_submission}
      before { sign_in user }

      it "loads most recent submissions for tax returns" do
        get :index, params: {}
        expect(assigns(:efile_submissions)).not_to include initial_efile_submission
        expect(assigns(:efile_submissions)).to include later_efile_submission
        expect(assigns(:efile_submissions).length).to eq 2
      end

      context "pagination" do
        let(:submissions_double) { double }
        before do
          allow(EfileSubmission).to receive(:most_recent_by_tax_return).and_return submissions_double
          allow(submissions_double).to receive(:page)
        end

        it "is paginated with page param" do
          get :index, params: { page: "5" }

          expect(submissions_double).to have_received(:page).with '5'
        end
      end
    end
  end

  describe "#show" do
    let(:submission) { create :efile_submission }
    let(:params) { { id: submission.tax_return  } }
    it_behaves_like :an_action_for_admins_only, action: :show, method: :get

    context "as an authenticated admin" do
      let(:user) { create :admin_user }
      before { sign_in user }

      it "loads the tax return by id and latest submission as instance variables" do
        get :show, params: params

        expect(assigns(:tax_return)).to eq submission.tax_return
        expect(assigns(:efile_submission)).to eq submission
      end
    end
  end

  describe "#resubmit" do
    let(:submission) { create :efile_submission }
    let(:params) { { id: submission } }
    it_behaves_like :an_action_for_admins_only, action: :resubmit, method: :patch

    context "as an authenticated admin" do
      let(:user) { create :admin_user }
      before do
        sign_in user
        allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
      end

      it "loads the tax return by id and latest submission as instance variables" do
        patch :resubmit, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:resubmitted, { initiated_by_id: user.id})
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.tax_return_id))
        expect(flash[:notice]).to eq "Resubmission initiated."
      end
    end
  end
end