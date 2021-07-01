require "rails_helper"

RSpec.describe Hub::CtcClientsController do
  let!(:organization) { create :organization, allows_greeters: false, processes_ctc: true }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#new" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :new
    render_views

    context "as an authenticated user" do
      before { sign_in user }

      it "responds with ok" do
        get :new
        expect(response).to be_ok
      end

      it "displays an input for choosing an organization" do
        get :new
        expect(response.body).to have_text("Assign to")
      end
    end

    context "as an admin" do
      before { sign_in create(:admin_user) }

      let!(:other_organization) { create :organization, processes_ctc: true }
      let!(:unavailable_org) { create :organization, processes_ctc: false }

      it "loads all the vita partners and shows a select input" do
        get :new

        expect(assigns(:vita_partners)).to include organization
        expect(assigns(:vita_partners)).to include other_organization
        expect(assigns(:vita_partners)).not_to include unavailable_org

        expect(response.body).to have_text("Assign to")
      end
    end
  end

  describe "#create" do
    let(:vita_partner_id) { user.role.vita_partner_id }
    let(:params) do
      {
        hub_create_ctc_client_form: {
          primary_first_name: "New",
          primary_last_name: "Name",
          primary_ssn: '111-22-3333',
          primary_ssn_confirmation: '111-22-3333',
          preferred_name: "Newly",
          preferred_interview_language: "es",
          email_address: "someone@example.com",
          phone_number: "+15005550006",
          sms_phone_number: "+15005550006",
          street_address: "972 Mission St.",
          city: "San Francisco",
          state_of_residence: "CA",
          zip_code: "94103",
          sms_notification_opt_in: "yes",
          email_notification_opt_in: "no",
          spouse_first_name: "Newly",
          spouse_last_name: "Wed",
          spouse_email_address: "spouse@example.com",
          spouse_ssn: '111-22-3333',
          spouse_ssn_confirmation: '111-22-3333',
          timezone: "America/Chicago",
          signature_method: "online",
          service_type: "drop_off",
          vita_partner_id: vita_partner_id,
          filing_status: "married_filing_jointly",
          ctc_refund_delivery_method: "check",
          bank_account_type: "checking",
          with_passport_photo_id: "1",
          with_itin_taxpayer_id: "1",
          navigator_name: "Terry Taxseason",
          navigator_has_verified_client_identity: "1",
        },
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before { sign_in user }

      context "with valid params" do
        it "creates a new client in the user's organization and redirects to the new client's profile page" do
          expect do
            post :create, params: params
          end.to change(Client, :count).by 1
          expect(Client.last.vita_partner).to eq(organization)
          expect(flash[:notice]).to eq "Client successfully created."
          expect(response).to redirect_to(hub_client_path(id: Client.last.id))
        end
      end

      context "with invalid params" do
        let(:params) do
          {
            hub_create_ctc_client_form: {
              primary_first_name: "",
            }
          }
        end

        it "does not save the client and renders new" do
          expect do
            post :create, params: params
          end.not_to change(Client, :count)

          expect(response).to be_ok
          expect(response).to render_template(:new)
        end
      end

      context "with a vita partner they do not have access to" do
        let(:vita_partner_id) { create(:vita_partner).id }

        it "does not save the client and renders new" do
          expect do
            post :create, params: params
          end.not_to change(Client, :count)

          expect(response).to be_ok
          expect(response).to render_template(:new)
        end
      end
    end

    context "as a team member user" do
      let(:user) { create(:user, role: create(:team_member_role, site: create(:site))) }
      before { sign_in user }

      context "with valid params" do
        it "assigns the client to the team member's site" do
          expect do
            post :create, params: params
          end.to change(Client, :count).by 1
          expect(Client.last.vita_partner).to eq(user.role.site)
        end
      end
    end

    context "as an authenticated admin user" do
      let(:other_organization) { create :organization }

      before { sign_in create(:admin_user) }

      context "when assigning to an org you are not in" do
        before do
          params[:hub_create_ctc_client_form][:vita_partner_id] = other_organization.id
        end

        it "creates a new client in that org" do
          expect do
            post :create, params: params
          end.to change(Client, :count).by 1
          expect(Client.last.vita_partner).to eq(other_organization)
        end
      end
    end
  end
end
