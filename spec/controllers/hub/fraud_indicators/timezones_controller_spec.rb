require "rails_helper"

describe Hub::FraudIndicators::TimezonesController do
  let(:user) { create :admin_user }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "when logged in" do
      before do
        sign_in user
        Fraud::Indicators::Timezone.create(name: "Mexico/Tijuana", activated_at: DateTime.now)
        Fraud::Indicators::Timezone.create(name: "America/Indianapolis", activated_at: nil)
      end

      it "assigns a list of all Fraud::Indicator::Timezone objects" do
        get :index

        expect(assigns(:signup_selections).length).to eq 2
        expect(assigns(:signup_selections).pluck(:name)).to include "Mexico/Tijuana"
        expect(assigns(:signup_selections).pluck(:name)).to include "America/Indianapolis"
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
          fraud_indicators_timezone: {
              name: "America/Indianapolis"
          }
      }
    end
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "creates a new timezone object" do
        expect {
          post :create, params: params, format: "js"
        }.to change(Fraud::Indicators::Timezone, :count).by(1)

        indicator = Fraud::Indicators::Timezone.last
        expect(indicator.name).to eq "America/Indianapolis"
        expect(indicator.activated_at).not_to be_nil
      end

      context "when an entry already exists with the provided name" do
        before do
          Fraud::Indicators::Timezone.create(name: "America/Indianapolis")
        end

        it "does not save and adds errors to the object" do
          expect {
            post :create, params: params, format: "js"
          }.to change(Fraud::Indicators::Timezone, :count).by(0)
          expect(assigns(:resource).errors[:name]).to include "has already been taken"
        end
      end
    end
  end

  describe "#update" do
    let!(:indicator) { Fraud::Indicators::Timezone.create(name: "America/Indianapolis") }
    let(:params) do
      { id: indicator.id }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context 'when logged in' do
      before do
        sign_in user
      end

      it "toggles between activated to not activated" do
        expect(indicator.activated_at).to eq nil
        put :update, params: params, format: :js
        indicator.reload
        expect(indicator.activated_at).not_to be_nil
      end
    end
  end
end
