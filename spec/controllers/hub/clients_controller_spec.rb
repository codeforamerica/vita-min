require "rails_helper"

RSpec.describe Hub::ClientsController do
  let!(:organization) { create :organization, allows_greeters: false }
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

      let!(:other_organization) { create :organization }

      it "loads all the vita partners and shows a select input" do
        get :new

        expect(assigns(:vita_partners)).to include organization
        expect(assigns(:vita_partners)).to include other_organization
        expect(response.body).to have_text("Assign to")
      end
    end
  end

  describe "#create" do
    let(:vita_partner_id) { user.role.vita_partner_id }
    let(:params) do
      {
        hub_create_client_form: {
          primary_first_name: "New",
          primary_last_name: "Name",
          preferred_name: "Newly",
          preferred_interview_language: "es",
          primary_ssn: "123456789",
          primary_ssn_confirmation: "123456789",
          primary_tin_type: "ssn",
          married: "yes",
          separated: "no",
          widowed: "no",
          lived_with_spouse: "yes",
          divorced: "no",
          divorced_year: "",
          separated_year: "",
          widowed_year: "",
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
          spouse_tin_type: "ssn",
          spouse_ssn: "123456789",
          spouse_ssn_confirmation: "123456789",
          spouse_email_address: "spouse@example.com",
          filing_joint: "yes",
          timezone: "America/Chicago",
          needs_help_2021: "yes",
          needs_help_2020: "yes",
          needs_help_2019: "yes",
          needs_help_2018: "yes",
          signature_method: "online",
          service_type: "drop_off",
          vita_partner_id: vita_partner_id,
          tax_returns_attributes: {
            "0": {
              year: "2020",
              is_hsa: true,
              certification_level: "advanced"
            },
            "1": {
              year: "2019",
              is_hsa: false,
              certification_level: "basic"
            },
            "2": {
              year: "2018",
              is_hsa: false,
              certification_level: "basic"
            },
            "3": {
              year: "2017",
              is_hsa: false,
              certification_level: "advanced"
            },
          }
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
            hub_create_client_form: {
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
        let(:vita_partner_id) { create(:organization).id }

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
          params[:hub_create_client_form][:vita_partner_id] = other_organization.id
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

  describe "#show" do
    let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }
    let(:client) { create :client, vita_partner: organization, tax_returns: [(create :tax_return, year: 2019, service_type: "drop_off"), (create :tax_return, year: 2018, service_type: "online_intake")] }

    let!(:intake) do
      create :intake,
             :with_ssns,
             :with_contact_info,
             client: client,
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
             vita_partner: organization,
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
        header_tax_return_2019 = header.at_css("#tax-return-#{client.tax_returns.where(year: "2019").first.id}")
        header_tax_return_2018 = header.at_css("#tax-return-#{client.tax_returns.where(year: "2018").first.id}")
        expect(header_tax_return_2019).to have_content("Drop Off")
        expect(header_tax_return_2018).not_to have_content("Drop Off")
        profile = Nokogiri::HTML.parse(response.body).at_css(".client-profile")
        expect(profile).to have_text(client.preferred_name)
        expect(profile).to have_text(client.legal_name)
        expect(profile).to have_text("2019, 2018")
        expect(profile).to have_text(client.email_address)
        expect(profile).to have_text(client.phone_number)
        expect(profile).to have_text("English")
        expect(profile).to have_text("Married, Lived with spouse")
        expect(profile).to have_text("Filing jointly")
        expect(profile).to have_text("Oakland, CA 94606")
        expect(profile).to have_text("Spouse Contact Info")
        expect(profile).to have_text("Pacific Time (US & Canada)")
        expect(profile).to have_text("I'm available every morning except Fridays.")
        expect(profile).to have_text("2")
      end

      context "when a client needs a response" do
        before { client.touch(:flagged_at) }

        it "adds the needs response icon into the DOM" do
          get :show, params: params
          profile = Nokogiri::HTML.parse(response.body)
          expect(profile).to have_css("i.urgent")
        end
      end

      context "when trying to access a client you are not allowed to access" do
        let(:user) { create :user }

        it "renders a helpful interface" do
          get :show, params: params

          expect(response).to be_forbidden
          expect(response.body).to have_text "Oops! Looks like you're trying to access a page or client you do not have access to"
        end
      end
    end

    context "as an authenticated admin" do
      before { sign_in create(:admin_user) }

      context "when a client's account has been locked" do
        before { client.lock_access! }

        render_views
        it "shows a link to unlock the client's account" do
          get :show, params: params

          expect(response.body).to have_text "Unlock account"
        end
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated user" do
      before { sign_in user }

      context "default behaviors" do
        render_views

        let(:assigned_user) { create :user, name: "Lindsay" }
        let!(:george_sr) { create :client, vita_partner: organization, intake: create(:intake, :filled_out, preferred_name: "George Sr.", needs_help_2019: "yes", needs_help_2018: "yes", preferred_interview_language: "en", locale: "en") }
        let!(:george_sr_2019_return) { create :tax_return, :intake_in_progress, client: george_sr, year: 2019, assigned_user: assigned_user }
        let!(:george_sr_2018_return) { create :tax_return, :intake_ready, client: george_sr, year: 2018, assigned_user: assigned_user }
        let!(:michael) { create :client, vita_partner: organization, intake: create(:intake, :filled_out, preferred_name: "Michael", needs_help_2019: "yes", state_of_residence: nil) }
        let!(:michael_2019_return) { create :tax_return, :intake_in_progress, client: michael, year: 2019, assigned_user: assigned_user }
        let!(:tobias) { create :client, vita_partner: organization, intake: create(:intake, :filled_out, preferred_name: "Tobias", needs_help_2018: "yes", preferred_interview_language: "es", state_of_residence: "TX") }
        let!(:tobias_2019_return) { create :tax_return, :intake_in_progress, client: tobias, year: 2019, assigned_user: assigned_user }
        let!(:tobias_2018_return) { create :tax_return, :intake_in_progress, client: tobias, year: 2018, assigned_user: assigned_user }
        let!(:lucille) { create :client, vita_partner: organization, intake: create(:intake, preferred_name: "Lucille") }
        let!(:lucille_2018_return) { create(:tax_return, :intake_before_consent, client: lucille, year: 2018, assigned_user: assigned_user) }
        let!(:bob_loblaw) { create :client, vita_partner: organization, intake: create(:ctc_intake, preferred_name: "Bob Loblaw") }
        let!(:bob_loblaw_online_intake_return) { create :tax_return, :intake_before_consent, service_type: :online_intake, client: bob_loblaw }

        it "does not show a client whose tax returns are all before_consent" do
          get :index
          expect(assigns(:clients).pluck(:id)).not_to include(lucille.id)
          expect(assigns(:clients).pluck(:id)).not_to include(bob_loblaw.id)
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
          expect(html.at_css("#client-#{george_sr.id}")).to have_text(george_sr.vita_partner.name)
          expect(html.at_css("#client-#{george_sr.id} a")["href"]).to eq hub_client_path(id: george_sr)
          expect(html.at_css("#client-#{george_sr.id}")).to have_text("English")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Spanish")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Intake")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("Not ready")
          expect(html.at_css("#client-#{tobias.id}")).to have_text("TX")
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

        context "when a client is flagged" do
          before { tobias.touch(:flagged_at) }

          it "adds the flagged icon into the DOM" do
            get :index

            html = Nokogiri::HTML.parse(response.body)
            expect(html.at_css("#client-#{michael.id}")).not_to have_css("i.urgent")
            expect(html.at_css("#client-#{tobias.id}")).to have_css("i.urgent")
          end
        end

        context "when a client's account is locked" do
          before { george_sr.lock_access! }

          it "shows that their account is locked" do
            get :index

            html = Nokogiri::HTML.parse(response.body)
            expect(html.at_css("#client-#{george_sr.id}")).to have_text("Locked")
          end
        end

        context "when a client has no preferred name" do
          before { george_sr.intake.update(preferred_name: nil) }

          it "shows a default value so you can still click on the client" do
            get :index

            html = Nokogiri::HTML.parse(response.body)
            expect(html.at_css("#client-#{george_sr.id}")).to have_text("Name left blank")
          end
        end

        context "when a client has a most recent communication" do
          let(:time) { DateTime.new(2021, 5, 18, 11, 32) }
          let!(:incoming_text_message) { create :incoming_text_message, client: george_sr, body: "Hi I have a \"question\" about my taxes, but my question is very long, so you might not see all of it", created_at: DateTime.new(2021, 5, 18, 11, 32) }

          it "shows a preview of the most recent message in a tooltip on the client" do
            get :index

            message_summary = <<~BODY
              "Hi I have a "question" about my taxes, but my question is very long, so you..."

              George Sr.
              Tue 5/18/2021 at 4:32 AM PDT
            BODY

            html = Nokogiri::HTML.parse(response.body)
            attrib = html.at_css("#client-#{george_sr.id}").at_css(".tooltip").attr("title")
            expect(attrib.strip).to eq(message_summary.strip)
          end
        end

        context "when there are clients with no current intakes (clients from previous tax years)" do
          let!(:former_year_client) { create :client, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:former_year_tax_return) { create :tax_return, :intake_in_progress, client: former_year_client, year: 2021, assigned_user: assigned_user }

          before do
            # In reality this intake would be moved to the `archived_intakes_2021` table, but removing it from the DB is good enough for our purposes
            former_year_client.intake.destroy
          end

          it "does not show those clients in the list" do
            get :index

            expect(assigns(:clients)).to match_array([george_sr, michael, tobias])
          end
        end
      end

      context "sorting and ordering" do
        context "with client as sort param" do
          let(:params) { { column: "preferred_name" } }
          let!(:alex) { create :client, :with_return, vita_partner: organization, intake: create(:intake, preferred_name: "Alex") }
          let!(:ben) { create :client, :with_return, vita_partner: organization, intake: create(:intake, preferred_name: "Ben") }

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
          let!(:first_id) { create :client, :with_return, vita_partner: organization, intake: create(:intake, preferred_name: "Alex") }
          let!(:second_id) { create :client, :with_return, vita_partner: organization, intake: create(:intake, preferred_name: "Ben") }

          it "orders clients by id asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("id")
            expect(assigns[:sort_order]).to eq("asc")

            expect(assigns(:clients)).to eq [first_id, second_id]
          end

          it "orders clients by id desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("id")
            expect(assigns[:sort_order]).to eq("desc")

            expect(assigns(:clients)).to eq [second_id, first_id]
          end
        end

        context "with updated_at as sort param" do
          let(:params) { { column: "updated_at" } }
          let!(:one) { create :client, :with_return, vita_partner: organization, intake: create(:intake, preferred_name: "Alex") }
          let!(:two) { create :client, :with_return, vita_partner: organization, intake: create(:intake, preferred_name: "Ben") }

          it "orders clients by updated_at asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("updated_at")
            expect(assigns[:sort_order]).to eq("asc")

            expect(assigns(:clients)).to eq [one, two]
          end

          it "orders clients by updated_at desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("updated_at")
            expect(assigns[:sort_order]).to eq("desc")

            expect(assigns(:clients)).to eq [two, one]
          end
        end

        context "with locale as sort param" do
          let(:params) { { column: "locale" } }
          let!(:spanish) { create :client, :with_return, vita_partner: organization, intake: create(:intake, locale: "es") }
          let!(:english) { create :client, :with_return, vita_partner: organization, intake: create(:intake, locale: "en") }

          it "orders clients by locale asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("locale")
            expect(assigns[:sort_order]).to eq("asc")

            expect(assigns(:clients)).to eq [english, spanish]
          end

          it "orders clients by locale desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq("locale")
            expect(assigns[:sort_order]).to eq("desc")

            expect(assigns(:clients)).to eq [spanish, english]
          end
        end

        context "with first_unanswered_incoming_interaction_at as sort param" do
          let(:params) { { column: "first_unanswered_incoming_interaction_at" } }
          let!(:first_id) { create :client, :with_return, vita_partner: organization, intake: create(:intake), first_unanswered_incoming_interaction_at: 2.days.ago, last_outgoing_communication_at: 5.day.ago }
          let!(:second_id) { create :client, :with_return, vita_partner: organization, intake: create(:intake), first_unanswered_incoming_interaction_at: 3.days.ago, last_outgoing_communication_at: 5.days.ago }

          it "orders clients by first_unanswered_incoming_interaction_at asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq "first_unanswered_incoming_interaction_at"
            expect(assigns[:sort_order]).to eq "asc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end

          it "orders clients by first_unanswered_incoming_interaction_at desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:sort_column]).to eq "first_unanswered_incoming_interaction_at"
            expect(assigns[:sort_order]).to eq "desc"

            expect(assigns(:clients)).to eq [first_id, second_id]
          end
        end

        context "with no or bad params" do
          let!(:first_id) { create :client, :with_return, vita_partner: organization, intake: create(:intake), last_outgoing_communication_at: 1.day.ago }
          let!(:second_id) { create :client, :with_return, vita_partner: organization, intake: create(:intake), last_outgoing_communication_at: 2.days.ago }

          it "defaults to sorting by last_outgoing_communication_at, asc by default" do
            get :index

            expect(assigns[:sort_column]).to eq "last_outgoing_communication_at"
            expect(assigns[:sort_order]).to eq "asc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end

          it "defaults to sorting by id, desc with bad params" do
            get :index, params: { column: "bad_order", order: "no_order" }

            expect(assigns[:sort_column]).to eq "last_outgoing_communication_at"
            expect(assigns[:sort_order]).to eq "asc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end
        end
      end

      context "pagination - with 26 clients and a page 2 param" do
        let!(:extra_clients) { create_list :client_with_intake_and_return, 25, vita_partner: organization }
        let!(:last_client) { create :client_with_intake_and_return, preferred_name: "Zed", vita_partner: organization }
        let(:params) do
          {
            page: "2",
            column: "preferred_name",
            order: "asc"
          }
        end

        before do
          create(:tax_return, year: 2018, client: Client.first)
        end

        it "only shows the 26th client" do
          get :index, params: params

          expect(assigns(:clients).length).to eq 1
          expect(assigns(:clients)).to match_array [last_client]
        end
      end

      context "tax return count" do
        let!(:over_pagination_clients) { create_list :client_with_intake_and_return, 50, vita_partner: organization }
        let(:params) do
          {
            page: "1"
          }
        end

        it "shows the full amount of tax returns" do
          get :index, params: params

          expect(assigns(:tax_return_count)).to eq 50
        end
      end

      context "ordering tax returns" do
        let(:client) { (create :intake).client }
        let!(:tax_return_2020) { create :tax_return, :intake_in_progress, client: client, year: 2021 }
        let!(:tax_return_2019) { create :tax_return, :intake_in_progress, client: client, year: 2019 }
        before { client.update(vita_partner: organization) }
        render_views

        it "shows the tax returns in order of year" do
          get :index, params: {}

          html = Nokogiri::HTML.parse(response.body)
          expect(html.css(".tax-return-list__year").first).to have_text("2019")
          expect(html.css(".tax-return-list__year").last).to have_text(TaxReturn.current_tax_year)
        end
      end

      context "filtering" do
        context "with a status filter" do
          let!(:included_client) { create :client, vita_partner: organization, tax_returns: [(create :tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:excluded_client) { create :client, vita_partner: organization, tax_returns: [(create :tax_return, :intake_ready)], intake: (build :intake) }

          it "includes clients with tax returns in that status" do
            get :index, params: { status: "intake_in_progress" }
            expect(assigns(:clients)).to eq [included_client]
          end
        end

        context "with a stage filter" do
          let!(:included_client) { create :client, vita_partner: organization, tax_returns: [(create :tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:excluded_client) { create :client, vita_partner: organization, tax_returns: [(create :tax_return, :prep_ready_for_prep)], intake: (build :intake) }

          it "includes clients with tax returns in that stage" do
            get :index, params: { status: "intake" }
            expect(assigns(:clients)).to eq [included_client]
          end
        end

        context "filtering by tax return year" do
          let!(:return_3020) { create :tax_return, :intake_in_progress, year: 3020, client: build(:client, vita_partner: organization, intake: build(:intake)) }

          it "filters in" do
            get :index, params: { year: 3020 }
            expect(assigns(:clients)).to eq [return_3020.client]
          end
        end

        context "filtering by unassigned" do
          let!(:unassigned) { create :tax_return, :intake_in_progress, year: 2012, assigned_user: nil, client: build(:client, vita_partner: organization, intake: build(:intake)) }

          it "filters in" do
            get :index, params: { unassigned: true }
            expect(assigns(:clients)).to include unassigned.client
          end
        end

        context "filtering by organization/site" do
          let(:site) { create :site, parent_organization: organization }
          let!(:included_client) { create :client, vita_partner: organization, tax_returns: [(create :tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:included_site_client) { create :client, vita_partner: site, tax_returns: [(create :tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:excluded_client) { create :client, vita_partner: create(:organization), tax_returns: [(create :tax_return, :intake_in_progress)], intake: (build :intake) }

          it "includes clients who are assigned to those vita partners" do
            get :index, params: { vita_partners: [{ id: organization.id, name: organization.name, value: organization.id }, { id: site.id, name: site.name, value: site.id }].to_json }

            expect(assigns(:clients)).to include included_client
            expect(assigns(:clients)).to include included_site_client
            expect(assigns(:clients)).not_to include excluded_client
          end
        end

        context "filtering by needs response" do
          let!(:flagged) { create :client, flagged_at: DateTime.now, vita_partner: organization, tax_returns: [(create :tax_return, :intake_in_progress)], intake: build(:intake) }

          it "filters in" do
            get :index, params: { flagged: true }
            expect(assigns(:clients)).to include flagged
          end
        end

        context "greetable client filter" do
          render_views

          context "when current_user is not an admin" do
            it "doesn't show the greetable checkbox" do
              get :index, params: {}

              expect(response.body).not_to include "Greetable"
            end
          end

          context "when current_user is an admin" do
            let(:vita_partner_not_greetable) { create :organization, allows_greeters: false }
            let(:vita_partner_greetable) { create :organization, allows_greeters: true }
            let!(:greetable_client) { create :client_with_intake_and_return, vita_partner_id: vita_partner_greetable.id }
            let!(:not_greetable_client) { create :client_with_intake_and_return, vita_partner_id: vita_partner_not_greetable.id }
            before do
              sign_out user
              sign_in create(:admin_user)
            end

            it "shows the greetable checkbox" do
              get :index, params: {}

              expect(response.body).to include "Greetable"
            end

            it "filters by greetable vita partners when greetable param is present" do
              get :index, params: { greetable: true }

              expect(assigns(:clients)).to include greetable_client
              expect(assigns(:clients)).not_to include not_greetable_client
            end
          end
        end
      end

      context "SLA columns" do
        render_views
        around do |example|
          Timecop.freeze(DateTime.new(2021, 12, 21, 8))
          example.run
          Timecop.return
        end

        context "last contact" do
          let!(:client_less_than_one_business_day) { create :client, :with_return, last_outgoing_communication_at: 1.hour.ago, vita_partner: organization, intake: create(:intake, :filled_out) }
          let!(:client_one_business_day) { create :client, :with_return, last_outgoing_communication_at: 1.business_days.ago, vita_partner: organization, intake: create(:intake, :filled_out) }
          let!(:client_three_business_days) { create :client, :with_return, last_outgoing_communication_at: 3.business_days.ago, vita_partner: organization, intake: create(:intake, :filled_out) }
          let!(:client_four_business_days) { create :client, :with_return, last_outgoing_communication_at: 4.business_days.ago, vita_partner: organization, intake: create(:intake, :filled_out) }

          it "shows the number of business days since a client was contacted" do
            get :index

            html = Nokogiri::HTML.parse(response.body)
            expect(html.at_css("#client-#{client_less_than_one_business_day.id}")).to have_text("<1 day")
            expect(html.at_css("#client-#{client_one_business_day.id}")).to have_text("1 day")
            expect(html.at_css("#client-#{client_three_business_days.id}")).to have_text("3 days")
            expect(html.at_css("#client-#{client_four_business_days.id}")).to have_text("4 days")
            expect(html.at_css("#client-#{client_four_business_days.id}")).to have_css(".text--red-bold")
          end
        end

        context "waiting on response or update" do
          let!(:client_update) { create :client, :with_return, first_unanswered_incoming_interaction_at: nil, vita_partner: organization, intake: create(:intake, :filled_out) }
          let!(:client_response_min) { create :client, :with_return, first_unanswered_incoming_interaction_at: 32.minutes.ago, vita_partner: organization, intake: create(:intake, :filled_out) }
          let!(:client_response_hours) { create :client, :with_return, first_unanswered_incoming_interaction_at: 5.hours.ago, vita_partner: organization, intake: create(:intake, :filled_out) }
          let!(:client_response_days) { create :client, :with_return, first_unanswered_incoming_interaction_at: 1.business_days.ago, vita_partner: organization, intake: create(:intake, :filled_out) }

          it "shows whether a client is waiting for a response or update" do
            get :index

            html = Nokogiri::HTML.parse(response.body)
            expect(html.at_css("#client-#{client_update.id}").children[17].text).to eq("Update")
            expect(html.at_css("#client-#{client_response_min.id}").children[17].text).to eq("Response")
            expect(html.at_css("#client-#{client_response_hours.id}").children[17].text).to eq("Response")
            expect(html.at_css("#client-#{client_response_days.id}").children[17].text).to eq("Response")
          end
        end
      end
    end
  end

  describe "#flag" do
    let(:params) do
      { id: client.id, client: { action: "set" } }
    end
    let(:client) { create :client, vita_partner: organization }
    before { sign_in(user) }

    it "redirects to hub client path" do
      patch :flag, params: params
      expect(response).to redirect_to(hub_client_path(id: client.id))
    end

    context "with clear param" do

      before do
        params[:client][:action] = "clear"
        client.touch(:flagged_at)
        allow(SystemNote::ResponseNeededToggledOff).to receive(:generate!)
      end

      it "removes flagged_at value from client and makes a system note" do
        patch :flag, params: params

        expect(client.reload.flagged_at).to be_nil
        expect(SystemNote::ResponseNeededToggledOff).to have_received(:generate!).with(
          client: client,
          initiated_by: user
        )
      end
    end

    context "with add flag param" do
      before do
        params[:client][:action] = "set"
        client.clear_flag!
        allow(SystemNote::ResponseNeededToggledOn).to receive(:generate!)
      end

      it "adds flagged_at to client and leaves a system note" do
        expect {
          patch :flag, params: params
        }.to change { client.reload.flagged_at }

        expect(SystemNote::ResponseNeededToggledOn).to have_received(:generate!).with(
          client: client,
          initiated_by: user
        )
      end
    end
  end

  describe "#edit" do
    let(:vita_partner) { create :organization }
    let(:client) { create :client, vita_partner: organization, intake: (build :intake) }
    let(:params) {
                   { id: client.id }
                 }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      it "renders edit for the client" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:form)).to be_an_instance_of Hub::UpdateClientForm
      end
    end
  end

  describe "#update" do
    let(:client) { create :client, vita_partner: organization, intake: intake }

    let(:intake) { create :intake, :with_contact_info, preferred_interview_language: "en", dependents: [build(:dependent), build(:dependent)] }
    let(:first_dependent) { intake.dependents.first }
    let(:params) {
                   {
                     id: client.id,
                     hub_update_client_form: {
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
                       primary_ssn: "123451234",
                       primary_tin_type: "ssn",
                       with_general_navigator: "1",
                       street_address: intake.street_address,
                       city: intake.city,
                       state: intake.state,
                       zip_code: intake.zip_code,
                       sms_notification_opt_in: intake.sms_notification_opt_in,
                       email_notification_opt_in: intake.email_notification_opt_in,
                       spouse_first_name: intake.spouse_first_name,
                       spouse_last_name: intake.spouse_last_name,
                       spouse_email_address: intake.spouse_email_address,
                       spouse_tin_type: "ssn",
                       spouse_ssn: "912345678",
                       state_of_residence: "CA",
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

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :update

    context "with a signed in user" do
      let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

      before do
        sign_in user
      end

      it "updates the clients intake and creates a system note" do
        post :update, params: params
        client.reload
        expect(client.intake.primary_first_name).to eq "Updated"
        expect(client.legal_name).to eq "Updated Name"
        expect(client.intake.interview_timing_preference).to eq "Tomorrow!"
        expect(client.intake.timezone).to eq "America/Chicago"
        expect(client.intake.primary_last_four_ssn).to eq "1234"
        expect(client.intake.with_general_navigator).to be_truthy
        first_dependent.reload
        expect(first_dependent.first_name).to eq "Updated Dependent"
        expect(client.intake.dependents.count).to eq 2
        expect(response).to redirect_to hub_client_path(id: client.id)
        system_note = SystemNote::ClientChange.last
        expect(system_note.client).to eq(client)
        expect(system_note.user).to eq(user)
        expect(system_note.data['changes']).to match({
          "timezone" => [nil, "America/Chicago"],
          "primary_last_name" => [intake.primary_last_name, "Name"],
          "primary_first_name" => [intake.primary_first_name, "Updated"],
          "primary_last_four_ssn" => ["[REDACTED]", "[REDACTED]"],
          "state_of_residence" => [nil, "CA"],
          "primary_ssn" => ["[REDACTED]", "[REDACTED]"],
          "primary_tin_type" => [nil, "ssn"],
          "spouse_last_four_ssn" => ["[REDACTED]", "[REDACTED]"],
          "spouse_ssn" => ["[REDACTED]", "[REDACTED]"],
          "spouse_tin_type" => [nil, "ssn"],
          "with_general_navigator" => [false, true],
          "with_unhoused_navigator" => [false, nil],
          "interview_timing_preference" => [nil, "Tomorrow!"],
          "with_incarcerated_navigator" => [false, nil],
          "with_limited_english_navigator" => [false, nil]
        })
      end

      context "with invalid params" do
        let(:params) {
                       {
                         id: client.id,
                         hub_update_client_form: {
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
                         hub_update_client_form: {
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

  describe "#destroy" do
    let(:organization) { create(:organization) }
    let!(:client) { create :client, intake: intake, vita_partner: organization }
    let(:intake) { create :intake, :with_contact_info }
    let(:params) do
      {
        id: client.id,
      }
    end

    context "with an authenticated admin user" do
      let(:user) { create :admin_user }
      before { sign_in user }

      it "deletes the client and destroys all associated information" do
        expect do
          delete :destroy, params: params
        end.to change(Client, :count).by(-1)

        expect(response).to redirect_to hub_clients_path
        expect(flash[:notice]).to eq "The client has been successfully deleted"

        expect do
          client.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#edit_take_action" do
    let(:client) { create(:client, vita_partner: organization) }
    let!(:intake) { create :intake, client: client, email_notification_opt_in: "yes", email_address: "intake@example.com" }
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

      context "without a selected tax return and status" do
        it "initializes the form without default values" do
          get :edit_take_action, params: params

          expect(assigns(:take_action_form)).to be_present
          expect(assigns(:take_action_form).state).to be_nil
          expect(assigns(:take_action_form).tax_return_id).to be_nil
        end
      end

      context "with a tax_return_status param that has a template (from client profile link)" do
        let(:params) do
          {
            id: client,
            tax_return: {
              id: tax_return_2019.id,
              state: "intake_info_requested",
              locale: "es"
            },
          }
        end

        render_views

        it "prepopulates the form using the locale, status, and relevant template" do
          get :edit_take_action, params: params

          expect(assigns(:take_action_form).tax_return_id).to eq tax_return_2019.id
          expect(assigns(:take_action_form).state).to eq "intake_info_requested"
          expect(assigns(:take_action_form).locale).to eq "es"
          expect(assigns(:take_action_form).message_body).not_to be_blank
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
    let!(:intake) { create :intake, email_address: "gob@example.com", sms_phone_number: "+14155551212", client: client }
    let(:client) { create :client, vita_partner: organization }

    let(:params) do
      {
        id: client,
        hub_take_action_form: {
          tax_return_id: tax_return_2019,
          status: new_status_2019,
          internal_note_body: internal_note_body,
          locale: locale,
          message_body: message_body,
          contact_method: contact_method,
        }
      }
    end

    let(:tax_return_2019) { create :tax_return, :intake_in_progress, client: client, year: 2019 }
    let(:new_status_2019) { "intake_ready" }
    let(:locale) { "en" }
    let(:internal_note_body) { "" }
    let(:message_body) { "" }
    let(:contact_method) { "email" }
    let(:action_list) { ["updated status", "sent email", "added internal note"] }
    let(:fake_form) { double("fake form") }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_take_action

    context "as an authenticated user" do
      before do
        sign_in user
        allow(Hub::TakeActionForm).to receive(:new).and_return(fake_form)
        allow(TaxReturnService).to receive(:handle_state_change).and_return(action_list)
      end

      let(:new_status_2019) { tax_return_2019.state }

      context "when there is an error" do
        before do
          allow(fake_form).to receive(:valid?).and_return false
        end

        it "flashes an error, and renders edit" do
          post :update_take_action, params: params

          client.reload
          expect(flash[:alert]).to eq "Please fix indicated errors before continuing."
          expect(response).to render_template :edit_take_action
        end
      end

      context "when the client is not hub updatable" do
        before do
          allow_any_instance_of(Hub::ClientsController::HubClientPresenter).to receive(:hub_status_updatable).and_return(false)
        end

        it "raises bad request" do
          post :update_take_action, params: params
          expect(response).to be_bad_request
        end
      end

      context "when successful" do
        before do
          allow(fake_form).to receive(:valid?).and_return true
        end

        it "handles the status change, adds a flashes message, and redirects to client show page" do
          post :update_take_action, params: params

          expect(TaxReturnService).to have_received(:handle_state_change).with(fake_form)
          expect(flash[:notice]).to eq "Success: Action taken! Updated status, sent email, added internal note."
          expect(response).to redirect_to hub_client_path(id: client.id)
        end
      end
    end
  end

  describe "#unlock" do
    let(:client) { create(:intake, preferred_name: "Maeby").client }
    let(:params) do
      { id: client.id }
    end
    before { client.lock_access! }

    context "as a non-admin user" do
      before { sign_in(create :user) }

      it "returns 403 Forbidden" do
        post :unlock, params: params

        expect(response.status).to eq 403
      end
    end

    context "as a greeter user" do
      before { sign_in create(:greeter_user) }

      it "returns 403 Forbidden" do
        post :unlock, params: params

        expect(response.status).to eq 403
      end
    end

    context "as a team member user" do
      before { sign_in create(:team_member_user) }

      it "returns 403 Forbidden" do
        post :unlock, params: params

        expect(response.status).to eq 403
      end
    end

    context "as a site coordinator user" do
      let!(:site) { create :site }
      let!(:client_outside_of_site) { create(:client) }
      before {
        sign_in create(:site_coordinator_user, site: site)
        client.update(vita_partner: site)
      }

      it "can't unlock a client that is not under their site" do
        patch :unlock, params: { id: client_outside_of_site.id }

        expect(response.status).to eq 403
      end

      it "unlocks the client and redirects to the client profile page" do
        patch :unlock, params: params

        expect(client.reload.access_locked?).to eq false
        expect(response).to redirect_to(hub_client_path(id: client))
        expect(flash[:notice]).to eq "Unlocked #{client.preferred_name}'s account."
      end
    end

    context "as a organization lead user" do
      let!(:organization) { create :organization, name: "Org" }
      let!(:client_outside_of_org) { create(:client) }
      before {
        sign_in create(:organization_lead_user, organization: organization)
        client.update(vita_partner: organization)
      }

      it "can't unlock a client that is not under their organization" do
        patch :unlock, params: { id: client_outside_of_org.id }

        expect(response.status).to eq 403
      end

      it "unlocks the client and redirects to the client profile page" do
        patch :unlock, params: params

        expect(client.reload.access_locked?).to eq false
        expect(response).to redirect_to(hub_client_path(id: client))
        expect(flash[:notice]).to eq "Unlocked #{client.preferred_name}'s account."
      end
    end

    context "as an admin user" do
      before { sign_in create(:admin_user) }

      it "unlocks the client and redirects to the client profile page" do
        patch :unlock, params: params

        expect(client.reload.access_locked?).to eq false
        expect(response).to redirect_to(hub_client_path(id: client))
        expect(flash[:notice]).to eq "Unlocked #{client.preferred_name}'s account."
      end
    end
  end

  describe "presenter" do
    let(:tax_returns) { [] }
    let(:intake) { build(:intake) }
    let(:client) { create(:client, intake: intake, tax_returns: tax_returns) }
    let(:presenter) { Hub::ClientsController::HubClientPresenter.new(client) }

    describe "#editable?" do
      context "when there is a .intake" do
        it "returns true" do
          expect(presenter.editable?).to be_truthy
        end
      end

      context "when there is no .intake" do
        let(:intake) { nil }

        it "returns false" do
          expect(presenter.editable?).to be_falsey
        end
      end
    end

    describe "#archived?" do
      context "when there is a .intake" do
        it "returns false" do
          expect(presenter.archived?).to be_falsey
        end
      end

      context "when there is no intake" do
        let(:intake) { nil }

        it "returns false" do
          expect(presenter.archived?).to be_falsey
        end
      end

      context "when there is an archived intake" do
        let(:intake) { nil }
        let!(:archived_intake) { create(:archived_2021_gyr_intake, client: client) }

        it "returns true" do
          expect(presenter.archived?).to be_truthy
        end
      end
    end

    describe "#requires_spouse_info?" do
      context "from intake filing_joint" do
        context "when filing_joint is yes" do
          let(:intake) { build(:intake, filing_joint: "yes") }
          it "returns true" do
            expect(presenter.requires_spouse_info?).to be_truthy
          end
        end

        context "when filing_joint is no" do
          let(:intake) { build(:intake, filing_joint: "no") }
          it "returns false" do
            expect(presenter.requires_spouse_info?).to be_falsey
          end
        end
      end

      context "from tax return status" do
        let(:intake) { build(:intake, filing_joint: "unfilled") }
        let(:tax_returns) { [tr_2020, tr_2019] }

        context "when all tax returns are filing single" do
          let(:tr_2019) { build :tax_return, filing_status: "single", year: 2019 }
          let(:tr_2020) { build :tax_return, filing_status: "single", year: 2021 }

          it "returns false" do
            expect(presenter.requires_spouse_info?).to be_falsey
          end
        end

        context "when tax returns have any other status or a mix of statuses" do
          let(:tr_2019) { create :tax_return, filing_status: "single", year: 2019 }
          let(:tr_2020) { create :tax_return, filing_status: "head_of_household", year: 2021 }

          it "returns true" do
            expect(presenter.requires_spouse_info?).to be_truthy
          end
        end
      end
    end

    describe "#needs_itin_help_text and #needs_itin_help_yes?" do
      context "when there is a triage associated with the intake" do
        let!(:triage) { create(:triage, intake: intake, id_type: id_type) }

        context "when triage id_type is need_itin_help" do
          let(:id_type) { "need_itin_help" }
          it "returns Yes" do
            expect(presenter.needs_itin_help_text).to eq(I18n.t("general.affirmative"))
          end

          it "returns true" do
            expect(presenter.needs_itin_help_yes?).to be_truthy
          end
        end

        context "when triage id_type is another answer" do
          let(:id_type) { "have_id" }
          it "returns No" do
            expect(presenter.needs_itin_help_text).to eq(I18n.t("general.negative"))
          end

          it "returns false" do
            expect(presenter.needs_itin_help_yes?).to be_falsey
          end
        end

        context "when triage id_type is unfilled" do
          let(:id_type) { "unfilled" }
          it "returns N/A" do
            expect(presenter.needs_itin_help_text).to eq(I18n.t("general.NA"))
          end

          it "returns false" do
            expect(presenter.needs_itin_help_yes?).to be_falsey
          end
        end
      end

      context "when there is no triage associated with the intake" do
        it "returns N/A" do
          expect(presenter.needs_itin_help_text).to eq(I18n.t("general.NA"))
        end

        it "returns false" do
          expect(presenter.needs_itin_help_yes?).to be_falsey
        end
      end
    end
  end
end
