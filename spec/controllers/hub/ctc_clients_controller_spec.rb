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
          primary_birth_date_year: "1963",
          primary_birth_date_month: "9",
          primary_birth_date_day: "10",
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
          spouse_birth_date_year: "1962",
          spouse_birth_date_month: "9",
          spouse_birth_date_day: "7",
          timezone: "America/Chicago",
          signature_method: "online",
          service_type: "drop_off",
          vita_partner_id: vita_partner_id,
          filing_status: "married_filing_jointly",
          refund_payment_method: "check",
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

  describe "#edit" do
    let(:client) { create :client, :with_return, intake: (create :ctc_intake) }
    let(:params) {
      { id: client.id }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      it "renders edit for the client" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:form)).to be_an_instance_of Hub::UpdateCtcClientForm
      end
    end
  end

  describe "#update" do
    let!(:client) { create :client, :with_return, intake: intake }

    let!(:intake) { create :ctc_intake, :filled_out_ctc, :with_contact_info, :with_ssns, :with_dependents, preferred_interview_language: "en" }
    let(:first_dependent) { intake.dependents.first }
    let!(:params) do
      {
        id: client.id,
        hub_update_ctc_client_form: {
          primary_first_name: 'San',
          primary_last_name: 'Mateo',
          preferred_name: intake.preferred_name,
          email_address: 'san@mateo.com',
          phone_number: intake.phone_number,
          sms_phone_number: intake.sms_phone_number,
          preferred_interview_language: intake.preferred_interview_language,
          primary_birth_date_year: intake.primary_birth_date.year,
          primary_birth_date_month: intake.primary_birth_date.month,
          primary_birth_date_day: intake.primary_birth_date.day,
          street_address: intake.street_address,
          city: intake.city,
          state: intake.state,
          zip_code: intake.zip_code,
          sms_notification_opt_in: 'yes',
          email_notification_opt_in: 'yes',
          spouse_first_name: 'San',
          spouse_last_name: 'Diego',
          spouse_email_address: 'san@diego.com',
          spouse_ssn: '123456789',
          spouse_ssn_confirmation: '123456789',
          spouse_birth_date_year: 1980,
          spouse_birth_date_month: 1,
          spouse_birth_date_day: 11,
          state_of_residence: intake.state_of_residence,
          primary_ssn: "111227778",
          primary_ssn_confirmation: "111227778",
          filing_status: client.tax_returns.last.filing_status,
          eip1_amount_received: '9000',
          eip2_amount_received: intake.eip2_amount_received,
          eip1_and_2_amount_received_confidence: intake.eip1_and_2_amount_received_confidence,
          refund_payment_method: "check",
          with_passport_photo_id: "1",
          with_itin_taxpayer_id: "1",
          primary_ip_pin: intake.primary_ip_pin,
          spouse_ip_pin: intake.spouse_ip_pin,
          dependents_attributes: {
            "0" => { id: first_dependent.id, first_name: "Updated Dependent", last_name: "Name", birth_date_year: "2001", birth_date_month: "10", birth_date_day: "9", relationship: first_dependent.relationship, ssn: "111227777" },
          }
        }
      }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :update

    context "with a signed in user" do
      let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

      before do
        sign_in user
        allow(SystemNote::ClientChange).to receive(:generate!)
      end

      it "updates the clients intake and creates a system note" do
        post :update, params: params
        client.reload
        intake.reload
        expect(intake.primary_first_name).to eq "San"
        expect(client.legal_name).to eq "San Mateo"
        expect(client.intake.email_address).to eq "san@mateo.com"
        expect(client.intake.eip1_amount_received).to eq 9000
        expect(client.intake.spouse_last_name).to eq "Diego"
        expect(client.intake.spouse_email_address).to eq "san@diego.com"
        expect(client.intake.spouse_ssn).to eq "123456789"
        expect(client.intake.spouse_birth_date).to eq Date.new(1980, 1, 11)
        expect(first_dependent.reload.first_name).to eq "Updated Dependent"
        expect(client.intake.dependents.count).to eq 1
        expect(response).to redirect_to hub_client_path(id: client.id)
        expect(SystemNote::ClientChange).to have_received(:generate!).with(initiated_by: user, intake: intake)
      end

      context "when the client's email address has changed" do
        before do
          params[:hub_update_ctc_client_form][:email_address] = 'changed@example.com'
        end

        it "sends a message to the new and old email addresses" do
          expect do
            post :update, params: params
          end.to change(OutgoingEmail, :count).by(2)

          expect(OutgoingEmail.all.map(&:to)).to match_array(['cher@example.com', 'changed@example.com'])
        end
      end

      context "when the client's phone number has changed" do
        before do
          params[:hub_update_ctc_client_form][:sms_phone_number] = '4155551234'
        end

        it "sends a message to the new and old phone numbers" do
          expect do
            post :update, params: params
          end.to change(OutgoingTextMessage, :count).by(2)

          expect(OutgoingTextMessage.all.map(&:to)).to match_array(['(415) 555-1212', '(415) 555-1234'])
        end
      end

      context "with invalid params" do
        let(:params) {
          {
            id: client.id,
            hub_update_ctc_client_form: {
              primary_first_name: "",
            }
          }
        }

        it "renders edit" do
          post :update, params: params

          expect(response).to render_template :edit
        end
      end

      context "with invalid dependent params" do
        let(:params) {
          {
            id: client.id,
            hub_update_ctc_client_form: {
              dependents_attributes: { 0 => { "first_name": "", last_name: "", birth_date_month: "", birth_date_year: "", birth_date_day: "" } },
            }
          }
        }

        it "renders edit" do
          post :update, params: params

          expect(response).to render_template :edit
        end

        it "displays a flash message" do
          post :update, params: params
          expect(flash[:alert]).to eq "Please fix indicated errors before continuing."
        end
      end
    end
  end
end
