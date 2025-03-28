require "rails_helper"

RSpec.describe Hub::TaxReturnsController, type: :controller do
  let(:coalition) { create :coalition }
  let(:organization) { create :organization, coalition: coalition }
  let(:site) { create :site, parent_organization: organization }

  let!(:organization_lead) { create :organization_lead_user, organization: organization }
  let!(:site_coordinator) { create :site_coordinator_user, sites: [site], name: "Barbara" }
  let!(:team_member) { create :team_member_user, sites: [site], name: "Aaron" }
  let!(:unauthorized_team_member) { create :team_member_user }

  let(:currently_assigned_coalition_lead) { create :coalition_lead_user, coalition: coalition }
  let(:user) { currently_assigned_coalition_lead }

  let(:client_assigned_group) { organization }
  let(:client) { create :client, intake: build(:intake, preferred_name: "Lucille"), vita_partner: client_assigned_group }
  let!(:tax_return) { create :tax_return, client: client, year: 2018, assigned_user: currently_assigned_coalition_lead }

  let(:fake_current_tax_year) { 2021 }
  let(:fake_time) { DateTime.parse("2022-04-14") }
  before do
    allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(fake_current_tax_year)
  end
  around do |example|
    Timecop.freeze(fake_time) do
      example.run
    end
  end

  describe "#new" do
    let(:params) do
      {
        client_id: client.id
      }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new

    context "an unauthorized user" do
      before do
        sign_in unauthorized_team_member
      end

      it "is not allowed to access the page" do
        get :new, params: params
        expect(response).to be_forbidden
      end
    end

    context "an authenticated user" do
      let(:user) { create :admin_user }
      before do
        sign_in user
      end

      it "renders the new template and assigns tax_return related variables" do
        get :new, params: params
        expect(response).to render_template :new
        expect(assigns(:client)).to eq client
        expect(assigns(:tax_return)).to be_an_instance_of TaxReturn
        expect(assigns(:form).tax_return_years).to eq [2018]
        expect(assigns(:form).remaining_years).to eq(MultiTenantService.gyr.filing_years(fake_time) - [2018])
      end

      context "with an archived intake" do
        let(:user) { team_member }

        before do
          client.intake.update(product_year: Rails.configuration.product_year - 2)
        end

        it "response is forbidden (403)" do
          get :new, params: params
          expect(response).to be_forbidden
        end
      end
    end
  end

  describe "#create" do
    let(:user) { create :admin_user }
    let(:params) do
      {
          client_id: client.id
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before do
        sign_in user
      end

      let(:assigned_user) { user }

      let(:params) do
        {
            client_id: client.id,
            hub_tax_return_form: {
                year: "2020",
                certification_level: "basic",
                assigned_user_id: assigned_user.id,
                current_state: :intake_in_progress
            }
        }
      end

      context "with valid parameters" do
        it "creates a new tax return object for the client and redirects with success message" do
          expect {
            post :create, params: params
          }.to change(client.tax_returns, :count).by(1)
           .and change(client.system_notes, :count).by(1)
          
          tax_return = TaxReturn.last
          expect(tax_return.year).to eq 2020
          expect(tax_return.current_state).to eq "intake_in_progress"
          expect(tax_return.assigned_user).to eq user
          expect(tax_return.certification_level).to eq "basic"
          expect(response).to redirect_to(hub_client_path(id: client.id))
          expect(flash[:notice]).to eq "2020 return created for #{client.preferred_name}."
        end
      end

      context "when existing tax return is drop_off" do
        let(:params) do
          {
              client_id: client.id,
              hub_tax_return_form: {
                  year: "2020",
                  certification_level: "basic",
                  assigned_user_id: user.id,
                  status: :intake_in_progress
              }
          }
        end
        let!(:tax_return) { create :tax_return, client: client, year: 2018, service_type: 'drop_off' }

        it "sets service type on created returns to be drop off" do
          expect {
            post :create, params: params
          }.to change(client.tax_returns, :count).by(1)
          expect(TaxReturn.last.service_type).to eq "drop_off"
        end
      end

      context "with invalid tax return" do
        before do
          allow_any_instance_of(Hub::TaxReturnForm).to receive(:valid?).and_return false
        end

        it "does not persist the tax return, renders new and flashes an error" do
          expect {
            post :create, params: params
          }.not_to change(client.tax_returns, :count)
          expect(response).to render_template :new
          expect(flash[:notice]).to include "Please fix indicated"
        end
      end

      context "when moving to a non-assignable user" do
        let(:assigned_user) { create :team_member_user, name: "The Unassignable User" }

        it "does not persist the tax return, renders new and flashes an error" do
          expect {
            post :create, params: params
          }.not_to change(client.tax_returns, :count)
          expect(response).to be_forbidden
        end
      end

      context "with an archived intake" do
        let(:user) { team_member }

        before do
          client.intake.update(product_year: Rails.configuration.product_year - 2)
        end

        it "response is forbidden (403)" do
          post :create, params: params
          expect(response).to be_forbidden
        end
      end
    end

    context "an unauthorized user" do
      before do
        sign_in unauthorized_team_member
      end

      it "is not allowed to access the page" do
        post :create, params: params
        expect(response).to be_forbidden
      end
    end
  end

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

        it "returns a list of org leads, site coords, and team members at the client's assigned organization, the assigned user, and myself" do
          get :edit, params: params, format: :js, xhr: true

          expect(response).to be_ok
          expect(assigns(:assignable_users)).to match_array [user, currently_assigned_coalition_lead, organization_lead, site_coordinator, team_member]
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

      context "with an archived intake" do
        before do
          client.intake.update(product_year: Rails.configuration.product_year - 2)
        end

        it "response is forbidden (403)" do
          get :edit, params: params
          expect(response).to be_forbidden
        end
      end
    end

    context "an unauthorized user" do
      before do
        sign_in unauthorized_team_member
      end

      it "is not allowed to access the page" do
        get :edit, params: params
        expect(response).to be_forbidden
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

      context "when assigning the tax return to themselves" do
        let(:assigned_user) { user }

        it "does not create a user notification or send an email alert" do
          expect {
            put :update, params: params, format: :js, xhr: true
          }.to change(UserNotification, :count).by(0)
        end

        it "assigns the user to the tax return, creates a system note" do
          put :update, params: params, format: :js, xhr: true

          tax_return.reload
          expect(response).to render_template :show
          expect(flash.now[:notice]).to eq "Assigned Lucille's 2018 tax return to #{user.name_with_role}."

          expect(SystemNote::AssignmentChange).to have_received(:generate!).with({ initiated_by: user, tax_return: tax_return })
        end
      end

      context "when trying to assign the tax return to an assignable user" do
        let(:assigned_user) { organization_lead }

        it "assigns the user to the tax return" do
          put :update, params: params, format: :js, xhr: true

          tax_return.reload
          expect(tax_return.assigned_user).to eq organization_lead
          expect(response).to render_template :show
          expect(flash.now[:notice]).to eq "Assigned Lucille's 2018 tax return to #{organization_lead.name_with_role}."
        end

        it "creates a system note" do
          put :update, params: params, format: :js, xhr: true

          expect(SystemNote::AssignmentChange).to have_received(:generate!).with({ initiated_by: user, tax_return: tax_return })
        end

        it "creates a user notification for tax return assignment" do
          put :update, params: params, format: :js, xhr: true

          notification = UserNotification.last
          expect(notification.user).to eq assigned_user
          expect(notification.read).to eq false
          expect(notification.notifiable.assigner).to eq user
          expect(notification.notifiable.tax_return).to eq tax_return
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
        let(:assigned_user) { create(:team_member_user) }

        it "is is forbidden" do
          put :update, params: params, format: :js, xhr: true

          expect(response).to be_forbidden
        end
      end

      context "with an archived intake" do
        before do
          client.intake.update(product_year: Rails.configuration.product_year - 2)
        end

        it "response is forbidden (403)" do
          put :update, params: params
          expect(response).to be_forbidden
        end
      end
    end

    context "an unauthorized user" do
      before do
        sign_in unauthorized_team_member
      end

      it "is not allowed to access the page" do
        put :update, params: params
        expect(response).to be_forbidden
      end
    end
  end
end
