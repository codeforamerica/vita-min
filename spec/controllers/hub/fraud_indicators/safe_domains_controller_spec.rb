require "rails_helper"

describe Hub::FraudIndicators::SafeDomainsController do
  let(:user) { create :admin_user }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "when logged in" do

      before do
        sign_in user
        Fraud::Indicators::Domain.create(risky: true, name: "something.com", activated_at: DateTime.now)
        Fraud::Indicators::Domain.create(safe: true, name: "something-else.com", activated_at: nil)
        Fraud::Indicators::Domain.create(safe: true, name: "another-thing.com", activated_at: DateTime.now)
      end

      it "assigns a list of all safe Fraud::Indicator::Domain objects" do
        get :index

        expect(assigns(:resources).length).to eq 2
        expect(assigns(:resources).pluck(:name)).to include "something-else.com"
        expect(assigns(:resources).pluck(:name)).to include "another-thing.com"
        expect(assigns(:resources).pluck(:name)).not_to include "something.com"
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
          fraud_indicators_domain: {
              name: "example.com"
          }
      }
    end
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "creates a new domain object" do
        expect {
          post :create, params: params, format: "js"
        }.to change(Fraud::Indicators::Domain, :count).by(1)

        indicator = Fraud::Indicators::Domain.last
        expect(indicator.name).to eq "example.com"
        expect(indicator.safe).to eq true
        expect(indicator.activated_at).not_to be_nil
      end

      context "when an entry already exists with the provided name" do
        before do
          Fraud::Indicators::Domain.create(safe: true, name: "example.com")
        end

        it "does not save and adds errors to the object" do
          expect {
            post :create, params: params, format: "js"
          }.to change(Fraud::Indicators::Domain, :count).by(0)
          expect(assigns(:resource).errors[:name]).to include "has already been taken"
        end
      end
    end
  end

  describe "#update" do
    let!(:indicator) { Fraud::Indicators::Domain.create(safe: true, name: "example.com") }
    let(:params) do
      { id: indicator.id }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context 'when logged in' do
      before do
        sign_in user
      end

      it "toggles from activated to not activated" do
        expect(indicator.activated_at).to eq nil
        put :update, params: params, format: :js
        indicator.reload
        expect(indicator.activated_at).not_to be_nil
      end
    end
  end
end
