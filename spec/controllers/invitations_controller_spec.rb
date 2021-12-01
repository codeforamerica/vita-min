require "rails_helper"

RSpec.describe InvitationsController do
  describe "#index" do
    let(:user) { create :admin_user }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated user" do
      before { sign_in user }

      context "with prior invites" do
        let!(:unaccepted_invite) { create :invited_user, invited_by: user }
        let!(:someone_elses_unaccepted_invite) { create :invited_user }
        let!(:accepted_invite) { create :accepted_invite_user, invited_by: user }

        it "shows unaccepted invites sent by the user" do
          get :index

          expect(assigns(:unaccepted_invitations)).to eq [unaccepted_invite]
        end
      end

      context "with role management permissions" do
        render_views

        before do
          allow(subject.current_ability).to receive(:can?).and_return(true)
          allow(subject.current_ability).to receive(:can?).with(:manage, AdminRole).and_return(false)
          allow(subject.current_ability).to receive(:can?).with(:manage, GreeterRole).and_return(true)
        end

        it "filters invite options" do
          get :index

          expect(response).to be_ok
          expect(response.body).not_to include('value="AdminRole"')
          expect(response.body).to include('value="GreeterRole"')
        end
      end
    end
  end

  describe "#resend_invitation" do
    context "invited by current user" do
      let(:creating_user) { create :user }
      let(:invited_user) { create :user, invited_by: creating_user }

      before { sign_in creating_user }

      it "updates invitation_sent_at value" do
        expect {
          put :resend_invitation, params: { user_id: invited_user.id }
          invited_user.reload
        }.to change(invited_user, :invitation_sent_at)
      end

      it "redirects after saving" do
        put :resend_invitation, params: { user_id: invited_user.id }
        expect(flash[:notice]).to eq "Invitation re-sent to #{invited_user.email}"
        expect(response).to redirect_to invitations_path
      end
    end

    context "invited by someone else" do
      let(:logged_in_user) { create :user }
      let(:invited_user) { create :user, invited_by: (create :user) }

      before { sign_in logged_in_user }

      it "does not resend the invitation" do
        expect {
          put :resend_invitation, params: { user_id: invited_user.id }
          invited_user.reload
        }.not_to change(invited_user, :invitation_sent_at)
      end

      it "redirects without saving" do
        put :resend_invitation, params: { user_id: invited_user.id }
        expect(flash[:notice]).to eq "Could not resend invitation."
        expect(response).to redirect_to invitations_path
      end
    end
  end
end
