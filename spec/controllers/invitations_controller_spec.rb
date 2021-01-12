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
    let(:params) { { id: invited_user.id } }
    let(:invited_user) { create(:invited_user) }
    it_behaves_like :a_post_action_for_admins_only, action: :resend

    context "with a logged-in admin user" do
      before { sign_in(create(:admin_user)) }

      context "with a user id who has already been invited" do
        it "sends a fresh invitation email" do
          expect { post :resend, params: { id: invited_user.id } }.to change(ActionMailer::Base.deliveries, :count).by 1
          expect(flash[:notice]).to eq "We sent an email invitation to #{invited_user.email}."
          expect(response).to redirect_to(invitations_path)
        end
      end

      context "with a user id who has accepted their invitation" do
        let(:accepted_invite_user) { create(:accepted_invite_user) }

        it "does not send an invitation email" do
          expect { post :resend, params: { id: accepted_invite_user.id } }.not_to change(ActionMailer::Base.deliveries, :count)
          expect(flash[:warning]).to eq "Cannot re-invite a user who already accepted the invite."
          expect(response).to redirect_to(invitations_path)
        end
      end
    end
  end
end
