require "rails_helper"

describe Hub::FraudIndicators::RoutingNumbersController do
  let(:user) { create :admin_user }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "when logged in" do

      before do
        sign_in user
        Fraud::Indicators::RoutingNumber.create(routing_number: "123456789", bank_name: "Some bank", activated_at: DateTime.now)
        Fraud::Indicators::RoutingNumber.create(routing_number: "222222222", bank_name: "Some other bank", activated_at: DateTime.now)
      end

      it "assigns a list of all risky Fraud::Indicator::RoutingNumber objects" do
        get :index

        expect(assigns(:signup_selections).length).to eq 2
        expect(assigns(:signup_selections).pluck(:routing_number)).to include "123456789"
        expect(assigns(:signup_selections).pluck(:routing_number)).to include "222222222"
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
          fraud_indicators_routing_number: {
              routing_number: "123456789",
              bank_name: "Some bank"
          }
      }
    end
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "creates a new routing number object" do
        expect {
          post :create, params: params, format: "js"
        }.to change(Fraud::Indicators::RoutingNumber, :count).by(1)

        indicator = Fraud::Indicators::RoutingNumber.last
        expect(indicator.routing_number).to eq "123456789"
        expect(indicator.activated_at).not_to be_nil
        expect(indicator.bank_name).to eq "Some bank"
        expect(indicator.extra_points).to be_nil
      end

      context "with extra_points provided" do
        let(:params) do
          {
            fraud_indicators_routing_number: {
              routing_number: "123456789",
              bank_name: "Some bank",
              extra_points: 10
            }
          }
        end

        it "persists the extra_points" do
          expect {
            post :create, params: params, format: "js"
          }.to change(Fraud::Indicators::RoutingNumber, :count).by(1)

          indicator = Fraud::Indicators::RoutingNumber.last
          expect(indicator.routing_number).to eq "123456789"
          expect(indicator.activated_at).not_to be_nil
          expect(indicator.bank_name).to eq "Some bank"
          expect(indicator.extra_points).to eq 10
        end
      end

      context "when an entry already exists with the provided name" do
        before do
          Fraud::Indicators::RoutingNumber.create(routing_number: "123456789", bank_name: "Some bank", activated_at: DateTime.now)
        end

        it "does not save and adds errors to the object" do
          expect {
            post :create, params: params, format: "js"
          }.to change(Fraud::Indicators::RoutingNumber, :count).by(0)
          expect(assigns(:resource).errors[:routing_number]).to include "has already been taken"
        end
      end
    end
  end

  describe "#update" do
    let!(:indicator) { Fraud::Indicators::RoutingNumber.create(routing_number: "123456789", bank_name: "Some bank", activated_at: nil) }
    let(:params) do
      { id: indicator.id }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context 'when logged in' do
      before do
        sign_in user
      end

      it "toggles between not activated and activated" do
        expect(indicator.activated_at).to eq nil
        put :update, params: params, format: :js
        indicator.reload
        expect(indicator.activated_at).not_to be_nil
      end
    end
  end
end
