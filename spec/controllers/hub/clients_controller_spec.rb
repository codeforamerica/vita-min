require "rails_helper"

RSpec.describe Hub::ClientsController do
  describe "#create" do
    let(:user) { create :user_with_membership }
    let(:vita_partner) { user.memberships.first.vita_partner }
    let(:intake) do
      create(
        :intake,
        client: nil,
        email_address: "client@example.com",
        phone_number: "14155537865",
        preferred_name: "Casey",
        vita_partner: vita_partner
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
            expect(response).to redirect_to hub_client_path(id: client.id)
          end
        end

        context "with an intake that already has a client" do
          let(:client) { create :client, vita_partner: vita_partner }
          let!(:intake) { create :intake, client: client }

          it "just redirects to the existing client" do
            expect {
              post :create, params: params
            }.not_to change(Client, :count)

            expect(response).to redirect_to hub_client_path(id: client.id)
          end
        end
      end
    end
  end

  describe "#show" do
    let(:user) { create :user_with_membership }
    let(:vita_partner) { user.memberships.first.vita_partner }
    let(:client) { create :client, vita_partner: vita_partner, intake: intake, tax_returns: [(create :tax_return, year: 2019)] }
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
             vita_partner: vita_partner,
             interview_timing_preference: "I'm available every morning except Fridays.",
             timezone: "America/Los_Angeles",
             dependents: [(build :dependent), (build :dependent)]
    end

    let(:params) { { id: client.id } }

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
        expect(profile).to have_text("Pacific Time (US & Canada)")
        expect(profile).to have_text("I'm available every morning except Fridays.")
        expect(profile).to have_text("Dependents: 2")
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

      let(:user) { create(:user_with_membership) }
      let(:vita_partner) { user.memberships.first.vita_partner }

      before { sign_in user }

      context "with some existing clients" do
        render_views

        let!(:george_sr) { create :client, vita_partner: vita_partner, intake: create(:intake, :filled_out, preferred_name: "George Sr.", needs_help_2019: "yes", needs_help_2018: "yes", locale: "en") }
        let!(:george_sr_2019_return) { create :tax_return, client: george_sr, year: 2019, assigned_user: assigned_user, status: "intake_in_progress" }
        let!(:george_sr_2018_return) { create :tax_return, client: george_sr, year: 2018, assigned_user: assigned_user, status: "intake_open" }
        let!(:michael) { create :client, vita_partner: vita_partner, intake: create(:intake, :filled_out, preferred_name: "Michael", needs_help_2019: "yes", needs_help_2017: "yes") }
        let!(:michael_2019_return) { create :tax_return, client: michael, year: 2019, assigned_user: assigned_user, status: "intake_in_progress" }
        let!(:tobias) { create :client, vita_partner: vita_partner, intake: create(:intake, :filled_out, preferred_name: "Tobias", needs_help_2018: "yes", locale: "es") }
        let(:assigned_user) { create :user, name: "Lindsay", vita_partner: vita_partner }
        let!(:tobias_2019_return) { create :tax_return, client: tobias, year: 2019, assigned_user: assigned_user, status: "intake_in_progress" }
        let!(:tobias_2018_return) { create :tax_return, client: tobias, year: 2018, assigned_user: assigned_user }
        let!(:lucille) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Lucille") }
        let!(:lucille_2018_return) { create(:tax_return, client: lucille, year: 2018, status: "intake_before_consent", assigned_user: assigned_user) }

        it "does not show a client whose tax returns are all before_consent" do
          get :index
          expect(assigns(:clients).pluck(:id)).not_to include(lucille.id)
        end

        it "shows a list of clients and client information" do
          get :index
          expect(assigns(:clients).count).to eq 3
          expect(assigns(:clients)).to include george_sr
          expect(assigns(:clients)).to include michael
          expect(assigns(:clients)).to include tobias

          html = Nokogiri::HTML.parse(response.body)
          expect(html).to have_text("Updated At")
          expect(html.at_css("#client-#{george_sr.id}")).to have_text("George Sr.")
          expect(html.at_css("#client-#{george_sr.id}")).to have_text(george_sr.vita_partner.display_name)
          expect(html.at_css("#client-#{george_sr.id} a")["href"]).to eq hub_client_path(id: george_sr)
          expect(html.at_css("#client-#{george_sr.id}")).to have_text("English")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Spanish")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Intake")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("In progress")
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
        context "with client as sort param" do
          let(:params) { { column: "preferred_name" } }
          let!(:alex) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Alex") }
          let!(:ben) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Ben") }

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
          let!(:first_id) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Alex") }
          let!(:second_id) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Ben") }

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
          let!(:one) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Alex") }
          let!(:two) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Ben") }

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
          end
        end

        context "with locale as sort param" do
          let(:params) { { column: "locale" } }
          let!(:spanish) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, locale: "es") }
          let!(:english) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake, locale: "en") }

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
          let!(:first_id) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake) }
          let!(:second_id) { create :client, :with_return, vita_partner: vita_partner, intake: create(:intake) }

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

      context "filtering" do

        context "with a status filter" do
          let!(:included_client) { create :client, vita_partner: vita_partner, tax_returns: [(create :tax_return, status: "intake_in_progress")], intake: (create :intake) }
          let!(:excluded_client) { create :client, vita_partner: vita_partner, tax_returns: [(create :tax_return, status: "intake_open")], intake: (create :intake) }

          it "includes clients with tax returns in that status" do
            get :index, params: { status: "intake_in_progress"}
            expect(assigns(:clients)).to eq [included_client]
          end
        end

        context "with a stage filter" do
          let!(:included_client) { create :client, vita_partner: vita_partner, tax_returns: [(create :tax_return, status: "intake_in_progress")], intake: (create :intake) }
          let!(:excluded_client) { create :client, vita_partner: vita_partner, tax_returns: [(create :tax_return, status: "prep_ready_for_call")], intake: (create :intake) }

          it "includes clients with tax returns in that stage" do
            get :index, params: { status: "intake" }
            expect(assigns(:clients)).to eq [included_client]
          end
        end

        context "filtering by tax return year" do
          let!(:return_3020) { create :tax_return, year: 3020, client: create(:client, vita_partner: user.memberships.first.vita_partner), status: "intake_open" }
          it "filters in" do
            get :index, params: { year: 3020 }
            expect(assigns(:clients)).to eq [return_3020.client]
          end
        end

        context "filtering by unassigned" do
          let!(:unassigned) { create :tax_return, year: 2012, assigned_user: nil, client: create(:client, vita_partner: user.memberships.first.vita_partner), status: "intake_open" }
          it "filters in" do
            get :index, params: { unassigned: true }
            expect(assigns(:clients)).to include unassigned.client
          end
        end

        context "filtering by needs response" do
          let!(:needs_response) { create :client, response_needed_since: DateTime.now, vita_partner: user.memberships.first.vita_partner, tax_returns: [(create :tax_return)] }
          it "filters in" do
            get :index, params: { needs_response: true }
            expect(assigns(:clients)).to include needs_response
          end
        end
      end
    end
  end

  describe "#response_needed" do
    let(:params) do
      { id: client.id, client: {} }
    end
    let(:user) { create :user_with_membership }
    let(:client) { create :client, vita_partner: user.memberships.first.vita_partner }
    before { sign_in(user) }

    it "redirects to hub client path" do
      patch :response_needed, params: params
      expect(response).to redirect_to(hub_client_path(id: client.id))
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
    let(:user) { create :user_with_membership }
    let(:vita_partner) { user.memberships.first.vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }
    let(:params) {
      { id: client.id }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders edit for the client" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:form)).to be_an_instance_of Hub::ClientIntakeForm
      end
    end
  end

  describe "#update" do
    let(:user) { create :user_with_membership }
    let(:vita_partner) { user.memberships.first.vita_partner }
    let(:client) { create :client, vita_partner: vita_partner }

    let(:intake) { create :intake, client: client, dependents: [build(:dependent), build(:dependent)] }
    let(:first_dependent) { intake.dependents.first }
    let(:params) {
      {
        id: client.id,
        hub_client_intake_form: {
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
          timezone: "America/Chicago",
          interview_timing_preference: "Tomorrow!",
          dependents_attributes: {
              "0" => { id: intake.dependents.first.id, first_name: "Updated Dependent", last_name: "Name", birth_date_year: "2001", birth_date_month: "10", birth_date_day: "9" },
              "1" => { first_name: "A New", last_name: "Dependent", birth_date_year: "2007", birth_date_month: "12", birth_date_day: "1" },
              "2" => { id: intake.dependents.last.id, _destroy: "1" }
          }
        }
      }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "with a signed in user" do

      before do
        sign_in user
      end

      it "updates the clients intake" do
        post :update, params: params
        client.reload
        expect(client.intake.primary_first_name).to eq "Updated"
        expect(client.legal_name).to eq "Updated Name"
        expect(client.intake.interview_timing_preference).to eq "Tomorrow!"
        expect(client.intake.timezone).to eq "America/Chicago"
        first_dependent.reload
        expect(first_dependent.first_name).to eq "Updated Dependent"
        expect(client.intake.dependents.count).to eq 2
        expect(response).to redirect_to hub_client_path(id: client.id)
      end

      context "with invalid params" do
        let(:params) {
          {
            id: client.id,
            hub_client_intake_form: {
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
              hub_client_intake_form: {
                  dependents_attributes: { 0 => {"first_name": "", last_name: "", birth_date_month: "", birth_date_year: "", birth_date_day: ""}},
              }
          }
        }

        it "renders edit" do
          post :update, params: params

          expect(response).to render_template :edit
        end

        it "displays a flash message" do
          post :update, params: params
          expect(flash[:warning]).to eq "Please enter the first name, last name, birth date of each dependent."
        end
      end
    end
  end

  describe "#edit_take_action" do
    let(:user) { create :user_with_membership }
    let(:client) { create(:client, vita_partner: user.memberships.first.vita_partner) }
    let!(:intake) { create :intake, client: client, email_notification_opt_in: "yes" }
    let!(:tax_return_2019) { create :tax_return, client: client, year: 2019 }
    let!(:tax_return_2018) { create :tax_return, client: client, year: 2018 }
    let(:params) { { id: client } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit_take_action

    context "as an authenticated user" do
      before { sign_in user }

      it "returns an ok response" do
        get :edit_take_action, params: params

        expect(response).to be_ok
      end

      it "finds all tax returns" do
        get :edit_take_action, params: params

        expect(assigns(:take_action_form)).to be_present
        expect(assigns(:take_action_form).tax_returns.length).to eq 2
      end

      context "with a tax_return_status param that has a template (from client profile link)" do
        let(:params) do
          {
            id: client,
            tax_return: {
              id: tax_return_2019.id,
              status: "intake_more_info",
            },
          }
        end

        render_views

        before do
          intake.update(locale: "es")
          allow_any_instance_of(Intake).to receive(:get_or_create_requested_docs_token).and_return "t0k3n"
        end

        it "prepopulates the form using the locale, status, and relevant template" do
          get :edit_take_action, params: params

          filled_out_template = <<~MESSAGE_BODY
            ¡Hola!

            Para continuar presentando sus impuestos, necesitamos que nos envíe:
              - Identificación
              - Selfie
              - SSN o ITIN
              - Otro
            Sube tus documentos de forma segura por http://test.host/es/documents/add/t0k3n

            Por favor, háganos saber si usted tiene alguna pregunta. No podemos preparar sus impuestos sin esta información.

            ¡Gracias!
            Su equipo de impuestos en GetYourRefund.org
          MESSAGE_BODY

          expect(assigns(:take_action_form).tax_returns[0].id).to eq tax_return_2018.id
          expect(assigns(:take_action_form).tax_returns[0].status).to eq "intake_in_progress"
          expect(assigns(:take_action_form).tax_returns[1].id).to eq tax_return_2019.id
          expect(assigns(:take_action_form).tax_returns[1].status).to eq "intake_more_info"
          expect(assigns(:take_action_form).locale).to eq "es"
          expect(assigns(:take_action_form).message_body).to eq filled_out_template
          expect(assigns(:take_action_form).contact_method).to eq "email"
        end

        context "with contact preferences" do
          before { client.intake.update(sms_notification_opt_in: "yes", email_notification_opt_in: "no") }

          it "includes a warning based on contact preferences" do
            get :edit_take_action, params: params

            expect(assigns(:take_action_form).contact_method).to eq "text_message"
            expect(response.body).to have_text "This client prefers text message instead of email"
          end
        end

        context "with a locale that differs from the client's preferred interview language" do
          before { client.intake.update(preferred_interview_language: "fr") }

          it "includes a warning about the client's language preferences" do
            get :edit_take_action, params: params

            expect(response.body).to have_text "This client requested French for their interview"
          end
        end
      end
    end
  end

  describe "#update_take_action" do
    let(:user) { create :user_with_membership }
    let!(:intake) { create :intake, email_address: "gob@example.com", sms_phone_number: "+14155551212", client: client }
    let(:client) { create :client, vita_partner: user.memberships.first.vita_partner }
    let(:params) do
      {
        id: client,
        hub_take_action_form: {
          tax_returns: {
            "#{tax_return_2019.id}": {
              status: new_status_2019
            },
            "#{tax_return_2018.id}": {
              status: new_status_2018
            }
          },
          internal_note_body: internal_note_body,
          locale: locale,
          message_body: message_body,
          contact_method: contact_method,
        }
      }
    end
    let(:tax_return_2019) { create :tax_return, status: "intake_in_progress", client: client, year: 2019 }
    let(:tax_return_2018) { create :tax_return, status: "intake_in_progress", client: client, year: 2018 }
    let(:new_status_2019) { "intake_in_progress" }
    let(:new_status_2018) { "intake_in_progress" }
    let(:locale) { "en" }
    let(:internal_note_body) { "" }
    let(:message_body) { "" }
    let(:contact_method) { "email" }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_take_action

    context "as an authenticated user" do
      before { sign_in user }

      it "redirects to the messages tab with a basic flash success message" do
        post :update_take_action, params: params

        expect(response).to redirect_to hub_client_path(id: client)
        expect(flash[:notice].strip).to eq "Success: Action taken!"
      end

      context "when a new status is submitted" do
        let(:new_status_2019) { "prep_ready_for_call" }

        it "updates the status and creates a system note" do
          expect(SystemNote).to receive(:create_status_change_note).with(user, tax_return_2019)

          post :update_take_action, params: params
          expect(tax_return_2019.reload.status).to eq(new_status_2019)
          expect(flash[:notice]).to match "Updated status"
        end
      end

      context "when the statuses are the same as the current statuses" do
        let(:new_status_2019) { "intake_in_progress" }
        let(:new_status_2018) { "intake_in_progress" }

        it "does not create a system status change note" do
          expect do
            post :update_take_action, params: params
          end.not_to change(SystemNote, :count)
        end
      end

      context "creating a note" do
        let(:internal_note_body) { "Lorem ipsum note about client tax return" }

        it "saves a note" do
          expect do
            post :update_take_action, params: params
          end.to change(Note, :count).by(1)

          note = Note.last
          expect(note.client).to eq client
          expect(note.body).to eq internal_note_body
          expect(note.user).to eq user

          expect(flash[:notice]).to match "Added internal note"
        end
      end

      context "when the note field is blank" do
        let(:internal_note_body) { " \n" }

        it "does not save a note" do
          expect do
            post :update_take_action, params: params
          end.not_to change(Note, :count)
        end
      end

      context "when the message body is present" do
        let(:message_body) { "There's always money in the banana stand" }

        context "and the contact method is email" do
          let(:contact_method) { "email" }
          let(:locale) { "es" }
          before { allow(subject).to receive(:send_email) }

          it "sends an email using the form locale and mentions that in the flash message" do
            post :update_take_action, params: params

            expect(subject).to have_received(:send_email).with(
              "There's always money in the banana stand", subject_locale: "es"
            )
            expect(flash[:notice]).to match "Sent email"
          end
        end

        context "and the contact method is text message" do
          let(:contact_method) { "text_message" }
          before { allow(subject).to receive(:send_text_message) }

          it "sends a text message and adds that to the flash message" do
            post :update_take_action, params: params

            expect(subject).to have_received(:send_text_message).with("There's always money in the banana stand")
            expect(flash[:notice]).to match "Sent text message"
          end
        end
      end

      context "when the message body is blank" do
        let(:message_body) { " \n" }
        let(:contact_method) { "email" }

        it "does not send a message using the chosen contact method" do
          expect do
            post :update_take_action, params: params
          end.not_to change(OutgoingEmail, :count)
        end
      end

      context "when status is changed, message body is present, and internal note is present" do
        let(:new_status_2019) { "review_in_review" }
        let(:message_body) { "hi" }
        let(:internal_note_body) { "wyd" }
        before { allow(subject).to receive(:send_email) }

        it "adds a flash success message listing all the actions taken" do
          post :update_take_action, params: params

          expect(flash[:notice]).to eq "Success: Action taken! Updated status, sent email, added internal note."
        end
      end
    end
  end
end
