require "rails_helper"

RSpec.describe CaseManagement::ClientsController do
  describe "#create" do
    let(:user) { create :user_with_org }
    let(:intake) do
      create(
        :intake,
        client: nil,
        email_address: "client@example.com",
        phone_number: "14155537865",
        preferred_name: "Casey",
        vita_partner: user.vita_partner
      )
    end
    let(:params) do
      { intake_id: intake.id }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated admin user" do
      before { sign_in(user) }

      context "without an intake id" do
        it "does nothing and returns invalid request status code" do
          expect {
            post :create, params: {}
          }.not_to change(Client, :count)

          expect(response.status).to eq 422
        end
      end

      context "with an intake id" do
        context "with an intake that does not yet have a client" do
          it "creates a client linked to the intake and redirects to show" do
            expect {
              post :create, params: params
            }.to change(Client, :count).by(1)

            client = Client.last
            expect(client.intake).to eq(intake)
            expect(client.vita_partner).to eq(intake.vita_partner)
            expect(intake.reload.client).to eq client
            expect(response).to redirect_to case_management_client_path(id: client.id)
          end
        end

        context "with an intake that already has a client" do
          let(:client) { create :client, vita_partner: user.vita_partner }
          let!(:intake) { create :intake, client: client }

          it "just redirects to the existing client" do
            expect {
              post :create, params: params
            }.not_to change(Client, :count)

            expect(response).to redirect_to case_management_client_path(id: client.id)
          end
        end
      end
    end
  end

  describe "#show" do
    let(:vita_partner) { create :vita_partner }
    let(:user) { create :user, vita_partner: vita_partner }
    let(:intake) do
      create :intake,
             :with_contact_info,
             primary_first_name: "Legal",
             primary_last_name: "Name",
             locale: "en",
             preferred_interview_language: "es",
             needs_help_2019: "yes",
             needs_help_2018: "yes",
             married: "yes",
             lived_with_spouse: "yes",
             filing_joint: "yes",
             state: "CA",
             city: "Oakland",
             zip_code: "94606",
             street_address: "123 Lilac Grove Blvd",
             spouse_first_name: "My",
             spouse_last_name: "Spouse",
             vita_partner: vita_partner
    end

    let(:client) { create :client, intake: intake, vita_partner: vita_partner, tax_returns: [(create :tax_return, year: 2019)] }
    let(:params) { {id: client.id} }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated user" do
      render_views

      before { sign_in(user) }

      it "shows client information" do
        get :show, params: params
        header = Nokogiri::HTML.parse(response.body).at_css(".client-header")
        expect(header).to have_text("2019")
        profile = Nokogiri::HTML.parse(response.body).at_css(".client-profile")
        expect(profile).to have_text(client.preferred_name)
        expect(profile).to have_text(client.legal_name)
        expect(profile).to have_text("2019, 2018")
        expect(profile).to have_text(client.email_address)
        expect(profile).to have_text(client.phone_number)
        expect(profile).to have_text("English")
        expect(profile).to have_text("Marital Status: Married, Lived with spouse")
        expect(profile).to have_text("Filing Status: Filing jointly")
        expect(profile).to have_text("Oakland, CA 94606")
        expect(profile).to have_text("Spouse Contact Info")
      end

      context "when a client needs attention" do
        before { client.touch(:response_needed_since) }

        it "adds the needs attention icon into the DOM" do
          get :show, params: params
          profile = Nokogiri::HTML.parse(response.body)
          expect(profile).to have_css("i.needs-response")
        end
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated user" do
      render_views

      let(:vita_partner) { create(:vita_partner) }
      let(:user) { create(:user_with_org, vita_partner: vita_partner) }

      before { sign_in user }

      context "with some existing clients" do
        let!(:george_sr) { create :client, vita_partner: vita_partner, intake: create(:intake, :filled_out, preferred_name: "George Sr.", needs_help_2019: "yes", needs_help_2018: "yes", locale: "en") }
        let!(:michael) { create :client, vita_partner: vita_partner, intake: create(:intake, :filled_out, preferred_name: "Michael", needs_help_2019: "yes", needs_help_2017: "yes") }
        let!(:tobias) { create :client, vita_partner: vita_partner, intake: create(:intake, :filled_out, preferred_name: "Tobias", needs_help_2018: "yes", locale: "es") }
        let(:assigned_user) { create :user, name: "Lindsay", vita_partner: vita_partner }
        let!(:tobias_2019_return) { create :tax_return, client: tobias, year: 2019, assigned_user: assigned_user, status: "intake_in_progress" }
        let!(:tobias_2018_return) { create :tax_return, client: tobias, year: 2018, assigned_user: assigned_user }

        it "shows a list of clients and client information" do
          get :index
          expect(assigns(:clients).count).to eq 3
          html = Nokogiri::HTML.parse(response.body)
          expect(html).to have_text("Updated At")
          expect(html.at_css("#client-#{george_sr.id}")).to have_text("George Sr.")
          expect(html.at_css("#client-#{george_sr.id}")).to have_text(george_sr.vita_partner.display_name)
          expect(html.at_css("#client-#{george_sr.id} a")["href"]).to eq case_management_client_path(id: george_sr)
          expect(html.at_css("#client-#{george_sr.id}")).to have_text("English")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Spanish")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Intake / In progress")

        end

        it "shows all returns for a client and users assigned to those returns" do
          get :index

          html = Nokogiri::HTML.parse(response.body)
          tobias_row = html.at_css("#client-#{tobias.id}")
          tobias_2019_year = tobias_row.at_css("#tax-return-#{tobias_2019_return.id}")
          expect(tobias_2019_year).to have_text "2019"
          tobias_2019_assignee = tobias_row.at_css("#tax-return-#{tobias_2019_return.id}")
          expect(tobias_2019_assignee).to have_text "Lindsay"
          tobias_2018_year = tobias_row.at_css("#tax-return-#{tobias_2018_return.id}")
          expect(tobias_2018_year).to have_text "2018"
          tobias_2018_assignee = tobias_row.at_css("#tax-return-#{tobias_2018_return.id}")
          expect(tobias_2018_assignee).to have_text "Lindsay"
        end

        describe "when a client needs attention" do
          it "adds the needs attention icon into the DOM" do
            tobias.touch(:response_needed_since)
            get :index
            html = Nokogiri::HTML.parse(response.body)
            expect(html.at_css("#client-#{michael.id}")).not_to have_css("i.needs-response")
            expect(html.at_css("#client-#{tobias.id}")).to have_css("i.needs-response")
          end
        end
      end

      context "sorting and ordering" do
        context "with client  as sort param" do
          let(:params) { { column: "preferred_name" } }
          let!(:alex) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Alex") }
          let!(:ben) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Ben") }

          it "orders clients by name asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("preferred_name")
            expect(assigns[:sort_order]).to eq("asc")
            expect(assigns(:clients).length).to eq 2

            expect(assigns(:clients)).to eq [alex, ben]
          end

          it "orders clients by name desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("preferred_name")
            expect(assigns[:sort_order]).to eq("desc")
            expect(assigns(:clients).length).to eq 2

            expect(assigns(:clients)).to eq [ben, alex]
          end
        end

        context "with id as sort param" do
          let(:params) { { column: "id" } }
          let!(:first_id) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Alex") }
          let!(:second_id) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Ben") }

          it "orders clients by name asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("id")
            expect(assigns[:sort_order]).to eq("asc")

            expect(assigns(:clients)).to eq [first_id, second_id]
          end

          it "orders clients by name desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("id")
            expect(assigns[:sort_order]).to eq("desc")

            expect(assigns(:clients)).to eq [second_id, first_id]
          end
        end

        context "with updated_at as sort param" do
          let(:params) { { column: "updated_at" } }
          let!(:one) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Alex") }
          let!(:two) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Ben") }

          it "orders clients by name asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("updated_at")
            expect(assigns[:sort_order]).to eq("asc")

            expect(assigns(:clients)).to eq [one, two]
          end

          it "orders clients by name desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("updated_at")
            expect(assigns[:sort_order]).to eq("desc")

            expect(assigns(:clients)).to eq [two, one]

            one.touch
            get :index, params: params
            expect(assigns(:clients)).to eq [one, two]
          end
        end

        context "with locale as sort param" do
          let(:params) { { column: "locale" } }
          let!(:spanish) { create :client, vita_partner: vita_partner, intake: create(:intake, locale: "es") }
          let!(:english) { create :client, vita_partner: vita_partner, intake: create(:intake, locale: "en") }

          it "orders clients by locale asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("locale")
            expect(assigns[:sort_order]).to eq("asc")

            expect(assigns(:clients)).to eq [english, spanish]
          end

          it "orders clients by name desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("locale")
            expect(assigns[:sort_order]).to eq("desc")

            expect(assigns(:clients)).to eq [spanish, english]
          end
        end

        context "with no or bad params" do
          let!(:first_id) { create :client, vita_partner: vita_partner, intake: create(:intake) }
          let!(:second_id) { create :client, vita_partner: vita_partner, intake: create(:intake) }

          it "defaults to sorting by id, desc by default" do
            get :index

            expect(assigns[:sort_column]).to eq "id"
            expect(assigns[:sort_order]).to eq "desc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end

          it "defaults to sorting by id, desc with bad params" do
            get :index, params: { column: "bad_sort", order: "no_order" }

            expect(assigns[:sort_column]).to eq "id"
            expect(assigns[:sort_order]).to eq "desc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end
        end
      end
    end
  end

  describe "#response_needed" do
    let(:params) do
      { id: client.id, client: {} }
    end
    let(:client) { create :client, vita_partner: create(:vita_partner) }
    let(:current_user) { create :user_with_org, vita_partner: client.vita_partner }
    before { sign_in(current_user) }

    it "redirects to case management client path" do
      patch :response_needed, params: params
      expect(response).to redirect_to(case_management_client_path(id: client.id))
    end

    context "with dismiss param" do

      before do
        params[:client][:action] = "clear"
      end

      it "removes response_needed_since value from client" do
        client.touch(:response_needed_since)
        patch :response_needed, params: params
        client.reload
        expect(client.response_needed_since).to be_nil
      end
    end

    context "with add flag param" do
      before do
        params[:client][:action] = "set"
      end

      it "adds response_needed_since to client" do
        client.clear_response_needed
        patch :response_needed, params: params
        client.reload
        expect(client.response_needed_since).to be_present
      end
    end

  end

  describe "#edit" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let(:params) {
      { id: client.id }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before do
        sign_in user
      end

      it "renders edit for the client" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:form)).to be_an_instance_of CaseManagement::ClientIntakeForm
      end
    end
  end

  describe "#update" do
    let(:vita_partner) { create :vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let(:intake) { create :intake, client: client }
    let(:params) {
      {
        id: client.id,
        case_management_client_intake_form: {
          primary_first_name: "Updated",
          primary_last_name: "Name",
          preferred_name: intake.preferred_name,
          preferred_interview_language: intake.preferred_interview_language,
          married: intake.married,
          separated: intake.separated,
          widowed: intake.widowed,
          lived_with_spouse: intake.lived_with_spouse,
          divorced: intake.divorced,
          divorced_year: intake.divorced_year,
          separated_year: intake.separated_year,
          widowed_year: intake.widowed_year,
          email_address: intake.email_address,
          phone_number: intake.phone_number,
          sms_phone_number: intake.sms_phone_number,
          street_address: intake.street_address,
          city: intake.city,
          state: intake.state,
          zip_code: intake.zip_code,
          sms_notification_opt_in: intake.sms_notification_opt_in,
          email_notification_opt_in: intake.email_notification_opt_in,
          spouse_first_name: intake.spouse_first_name,
          spouse_last_name: intake.spouse_last_name,
          spouse_email_address: intake.spouse_email_address,
          filing_joint: intake.filing_joint,
        }
      }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "with a signed in user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before do
        sign_in user
      end

      it "updates the clients intake" do
        post :update, params: params

        client.reload
        expect(client.intake.primary_first_name).to eq "Updated"
        expect(client.legal_name).to eq "Updated Name"
        expect(response).to redirect_to case_management_client_path(id: client.id)
      end

      context "with invalid params" do
        let(:params) {
          {
            id: client.id,
            case_management_client_intake_form: {
              primary_first_name: "",
            }
          }
        }

        it "renders edit" do
          post :update, params: params

          expect(response).to render_template :edit
        end
      end
    end
  end
end
