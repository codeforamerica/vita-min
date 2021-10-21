require "rails_helper"

describe Hub::EfileSubmissionsController do
  describe '#index' do
    it_behaves_like :an_action_for_admins_only, action: :index, method: :get

    context "when authenticated as an admin" do
      let(:user) { create :admin_user }
      let!(:initial_efile_submission) { create :efile_submission }
      let!(:later_efile_submission) { create :efile_submission, tax_return: initial_efile_submission.tax_return }
      let!(:another_file_submission) { create :efile_submission }
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
    let!(:submission_2) { create :efile_submission, tax_return: submission.tax_return }
    let(:params) { { id: submission.client.id } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated admin" do
      let(:user) { create :admin_user }
      before { sign_in user }

      it "loads the tax return by id and latest submission as instance variables" do
        get :show, params: params
        expect(assigns(:client)).to eq submission.client
        expect(assigns(:tax_returns)).to eq [submission.tax_return]
      end
    end

    context "as a member of GetCTC.org organization" do
      let(:user) { create :organization_lead_user, organization: VitaPartner.ctc_org }
      before { sign_in user }

      it "loads the tax return by id and latest submission as instance variables" do
        get :show, params: params
        expect(assigns(:client)).to eq submission.client
        expect(assigns(:tax_returns)).to eq [submission.tax_return]
      end
    end

    context "as a member of GetCTC.org (Site)" do
      let(:user) { create :team_member_user, site: VitaPartner.ctc_site }
      before { sign_in user }

      it "loads the tax return by id and latest submission as instance variables" do
        get :show, params: params
        expect(assigns(:client)).to eq submission.client
        expect(assigns(:tax_returns)).to eq [submission.tax_return]
      end
    end

    context "with some other role" do
      let(:user) { create :team_member_user }
      before { sign_in user }

      it "does not allow access to the page" do
        get :show, params: params
        expect(response.status).to eq 403
      end
    end
  end

  describe "#resubmit" do
    let(:submission) { create :efile_submission, :failed }
    let(:params) { { id: submission } }

    before do
      sign_in user
      allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
    end

    context "as an authenticated admin" do
      let(:user) { create :admin_user }

      it "transitions the submission to resubmitted and records the initiator" do
        patch :resubmit, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:resubmitted, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Resubmission initiated."
      end
    end

    context "as a member of GetCTC.org organization" do
      let(:user) { create :organization_lead_user, organization: VitaPartner.ctc_org }
      before do
        allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
      end

      it "transitions the submission to resubmitted and records the initiator" do
        patch :resubmit, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:resubmitted, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Resubmission initiated."
      end
    end

    context "as a member of GetCTC.org (Site)" do
      let(:user) { create :team_member_user, site: VitaPartner.ctc_site }
      before do
        allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
      end

      it "transitions the submission to resubmitted and records the initiator" do
        patch :resubmit, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:resubmitted, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Resubmission initiated."
      end
    end


    context "with some other unauthorized role" do
      let(:user) { create :team_member_user }

      it "does not allow access" do
        patch :resubmit, params: params
        expect(response.status).to eq 403
      end
    end
  end

  describe "#waiting" do
    let(:submission) { create :efile_submission }
    let(:params) { { id: submission } }
    before do
      sign_in user
      allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
    end

    context "as an authenticated admin" do
      let(:user) { create :admin_user }

      it "transitions the submission to waiting and records the initiator" do
        patch :wait, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:waiting, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Waiting for client action."
      end
    end

    context "with a GetCTC.org role" do
      let(:user) { create :organization_lead_user, organization: VitaPartner.ctc_org }

      it "transitions the submission to waiting and records the initiator" do
        patch :wait, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:waiting, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Waiting for client action."
      end
    end

    context "with a GetCTC.org role (team member at site)" do
      let(:user) { create :team_member_user, site: VitaPartner.ctc_site }

      it "transitions the submission to waiting and records the initiator" do
        patch :wait, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:waiting, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Waiting for client action."
      end
    end

    context "with another role" do
      let(:user) { create :team_member_user }

      it "is not authorized" do
        patch :wait, params: params
        expect(response.status).to eq 403
      end
    end
  end

  describe "#cancel" do
    let(:submission) { create :efile_submission }
    let(:params) { { id: submission } }
    before do
      sign_in user
      allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
    end

    context "as an authenticated admin" do
      let(:user) { create :admin_user }

      it "transitions the efile submission to cancelled and records the initiator" do
        patch :cancel, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:cancelled, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Submission cancelled, tax return marked 'Not filing'."
      end
    end

    context "as a user of GetCTC.org" do
      let(:user) { create :organization_lead_user, organization: VitaPartner.ctc_org }

      it "transitions the efile submission to cancelled and records the initiator" do
        patch :cancel, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:cancelled, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Submission cancelled, tax return marked 'Not filing'."
      end
    end

    context "as a user of GetCTC.org (Site)" do
      let(:user) { create :team_member_user, site: VitaPartner.ctc_site }

      it "transitions the efile submission to cancelled and records the initiator" do
        patch :cancel, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:cancelled, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Submission cancelled, tax return marked 'Not filing'."
      end
    end

    context "as a team member of another org" do
      let(:user) { create :team_member_user }
      it "does not authorize me to see the page" do
        patch :cancel, params: params
        expect(response.status).to eq 403
      end
    end
  end

  describe "#investigate" do
    let(:submission) { create :efile_submission }
    let(:params) { { id: submission } }
    before do
      sign_in user
      allow_any_instance_of(EfileSubmission).to receive(:transition_to!)
    end
    context "as an authenticated admin" do
      let(:user) { create :admin_user }

      it "transitions the efile submission to investigate and records the initiator" do
        patch :investigate, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:investigating, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Good luck on your investigation!"
      end
    end

    context "as an authenticated user of GetCTC.org" do
      let(:user) { create :organization_lead_user, organization: VitaPartner.ctc_org }

      it "transitions the efile submission to investigate and records the initiator" do
        patch :investigate, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:investigating, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Good luck on your investigation!"
      end
    end

    context "as an authenticated user of GetCTC.org (Site)" do
      let(:user) { create :team_member_user, site: VitaPartner.ctc_site }

      it "transitions the efile submission to investigate and records the initiator" do
        patch :investigate, params: params

        expect(assigns(:efile_submission)).to have_received(:transition_to!).with(:investigating, { initiated_by_id: user.id })
        expect(response).to redirect_to(hub_efile_submission_path(id: submission.client.id))
        expect(flash[:notice]).to eq "Good luck on your investigation!"
      end
    end

    context "as a team member of another org" do
      let(:user) { create :team_member_user }

      it "does not authorize you to take the action" do
        patch :investigate, params: params

        expect(response.status).to eq 403
      end
    end
  end

  describe "#download" do
    let(:bundle) { { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") } }
    let(:submission) { create(:efile_submission, submission_bundle: bundle) }
    let(:params) { { id: submission.id} }

    context "as an authenticated admin" do
      let(:user) { create :admin_user }
      let(:transient_download_url) { "https://gyr-demo.s3.amazonaws.com/data.zip?sig=whatever&expires=whatever" }

      before do
        sign_in user
        allow(subject).to receive(:transient_storage_url).and_return(transient_download_url)
      end

      context "when a submission bundle is present" do
        it "redirects to the file in storage and logs access" do
          expect {
            get :download, params: params
          }.to change(AccessLog, :count).by(1)
          access_log = AccessLog.last
          expect(access_log.record).to eq(submission)
          expect(access_log.event_type).to eq("downloaded_submission_bundle")
          expect(access_log.user).to eq(user)

          expect(response).to redirect_to(transient_download_url)
          expect(subject).to have_received(:transient_storage_url).with(submission.submission_bundle.blob, disposition: "attachment")
        end
      end

      context "when a submission bundle is not present" do
        let(:bundle) { nil }

        it "404s" do
          get :download, params: params
          expect(response).to be_not_found
        end
      end
    end
  end
end
