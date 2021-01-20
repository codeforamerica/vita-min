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

        it "filters invite buttons based on ability" do
          get :index

          expect(response).to be_ok
          expect(response.body).not_to include("Invite a new admin")
          expect(response.body).to include("Invite a new greeter")
        end
      end
    end
  end
end
