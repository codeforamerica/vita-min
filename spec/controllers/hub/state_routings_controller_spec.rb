require "rails_helper"

describe Hub::StateRoutingsController do
  let!(:florida_srt_1) { create(:state_routing_target, state_abbreviation: "FL", target: create(:coalition)) }
  let!(:florida_srt_2) { create(:state_routing_target, state_abbreviation: "FL", target: create(:coalition)) }
  let!(:florida_srt_3) { create(:state_routing_target, state_abbreviation: "FL", target: create(:organization)) }
  let!(:california_srt) { create(:state_routing_target, state_abbreviation: "CA", target: create(:coalition)) }
  let!(:california_srt_2) { create(:state_routing_target, state_abbreviation: "CA", target: create(:organization)) }

  describe "before_actions" do
    context "as an authenticated user" do
      let(:user) { create :admin_user }

      before do
        sign_in user
      end

      it "loads the state routing targets on edit" do
        get :edit, params: { state: "FL" }

        expect(assigns(:coalition_srts)).to eq [florida_srt_1, florida_srt_2]
        expect(assigns(:independent_org_srts)).to eq [florida_srt_3]
      end

      it "loads the state routing targets on update" do
        put :update, params: { state: "FL", hub_state_routing_form: { state_routing_fraction_attributes: "some_params" } }

        expect(assigns(:coalition_srts)).to eq [florida_srt_1, florida_srt_2]
        expect(assigns(:independent_org_srts)).to eq [florida_srt_3]
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an authenticated user" do
      let(:user) { create :admin_user }

      before do
        sign_in user
      end

      it "assigns state_routings grouped by state in ASC order" do
        srts_grouped_by_state_abbrev = [
          ["CA", [california_srt, california_srt_2]],
          ["FL", [florida_srt_1, florida_srt_2, florida_srt_3]]
        ]
        get :index
        expect(assigns(:state_routings)).to eq srts_grouped_by_state_abbrev
      end
    end
  end

  describe "#edit" do
    let(:params) { { state: "FL" } }

    it_behaves_like :a_get_action_for_admins_only, action: :edit

    context "as an authenticated user" do
      let(:user) { create :admin_user }

      before do
        sign_in user
        allow(Hub::StateRoutingForm).to receive(:new)
      end

      it "instantiates the form" do
        get :edit, params: params

        expect(response).to render_template :edit
        expect(Hub::StateRoutingForm).to have_received(:new)
      end
    end
  end

  describe "#update" do
    let(:params) { { state: "FL", hub_state_routing_form: { state_routing_fraction_attributes: "some_params" } } }
    let(:form_double) { instance_double(Hub::StateRoutingForm) }

    before do
      allow(Hub::StateRoutingForm).to receive(:new).and_return(form_double)
      allow(form_double).to receive(:valid?)
      allow(form_double).to receive(:save)
    end

    it_behaves_like :a_post_action_for_admins_only, action: :update

    context "as an authenticated user" do
      let(:user) { create :admin_user }

      before do
        sign_in user
      end

      context "when the form is not valid" do
        before do
          allow(form_double).to receive(:valid?).and_return false
          allow(form_double).to receive(:errors).and_return({ error_type: "you did it wrong" })
        end

        it "creates a flash alert and renders edit with form errors" do
          put :update, params: params

          expect(flash[:alert]).to eq "Please fix indicated errors and try again."
          expect(response).to render_template :edit
        end
      end

      context "when the form is valid" do
        before do
          allow(form_double).to receive(:valid?).and_return true
        end

        it "calls save and redirects to edit" do
          put :update, params: params

          expect(form_double).to have_received(:save)
          expect(response).to redirect_to edit_hub_state_routing_path(state: "FL")
        end
      end
    end
  end
end