require "rails_helper"

RSpec.describe InvitationsController do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with a user who has prior invites" do
      let(:user) { create :user_with_membership }
      let!(:unaccepted_invite) { create :invited_user, invited_by: user }
      let!(:someone_elses_unaccepted_invite) { create :invited_user }
      let!(:accepted_invite) { create :accepted_invite_user, invited_by: user }
      before { allow(subject).to receive(:current_user).and_return(user) }

      it "shows unaccepted invites sent by the user" do
        get :index

        expect(assigns(:unaccepted_invitations)).to eq [unaccepted_invite]
      end
    end
  end
end