require "rails_helper"

RSpec.describe Hub::CtcIntakeCapacityController do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an admin user" do
      let(:user) { create(:admin_user) }
      before do
        create_list(:ctc_intake_capacity, 6)
        sign_in user
      end

      it "shows an editable CtcIntakeCapacity and lists the most recent 5 intake capacities" do
        get :index
        expect(assigns(:form)).to be_instance_of(CtcIntakeCapacity)
        expect(assigns(:recent_intake_capacities)).to eq(CtcIntakeCapacity.order(created_at: :desc).limit(5))
      end
    end
  end

  describe "#create" do
    let(:params) do
      { ctc_intake_capacity:
          { capacity: 1 }
      }
    end
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an admin user" do
      let(:user) { create :admin_user }
      before do
        sign_in user
      end

      it "creates a new CtcIntakeCapacity record" do
        expect do
          post :create, params: params
        end.to change(CtcIntakeCapacity, :count).by(1)

        capacity = CtcIntakeCapacity.last
        expect(capacity.capacity).to eq 1
        expect(capacity.user).to eq user
        expect(response).to redirect_to hub_ctc_intake_capacity_index_path
      end
    end
  end
end
