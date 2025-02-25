require "rails_helper"

describe Hub::StateFile::EfileSubmissionsController do
  describe '#index' do
    let!(:state_efile_submission) { create :efile_submission, :for_state }
    let!(:nj_state_efile_submission) { create :efile_submission, :for_state, data_source: create(:state_file_nj_intake) }
    let!(:non_state_efile_submission) { create :efile_submission }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with an authenticated state file admin" do
      before { sign_in(create(:state_file_admin_user)) }

      it "shows all state efile submissions except nj and no other efile submissions" do
        get :index

        expect(assigns(:efile_submissions)).to match_array [state_efile_submission]
      end
    end

    context "with an authenticated non-state file admin" do
      before { sign_in(create(:admin_user)) }

      it "shows no efile submissions" do
        get :index

        expect(assigns(:efile_submissions)).to be_empty
      end
    end

    context "with a nj staff role" do
      before { sign_in(create(:state_file_nj_staff_user)) }

      it "shows state efile submissions for nj only" do
        get :index

        expect(assigns(:efile_submissions)).to match_array [nj_state_efile_submission]
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

    context "with an authenticated state file admin" do
      before { sign_in(create(:state_file_admin_user)) }

      it "shows the state efile submission" do
        get :show, params: params

        expect(assigns(:efile_submission)).to eq state_efile_submission
      end
    end

    context "with an authenticated non-state file admin" do
      before { sign_in(create(:admin_user)) }

      it "returns 403 forbidden" do
        get :show, params: params

        expect(response).to be_forbidden
      end
    end
  end

  describe '#show_xml' do
    let(:intake) { create :state_file_ny_intake, :with_efile_device_infos }
    let!(:state_efile_submission) { create :efile_submission, :for_state, data_source: intake }
    let(:params) do
      { efile_submission_id: state_efile_submission.id }
    end

    context "with an authenticated state file admin" do
      render_views
      before { sign_in(create(:state_file_admin_user)) }

      it "shows the state efile submission xml", required_schema: "ny" do
        get :show_xml, params: params
        expect(response).to be_successful
        xml = Nokogiri::XML(response.body)
        expect(xml.at("ReturnState Filer Primary LastName").text).to eq intake.primary_last_name
      end
    end

    context "with an authenticated non-state file admin" do
      render_views
      before { sign_in(create(:admin_user)) }

      it "returns 403 forbidden" do
        get :show_xml, params: params

        expect(response).to be_forbidden
      end
    end
  end

  describe "#state_counts" do
    context "assigning the instance variable" do
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

    context "separating nj" do
      before do
        create(:efile_submission, :accepted, :for_state, data_source: create(:state_file_az_intake))
        create(:efile_submission, :accepted, :for_state, data_source: create(:state_file_md_intake))
        create(:efile_submission, :rejected, :for_state, data_source: create(:state_file_id_intake))
        create(:efile_submission, :failed, :for_state, data_source: create(:state_file_nc_intake))
        create(:efile_submission, :failed, :for_state, data_source: create(:state_file_nj_intake))
      end

      it "shows sum of all state except nj when authenticated as an admin" do
        sign_in create :state_file_admin_user

        get :state_counts, format: :js, xhr: true
        non_zero_counts = assigns(:efile_submission_state_counts).reject { |_,v| v == 0 }
        expect(non_zero_counts).to eq({ "accepted" => 2, "rejected" => 1, "failed" => 1 })
      end

      it "shows sum of all state except nj when authenticated as nj staff" do
        sign_in create :state_file_nj_staff_user

        get :state_counts, format: :js, xhr: true
        non_zero_counts = assigns(:efile_submission_state_counts).reject { |_,v| v == 0 }
        expect(non_zero_counts).to eq({ "failed" => 1 })
      end
    end
  end
end
