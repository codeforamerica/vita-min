require "rails_helper"

RSpec.describe InvitationsController do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with a user who has prior invites" do
      let(:user) { create :user }
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

  describe "#resend" do
    let(:params) { { user_id: invited_user.id } }
    let(:invited_user) { create(:invited_user) }
    it_behaves_like :a_post_action_for_admins_only, action: :resend

    context "with a user id who has already been invited" do
      before { sign_in(create(:admin_user)) }

      it "sends a fresh invitation email" do
        expect { post :resend, params: { user_id: invited_user.id } }.to change(ActionMailer::Base.deliveries, :count).by 1
      end
    end

    context "with a user id who has accepted their invitation" do
      let(:accepted_invite_user) { create(:accepted_invite_user) }

      it "does not send an invitation email" do
        expect { post :resend, params: { user_id: accepted_invite_user.id } }.not_to change(ActionMailer::Base.deliveries, :count)
      end
    end
  end
end
