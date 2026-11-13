require "rails_helper"

describe Hub::SourceParamsController do
  let(:admin_user) { create :admin_user }

  describe "#create" do
    render_views
    let(:vita_partner) { create :organization }
    let(:code) { "code" }
    let(:params) do
      {
          hub_source_params_form: {
              code: code
          },
          vita_partner_id: vita_partner.id
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "an authenticated user" do
      before do
        sign_in admin_user
      end

      it "responds with js" do
        post :create, params: params, format: :js, xhr: true
        expect(response.media_type).to eq "text/javascript"
      end

      it "does not respond with html" do
        post :create, params: params
        expect(response).to be_not_found
      end

      context "when the code does not already exist" do
        let(:code) { "koala" }
        it "creates a new source parameter" do
          expect {
            post :create, params: params, format: :js, xhr: true
          }.to change(vita_partner.source_parameters, :count).by 1
        end
      end

      context "when the code already exists" do
        let(:code) { "koala" }
        before do
          create :source_parameter, code: "koala", vita_partner: create(:organization)
        end

        it "does not make a new source parameter" do
          expect {
            post :create, params: params, format: :js, xhr: true
          }.not_to change(SourceParameter, :count)
        end
      end
    end
  end

  describe "#destroy" do
    render_views
    let(:source_parameter) { create :source_parameter, vita_partner: create(:organization), code: "code" }
    let(:id) { source_parameter.id }
    let(:params) do
      { id: id }
    end

    before do
      sign_in admin_user
    end

    it "responds with js" do
      delete :destroy, params: params, format: :js, xhr: true
      expect(response.media_type).to eq "text/javascript"
    end

    it "does not respond with html" do
      delete :destroy, params: params
      expect(response).to be_not_found
    end

    context "when the source param exists" do
      let!(:id) { source_parameter.id }

      it "deletes the source parameter" do
        expect {
          delete :destroy, params: params, format: :js, xhr: true
        }.to change(SourceParameter, :count).by(-1)
      end
    end
  end

  describe "#update" do
    let(:source_parameter) { create :source_parameter, vita_partner: create(:organization), code: "code" }
    before do
      sign_in admin_user
    end

    it "deactivates successfully" do
      post :update, format: :js, :params => { :locale => :en, :id => source_parameter.id, :source_parameter => { :active => "0" } }
      expect(response.status).to eq 204
      source_parameter.reload
      expect(source_parameter.active).to be false
    end

    it "activates successfully" do
      source_parameter.update(active: false)
      post :update, format: :js, :params => { :locale => :en, :id => source_parameter.id, :source_parameter => { :active => "1" } }
      expect(response.status).to eq 204
      source_parameter.reload
      expect(source_parameter.active).to be true
    end

  end

  describe "cross-tenant access" do
    # A team member belongs to a single site of ONE organization. This
    # reproduces that user acting on a SourceParameter belonging to a
    # completely unrelated organization, via #update and #destroy.
    let!(:other_org_source_parameter) { create :source_parameter, vita_partner: create(:organization), code: "unrelated-org-code" }
    let(:attacker_site) { create :site }
    let(:attacker) { create :user, role: create(:team_member_role, sites: [attacker_site]) }

    before { sign_in attacker }

    it "denies an unrelated team member trying to deactivate another org's source parameter" do
      post :update, format: :js, params: { id: other_org_source_parameter.id, source_parameter: { active: "0" } }

      expect(response).to be_forbidden
      other_org_source_parameter.reload
      expect(other_org_source_parameter.active).to eq true
    end

    it "denies an unrelated team member trying to destroy another org's source parameter" do
      expect {
        delete :destroy, params: { id: other_org_source_parameter.id }, format: :js, xhr: true
      }.not_to change(SourceParameter, :count)

      expect(response).to be_forbidden
      expect(SourceParameter.exists?(other_org_source_parameter.id)).to eq true
    end
  end
end
