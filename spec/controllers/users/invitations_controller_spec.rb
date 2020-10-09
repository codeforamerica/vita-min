require "rails_helper"

RSpec.describe Users::InvitationsController do
  let(:raw_invitation_token) { "exampleToken" }
  let(:beta_user) { create :beta_tester }
  let(:vita_partner) { create :vita_partner }
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#new" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new
    it_behaves_like :a_get_action_for_beta_testers_only, action: :new
  end

  describe "#create" do
    let(:params) do
      {
        user: {
          name: "Cher Cherimoya",
          email: "cherry@example.com",
          vita_partner_id: vita_partner.id
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create
    it_behaves_like :a_post_action_for_beta_testers_only, action: :create

    context "with an authenticated beta tester" do
      before { sign_in beta_user }

      it "creates a new invited user" do
        expect do
          post :create, params: params
        end.to change(User, :count).by 1

        invited_user = User.last
        expect(invited_user.name).to eq "Cher Cherimoya"
        expect(invited_user.email).to eq "cherry@example.com"
        expect(invited_user.is_beta_tester?).to eq true
        expect(invited_user.invitation_token).to be_present
        expect(invited_user.invited_by).to eq beta_user
        expect(invited_user.role).to eq "agent"
        expect(invited_user.vita_partner).to eq vita_partner
        expect(response).to redirect_to invitations_path
      end

      context "if the invited user already exists and is an admin" do
        let!(:invited_user) { create :admin_user, email: "cherry@example.com" }

        it "doesn't change the user's role" do
          post :create, params: params
          invited_user.reload
          expect(invited_user.is_beta_tester?).to eq true
          expect(invited_user.role).to eq "admin"
        end
      end
    end
  end

  describe "#edit" do
    render_views

    let(:params) { { invitation_token: raw_invitation_token } }
    let!(:invited_user) do
      create(
        :invited_user,
        name: "Cherry Cherimoya",
        email: "cherry@example.com",
        invitation_token: Devise.token_generator.digest(User, :invitation_token, raw_invitation_token),
        invited_by: beta_user,
        vita_partner: vita_partner
      )
    end

    it "shows the user's existing information" do
      get :edit, params: params

      expect(response.body).to have_content "cherry@example.com"
      expect(response.body).to have_content vita_partner.name
      expect(assigns(:user).name).to eq "Cherry Cherimoya"
    end

    context "with a HEAD request" do
      # one of our collaborators encountered this error, unclear why the browser used HEAD, but it happens
      it "works fine and shows the user's info" do
        head :edit, params: params

        expect(response.body).to have_content "cherry@example.com"
        expect(response.body).to have_content vita_partner.name
        expect(assigns(:user).name).to eq "Cherry Cherimoya"
      end
    end

    context "without a matching token" do
      let(:params) { { invitation_token: "BrokenToken" } }

      it "shows an error page" do
        get :edit, params: params

        expect(response).to be_not_found
        expect(response.body).to have_content "We can't find that invitation"
      end
    end

    context "without a token" do
      it "shows an error page" do
        get :edit

        expect(response).to be_not_found
        expect(response.body).to have_content "We can't find that invitation"
      end
    end
  end

  describe "#update" do
    let!(:invited_user) do
      create(
        :invited_user,
        name: "Cherry Cherimoya",
        invitation_token: Devise.token_generator.digest(User, :invitation_token, raw_invitation_token),
        invited_by: beta_user,
        vita_partner: vita_partner
      )
    end

    context "with valid params" do
      let(:params) do
        {
          user: {
            name: "Cher Cherimoya",
            password: "secret password",
            password_confirmation: "secret password",
            invitation_token: raw_invitation_token,
            timezone: timezone,
          }
        }
      end

      context "without a timezone" do
        it "updates all necessary information on the user and signs them in" do
        expect do
          post :update, params: params
        end.to change{ controller.current_user }.from(nil).to(invited_user)
        invited_user.reload
        expect(invited_user.name).to eq "Cher Cherimoya"
        expect(invited_user.vita_partner).to eq vita_partner
        expect(invited_user.timezone).to eq "Eastern Time (US & Canada)"
        expect(response).to redirect_to user_profile_path
        end
      end

      context "with a timezone" do
        let(:timezone) { "Pacific Time (US & Canada)" }

        it "stores the timezone data" do
          expect do
            post :update, params: params
          end.to change{ controller.current_user }.from(nil).to(invited_user)
          invited_user.reload
          expect(invited_user.name).to eq "Cher Cherimoya"
          expect(invited_user.vita_partner).to eq vita_partner
          expect(invited_user.timezone).to eq "Pacific Time (US & Canada)"
          expect(response).to redirect_to user_profile_path
        end
      end


    end

    context "with missing required fields" do
      let(:params) do
        {
          user: {
            name: "",
            password: "secret password",
            password_confirmation: "secret password",
            invitation_token: raw_invitation_token
          }
        }
      end

      it "shows a validation error" do
        post :update, params: params

        expect(assigns(:user).errors).to include :name
        expect(response.status).to eq 200
      end
    end
  end
end