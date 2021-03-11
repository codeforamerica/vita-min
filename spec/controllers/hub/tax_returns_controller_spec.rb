require "rails_helper"

RSpec.describe Hub::TaxReturnsController, type: :controller do
  let(:coalition) { create :coalition }
  let(:organization) { create :organization, coalition: coalition }
  let(:site) { create :site, parent_organization: organization }

  let!(:organization_lead) { create :organization_lead_user, organization: organization }
  let!(:site_coordinator) { create :site_coordinator_user, site: site, name: "Barbara" }
  let!(:team_member) { create :team_member_user, site: site, name: "Aaron" }

  let(:currently_assigned_coalition_lead) { create :coalition_lead_user, coalition: coalition }
  let(:user) { currently_assigned_coalition_lead }

  let(:client_assigned_group) { organization }
  let(:client) { create :client, intake: create(:intake, preferred_name: "Lucille"), vita_partner: client_assigned_group }
  let(:tax_return) { create :tax_return, client: client, year: 2018, assigned_user: currently_assigned_coalition_lead }

  describe "#edit" do
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
      }
    }

    context "as an anonymous user" do
      it "is forbidden" do
        get :edit, params: params, format: :js, xhr: true

        expect(response).to be_forbidden
      end
    end

    context "as an authenticated coalition lead user" do
      let(:user) { create :coalition_lead_user, coalition: coalition }
      before { sign_in user }

      context "client is assigned to an org" do
        let(:client_assigned_group) { organization }

        it "returns a list of org leads at the client's assigned organization + the assigned user + myself" do
          get :edit, params: params, format: :js, xhr: true

          expect(response).to be_ok
          expect(assigns(:assignable_users)).to eq [user, currently_assigned_coalition_lead, organization_lead]
        end
      end

      context "client is assigned to a site" do
        let(:client_assigned_group) { site }

        it "returns a list of sorted site coordinators and team members at the client's assigned site + the assigned user + myself" do
          get :edit, params: params, format: :js, xhr: true

          expect(response).to be_ok
          expect(assigns(:assignable_users).first).to eq user # current user should always be first
          expect(assigns(:assignable_users).second).to eq currently_assigned_coalition_lead # current assignee should be second
          # remaining are alphabetical ordering by name
          expect(assigns(:assignable_users).third).to eq team_member # Aaron
          expect(assigns(:assignable_users).fourth).to eq site_coordinator # Barbara
        end
      end

      context "with a suspended user at the associated vita_partner" do
        let!(:suspended_user) { create :organization_lead_user, suspended_at: DateTime.now, organization: client.vita_partner }

        it "does not include the suspended user" do
          get :edit, params: params, format: :js, xhr: true

          expect(assigns(:assignable_users)).not_to include suspended_user
        end
      end
    end
  end

  describe "#update" do
    let(:user) { create :site_coordinator_user, site: site }
    let(:assigned_user) { team_member }
    let(:assigned_user_id) { assigned_user.id }
    let(:params) {
      {
        id: tax_return.id.to_s,
        assigned_user_id: assigned_user_id
      }
    }

    context "as an unauthenticated user" do
      it "is forbidden" do
        put :update, params: params, format: :js, xhr: true

        expect(response).to be_forbidden
      end
    end

    context "as an authenticated coalition lead" do
      let(:user) { create :coalition_lead_user, coalition: coalition }
      before do
        sign_in user
        allow(SystemNote::AssignmentChange).to receive(:generate!)
      end

      context "when trying to assign the tax return to an assignable user" do
        let(:assigned_user) { organization_lead }

        it "assigns the user to the tax return and creates a system note" do
          put :update, params: params, format: :js, xhr: true

          tax_return.reload
          expect(tax_return.assigned_user).to eq organization_lead
          expect(response).to render_template :show
          expect(flash.now[:notice]).to eq "Assigned Lucille's 2018 tax return to #{organization_lead.name}."
          expect(SystemNote::AssignmentChange).to have_received(:generate!).with({ initiated_by: user, tax_return: tax_return })
        end
      end

      context "when reassigning to the already assigned user" do
        let(:assigned_user) { currently_assigned_coalition_lead }

        it "is ok" do
          put :update, params: params, format: :js, xhr: true

          expect(response).to be_ok
          tax_return.reload
          expect(tax_return.assigned_user).to eq currently_assigned_coalition_lead
        end
      end

      context "when unassigning the tax return" do
        let(:assigned_user_id) { "" }

        it "removes the assigned user from the tax return" do
          put :update, params: params, format: :js, xhr: true

          tax_return.reload
          expect(tax_return.assigned_user).not_to be_present
          expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to no one."
          expect(SystemNote::AssignmentChange).to have_received(:generate!).with({ initiated_by: user, tax_return: tax_return })
        end
      end

      context "when trying to assign to an unassignable user" do
        let(:assigned_user) { site_coordinator }

        it "is is forbidden" do
          put :update, params: params, format: :js, xhr: true

          expect(response).to be_forbidden
        end
      end
    end
  end
end
