require "rails_helper"

RSpec.describe Hub::ClientsController do
  include FeatureHelpers

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
          spouse_was_blind: 'no',
          was_blind: 'no',
          filing_joint: "yes",
          timezone: "America/Chicago",
          needs_help_previous_year_1: "yes",
          needs_help_previous_year_2: "yes",
          needs_help_previous_year_3: "yes",
          needs_help_current_year: "yes",
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
      let(:vita_partner_id) { user.role.sites.first.id }
      let(:user) { create(:user, role: create(:team_member_role, sites: [create(:site)])) }
      before { sign_in user }

      context "with valid params" do
        it "assigns the client to the team member's site" do
          expect do
            post :create, params: params
          end.to change(Client, :count).by 1
          expect(Client.last.vita_partner).to eq(user.role.sites.first)
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
    let(:client) { build :client, vita_partner: organization, tax_returns: [(build :tax_return, year: 2019, service_type: "drop_off", filing_status: nil), (build :tax_return, year: 2018, service_type: "online_intake", filing_status: nil)] }

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

      before do
        sign_in(user)
      end

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
        let!(:george_sr) { create :client, vita_partner: organization, intake: build(:intake, :filled_out, preferred_name: "George Sr.", needs_help_2019: "yes", needs_help_2018: "yes", preferred_interview_language: "en", locale: "en") }
        let!(:george_sr_2019_return) { create :tax_return, :intake_in_progress, client: george_sr, year: 2019, assigned_user: assigned_user }
        let!(:george_sr_2018_return) { create :tax_return, :intake_ready, client: george_sr, year: 2018, assigned_user: assigned_user }
        let!(:michael) { create :client, vita_partner: organization, intake: build(:intake, :filled_out, preferred_name: "Michael", needs_help_2019: "yes", state_of_residence: nil) }
        let!(:michael_2019_return) { create :tax_return, :intake_in_progress, client: michael, year: 2019, assigned_user: assigned_user }
        let!(:tobias) { create :client, vita_partner: organization, intake: build(:intake, :filled_out, preferred_name: "Tobias", needs_help_2018: "yes", preferred_interview_language: "es", state_of_residence: "TX") }
        let!(:tobias_2019_return) { create :tax_return, :intake_in_progress, client: tobias, year: 2019, assigned_user: assigned_user }
        let!(:tobias_2018_return) { create :tax_return, :intake_in_progress, client: tobias, year: 2018, assigned_user: assigned_user }
        let!(:lucille) { create :client, vita_partner: organization, consented_to_service_at: nil, intake: build(:intake, preferred_name: "Lucille") }
        let!(:lucille_2018_return) { create(:tax_return, :intake_before_consent, client: lucille, year: 2018, assigned_user: assigned_user) }
        let!(:bob_loblaw) { create :client, consented_to_service_at: nil, vita_partner: organization, intake: build(:ctc_intake, preferred_name: "Bob Loblaw") }
        let!(:bob_loblaw_online_intake_return) { create :ctc_tax_return, :intake_before_consent, service_type: :online_intake, client: bob_loblaw }

        it "does not show a client who has not consented" do
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

        it "loads all the non-suspended users" do
          create :user, suspended_at: Time.current, role: create(:organization_lead_role, organization: organization)

          get :index

          expect(assigns(:users).count).to eq 1
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
          let!(:former_year_tax_return) { create :gyr_tax_return, :intake_in_progress, client: former_year_client, assigned_user: assigned_user }

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
          let!(:alex) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, preferred_name: "Alex") }
          let!(:ben) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, preferred_name: "Ben") }

          it "orders clients by name asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("preferred_name")
            expect(assigns[:client_sorter].sort_order).to eq("asc")
            expect(assigns(:clients).length).to eq 2

            expect(assigns(:clients)).to eq [alex, ben]
          end

          it "orders clients by name desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("preferred_name")
            expect(assigns[:client_sorter].sort_order).to eq("desc")
            expect(assigns(:clients).length).to eq 2
            expect(assigns(:clients)).to eq [ben, alex]
          end
        end

        context "with id as sort param" do
          let(:params) { { column: "id" } }
          let!(:first_id) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, preferred_name: "Alex") }
          let!(:second_id) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, preferred_name: "Ben") }

          it "orders clients by id asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("id")
            expect(assigns[:client_sorter].sort_order).to eq("asc")

            expect(assigns(:clients)).to eq [first_id, second_id]
          end

          it "orders clients by id desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("id")
            expect(assigns[:client_sorter].sort_order).to eq("desc")

            expect(assigns(:clients)).to eq [second_id, first_id]
          end
        end

        context "with updated_at as sort param" do
          let(:params) { { column: "updated_at" } }
          let!(:one) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, preferred_name: "Alex") }
          let!(:two) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, preferred_name: "Ben") }

          it "orders clients by updated_at asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("updated_at")
            expect(assigns[:client_sorter].sort_order).to eq("asc")

            expect(assigns(:clients)).to eq [one, two]
          end

          it "orders clients by updated_at desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("updated_at")
            expect(assigns[:client_sorter].sort_order).to eq("desc")

            expect(assigns(:clients)).to eq [two, one]
          end
        end

        context "with locale as sort param" do
          let(:params) { { column: "locale" } }
          let!(:spanish) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, locale: "es") }
          let!(:english) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, locale: "en") }

          it "orders clients by locale asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("locale")
            expect(assigns[:client_sorter].sort_order).to eq("asc")

            expect(assigns(:clients)).to eq [english, spanish]
          end

          it "orders clients by locale desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq("locale")
            expect(assigns[:client_sorter].sort_order).to eq("desc")

            expect(assigns(:clients)).to eq [spanish, english]
          end
        end

        context "with first_unanswered_incoming_interaction_at as sort param" do
          let(:params) { { column: "first_unanswered_incoming_interaction_at" } }
          let!(:first_id) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake), first_unanswered_incoming_interaction_at: 2.days.ago, last_outgoing_communication_at: 5.day.ago }
          let!(:second_id) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake), first_unanswered_incoming_interaction_at: 3.days.ago, last_outgoing_communication_at: 5.days.ago }

          it "orders clients by first_unanswered_incoming_interaction_at asc" do
            params[:order] = "asc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq "first_unanswered_incoming_interaction_at"
            expect(assigns[:client_sorter].sort_order).to eq "asc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end

          it "orders clients by first_unanswered_incoming_interaction_at desc" do
            params[:order] = "desc"
            get :index, params: params

            expect(assigns[:client_sorter].sort_column).to eq "first_unanswered_incoming_interaction_at"
            expect(assigns[:client_sorter].sort_order).to eq "desc"

            expect(assigns(:clients)).to eq [first_id, second_id]
          end
        end

        context "with no or bad params" do
          let!(:first_id) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake), last_outgoing_communication_at: 1.day.ago }
          let!(:second_id) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake), last_outgoing_communication_at: 2.days.ago }

          it "defaults to sorting by last_outgoing_communication_at, asc by default" do
            get :index

            expect(assigns[:client_sorter].sort_column).to eq "last_outgoing_communication_at"
            expect(assigns[:client_sorter].sort_order).to eq "asc"

            expect(assigns(:clients)).to eq [second_id, first_id]
          end

          it "defaults to sorting by id, desc with bad params" do
            get :index, params: { column: "bad_order", order: "no_order" }

            expect(assigns[:client_sorter].sort_column).to eq "last_outgoing_communication_at"
            expect(assigns[:client_sorter].sort_order).to eq "asc"

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

      context "ordering tax returns" do
        let(:client) { (create :intake).client }
        let!(:tax_return_2022) { create :gyr_tax_return, :intake_in_progress, client: client }
        let!(:tax_return_2019) { create :tax_return, :intake_in_progress, client: client, year: 2019 }
        before { client.update(vita_partner: organization, consented_to_service_at: DateTime.current) }
        render_views

        it "shows the tax returns in order of year" do
          get :index, params: {}

          html = Nokogiri::HTML.parse(response.body)
          expect(html.css(".tax-return-list__year").first).to have_text("2019")
          expect(html.css(".tax-return-list__year").last).to have_text(MultiTenantService.new(:gyr).current_tax_year)
        end
      end

      context "filtering" do
        context "with a status filter" do
          let!(:included_client) { create :client, vita_partner: organization, tax_returns: [(build :gyr_tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:excluded_client) { create :client, vita_partner: organization, tax_returns: [(build :gyr_tax_return, :intake_ready)], intake: (build :intake) }

          it "includes clients with tax returns in that status" do
            get :index, params: { status: "intake_in_progress" }
            expect(assigns(:clients)).to eq [included_client]
          end
        end

        context "with a stage filter" do
          let!(:included_client) { create :client, vita_partner: organization, tax_returns: [(build :gyr_tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:excluded_client) { create :client, vita_partner: organization, tax_returns: [(build :gyr_tax_return, :prep_ready_for_prep)], intake: (build :intake) }

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
          let!(:included_client) { create :client, vita_partner: organization, tax_returns: [(build :gyr_tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:included_site_client) { create :client, vita_partner: site, tax_returns: [(build :gyr_tax_return, :intake_in_progress)], intake: (build :intake) }
          let!(:excluded_client) { create :client, vita_partner: create(:organization), tax_returns: [(build :gyr_tax_return, :intake_in_progress)], intake: (build :intake) }

          it "includes clients who are assigned to those vita partners" do
            get :index, params: { vita_partners: [{ id: organization.id, name: organization.name, value: organization.id }, { id: site.id, name: site.name, value: site.id }].to_json }

            expect(assigns(:clients)).to include included_client
            expect(assigns(:clients)).to include included_site_client
            expect(assigns(:clients)).not_to include excluded_client
          end
        end

        context "filtering by needs response" do
          let!(:flagged) { create :client, flagged_at: DateTime.now, vita_partner: organization, tax_returns: [(build :gyr_tax_return, :intake_in_progress)], intake: build(:intake) }

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

        context "last contact filter" do
          let!(:approaching_sla_client) { create :client_with_intake_and_return, preferred_name: "Approachy", vita_partner: organization, last_outgoing_communication_at: 4.business_days.ago - 2.hours }
          let!(:breached_sla_client) { create :client_with_intake_and_return, preferred_name: "Breachy", vita_partner: organization, last_outgoing_communication_at: 6.business_days.ago }
          let!(:recently_contacted_client) { create :client_with_intake_and_return, preferred_name: "Recenty", vita_partner: organization, last_outgoing_communication_at: 2.hours.ago }

          around do |example|
            Timecop.freeze(DateTime.new(2022, 1, 1, 5, 0, 0)) do
              example.run
            end
          end

          context "with page contents" do
            render_views

            it "filters the All Clients page" do
              get :index
              html = Nokogiri::HTML.parse(response.body)
              expect(html.at_css("a.button--quick-filter").attr("href")).to include hub_clients_path
            end
          end

          it "can filter to only clients who are approaching SLA" do
            get :index, params: { last_contact: "approaching_sla" }
            expect(assigns(:clients).map(&:preferred_name)).to eq [approaching_sla_client].map(&:preferred_name)
          end

          it "can filter to only clients who have breached SLA" do
            get :index, params: { last_contact: "breached_sla" }
            expect(assigns(:clients).map(&:preferred_name)).to eq [breached_sla_client].map(&:preferred_name)
          end

          it "can filter to only clients who have been recently contacted" do
            get :index, params: { last_contact: "recently_contacted" }
            expect(assigns(:clients).map(&:preferred_name)).to eq [recently_contacted_client].map(&:preferred_name)
          end
        end

        context "active_returns filter" do
          let!(:in_progress_client) { create :client_with_intake_and_return, vita_partner: organization, tax_return_state: 'intake_in_progress' }
          let!(:reviewing_client) { create :client_with_intake_and_return, vita_partner: organization, tax_return_state: 'review_reviewing' }
          let!(:accepted_client) { create :client_with_intake_and_return, vita_partner: organization, tax_return_state: 'file_accepted' }

          it "returns only the clients that are active" do
            get :index, params: { active_returns: "true" }
            expect(assigns(:clients)).to eq [in_progress_client, reviewing_client]
          end
        end
      end

      context "SLA columns" do
        render_views
        around do |example|
          Timecop.freeze(DateTime.new(2021, 12, 21, 8)) do
            example.run
          end
        end

        context "last contact" do
          let!(:client_less_than_one_business_day) { create :client, :with_gyr_return, last_outgoing_communication_at: 1.hour.ago, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:client_one_business_day) { create :client, :with_gyr_return, last_outgoing_communication_at: 1.business_days.ago, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:client_three_business_days) { create :client, :with_gyr_return, last_outgoing_communication_at: 3.business_days.ago, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:client_four_business_days) { create :client, :with_gyr_return, last_outgoing_communication_at: 4.business_days.ago, vita_partner: organization, intake: build(:intake, :filled_out) }

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
          let!(:client_update) { create :client, :with_gyr_return, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:client_response_min) { create :client, :with_gyr_return, first_unanswered_incoming_interaction_at: 32.minutes.ago, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:client_response_hours) { create :client, :with_gyr_return, first_unanswered_incoming_interaction_at: 5.hours.ago, vita_partner: organization, intake: build(:intake, :filled_out) }
          let!(:client_response_days) { create :client, :with_gyr_return, first_unanswered_incoming_interaction_at: 1.business_days.ago, vita_partner: organization, intake: build(:intake, :filled_out) }

          before do
            # Can't set `first_unanswered_incoming_interaction_at` via the factory because the InteractionTrackingService
            # eagerly overwrites it
            client_update.update(first_unanswered_incoming_interaction_at: nil)
          end

          it "shows whether a client is waiting for a response or update" do
            get :index
            table_rows = table_contents(Nokogiri::HTML.parse(response.body).css('.client-table'))

            expected_rows = [
              {
                'Client ID' => client_update.id.to_s,
                'Waiting on' => 'Update',
              }, {
                'Client ID' => client_response_min.id.to_s,
                'Waiting on' => 'Response'
              }, {
                'Client ID' => client_response_hours.id.to_s,
                'Waiting on' => 'Response'
              }, {
                'Client ID' => client_response_days.id.to_s,
                'Waiting on' => 'Response',
              }
            ]
            expect(table_rows.sort_by { |row| row['Client ID'] }).to match_rows(expected_rows)
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

      context "with a client with an archived intake" do
        before do
          client.intake.destroy!
          create(:archived_2021_gyr_intake, client: client)
        end

        it "redirects to the /show page for the client" do
          get :edit, params: params

          expect(response).to redirect_to(hub_client_path(id: client.id))
        end
      end
    end
  end

  describe "#update" do
    let(:client) { create :client, vita_partner: organization, intake: intake }

    let(:intake) { build :intake, :with_contact_info, preferred_interview_language: "en", dependents: [build(:dependent), build(:dependent)] }
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
                       spouse_first_name: intake.spouse.first_name,
                       spouse_last_name: intake.spouse.last_name,
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
                       },
                       used_itin_certifying_acceptance_agent: "false",
                       was_blind: "no",
                       spouse_was_blind: "no",
                       signature_method: "online",
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
        expect(client.intake.primary.first_name).to eq "Updated"
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
          "primary_last_name" => [intake.primary.last_name, "Name"],
          "primary_first_name" => [intake.primary.first_name, "Updated"],
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

      context "with a client with an archived intake" do
        before do
          client.intake.destroy!
          create(:archived_2021_gyr_intake, client: client)
        end

        it "redirects to the /show page for the client" do
          post :update, params: { id: client.id }

          expect(response).to redirect_to(hub_client_path(id: client.id))
        end
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
    let(:intake) { build :intake, :with_contact_info }
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

      context "a client with soft deleted dependents" do
        let(:intake) { build :intake, :with_contact_info, dependents: [create(:dependent, soft_deleted_at: Time.now()), create(:dependent)] }

        it "deletes the client and destroys all dependents" do
          expect do
            delete :destroy, params: params
          end.to change(Client, :count).by(-1).and change(Dependent.with_deleted, :count).by(-2)

          expect(response).to redirect_to hub_clients_path
          expect(flash[:notice]).to eq "The client has been successfully deleted"

          expect do
            client.reload
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "with a team member" do
      let(:user) { create :team_member_user }
      before { sign_in user }

      it "does not delete the client" do
        expect do
          delete :destroy, params: params
        end.not_to change(Client, :count)
      end
    end
  end

  describe "#edit_take_action" do
    let!(:client) { create(:client, intake: intake, vita_partner: organization) }
    let(:intake) { build :intake, email_notification_opt_in: "yes", email_address: "intake@example.com" }
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

      context "with a client with an archived intake" do
        before do
          intake.destroy!
          create(:archived_2021_gyr_intake, client: client)
        end

        it "redirects to the /show page for the client" do
          get :edit_take_action, params: params

          expect(response).to redirect_to(hub_client_path(id: client.id))
        end
      end

      context "without a selected tax return and status" do
        it "initializes the form without default values" do
          get :edit_take_action, params: params

          expect(assigns(:take_action_form)).to be_present
          expect(assigns(:take_action_form).status).to be_nil
          expect(assigns(:take_action_form).tax_return_id).to be_nil
        end
      end

      context "with a tax_return_status param that has a template (from client profile link)" do
        let(:params) do
          {
            id: client,
            tax_return: {
              id: tax_return_2019.id,
              current_state: "intake_info_requested",
              locale: "es"
            },
          }
        end

        render_views

        it "prepopulates the form using the locale, status, and relevant template" do
          get :edit_take_action, params: params

          expect(assigns(:take_action_form).tax_return_id).to eq tax_return_2019.id
          expect(assigns(:take_action_form).status).to eq "intake_info_requested"
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
    let(:intake) { build :intake, email_address: "gob@example.com", sms_phone_number: "+14155551212" }
    let(:client) { create :client, intake: intake, vita_partner: organization }

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

      let(:new_status_2019) { tax_return_2019.current_state }

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
          expect(response).to redirect_to hub_client_path(id: client.id)
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
        sign_in create(:site_coordinator_user, sites: [site])
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

  describe "#resource_to_client_redirect" do
    let(:tax_return) { create :gyr_tax_return }
    let(:params) { { id: tax_return.id, resource: "tax_return" } }
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :resource_to_client_redirect

    context "as an authenticated user" do
      before { sign_in user }

      context "when the resource is a tax return" do
        let(:tax_return) { create :gyr_tax_return }
        let(:client) { tax_return.client }

        it "redirects to the associated client" do
          get :resource_to_client_redirect, params: params
          expect(response).to redirect_to hub_client_path(id: client.id)
        end
      end

      context "when the resource is a bank account" do
        let(:bank_account) { create :bank_account, intake: (build :intake, client: (create :client))}
        let(:client) { bank_account.client }

        it "redirects to the associated client" do
          get :resource_to_client_redirect, params: { id: bank_account.id, resource: "bank_account" }
          expect(response).to redirect_to hub_client_path(id: client.id)
        end
      end

      context "when the resource is an intake" do
        let(:intake) { create :intake, client: (create :client) }
        let(:client) { intake.client }

        it "redirects to the associated client" do
          get :resource_to_client_redirect, params: { id: intake.id, resource: "intake" }
          expect(response).to redirect_to hub_client_path(id: client.id)
        end
      end

      context "when the resource is a client" do
        let(:client) { create :client}

        it "redirects to the client show page" do
          get :resource_to_client_redirect, params: {id: client.id, resource: "client" }
          expect(response).to redirect_to hub_client_path(id: client.id)
        end
      end

      context "when the resource is an invalid resource" do
        let(:client) { create :client}

        it "should be an internal error" do
          expect {
            get :resource_to_client_redirect, params: {id: client.id, resource: "foobar"}
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "presenter" do
    let(:tax_returns) { [] }
    let(:product_year) { Rails.configuration.product_year }
    let(:intake) { build(:intake, product_year: product_year) }
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

      context "when the intake is for a prior product year" do
        let(:product_year) { Rails.configuration.product_year - 1 }

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
          let(:tr_2020) { build :tax_return, filing_status: "single", year: 2020 }

          it "returns false" do
            expect(presenter.requires_spouse_info?).to be_falsey
          end
        end

        context "when tax returns have any other status or a mix of statuses" do
          let(:tr_2019) { build :tax_return, filing_status: "single", year: 2019 }
          let(:tr_2020) { build :tax_return, filing_status: "head_of_household", year: 2020 }

          it "returns true" do
            expect(presenter.requires_spouse_info?).to be_truthy
          end
        end
      end
    end

    describe "#preferred_language" do
      context "when preferred language is set to something other than english" do
        let(:intake) { build :intake, preferred_interview_language: "de", locale: "es" }

        it "it uses preferred language" do
          expect(presenter.preferred_language).to eq "de"
        end
      end

      context "when preferred language is set to english" do
        let(:intake) { build :intake, preferred_interview_language: "en", locale: "es" }

        it "falls through to locale" do
          expect(presenter.preferred_language).to eq "es"
        end
      end

      context "when preferred language not set" do
        let(:intake) { build :intake, locale: "en" }

        it "falls through to locale" do
          expect(presenter.preferred_language).to eq "en"
        end
      end

      context "when preferred language is set to en, and locale is not set" do
        let(:intake) { build :intake, locale: nil, preferred_interview_language: "en" }

        it "falls through to locale" do
          expect(presenter.preferred_language).to eq "en"
        end
      end
    end

    describe "#needs_itin_help_text and #needs_itin_help_yes?" do
      context "when intake is need_itin_help_yes?" do
        let(:intake) { build :intake, need_itin_help: "yes" }

        it "returns Yes" do
          expect(presenter.needs_itin_help_text).to eq(I18n.t("general.affirmative"))
        end

        it "returns true" do
          expect(presenter.needs_itin_help_yes?).to be_truthy
        end
      end

      context "when intake is need_itin_help_no?" do
        let(:intake) { build :intake, need_itin_help: "no" }

        it "returns No" do
          expect(presenter.needs_itin_help_text).to eq(I18n.t("general.negative"))
        end

        it "returns false" do
          expect(presenter.needs_itin_help_yes?).to be_falsey
        end
      end

      context "when intake is need_itin_help_unfilled?" do
        let(:intake) { build :intake, need_itin_help: "unfilled" }

        it "returns N/A" do
          expect(presenter.needs_itin_help_text).to eq(I18n.t("general.negative"))
        end

        it "returns false" do
          expect(presenter.needs_itin_help_yes?).to be_falsey
        end
      end

      context "when intake has been archived" do
        let(:intake) { nil }
        let!(:archived_intake) { create(:archived_2021_gyr_intake, client: client) }

        it "returns N/A" do
          expect(presenter.needs_itin_help_text).to eq(I18n.t("general.NA"))
        end

        it "returns false" do
          expect(presenter.needs_itin_help_yes?).to be_falsey
        end
      end
    end
  end

  context "updating 13614c" do
    let(:client) { create :client, vita_partner: organization, intake: intake }

    let(:intake) { build :intake, :with_contact_info, preferred_interview_language: "en", ever_married: "yes", dependents: [build(:dependent), build(:dependent)] }
    let(:first_dependent) { intake.dependents.first }

    describe "#update_13614c_form_page1" do
      let(:params) {
        {
          id: client.id,
          commit: I18n.t('general.save'),
          hub_update13614c_form_page1: {
            primary_first_name: "Updated",
            primary_last_name: "Name",
            never_married: intake.ever_married_yes? ? "no" : "yes",
            married: intake.married,
            got_married_during_tax_year: "unfilled",
            separated: intake.separated,
            widowed: intake.widowed,
            lived_with_spouse: intake.lived_with_spouse,
            divorced: intake.divorced,
            divorced_year: intake.divorced_year,
            separated_year: intake.separated_year,
            widowed_year: intake.widowed_year,
            email_address: intake.email_address,
            phone_number: intake.phone_number,
            street_address: intake.street_address,
            city: intake.city,
            state: intake.state,
            zip_code: intake.zip_code,
            primary_us_citizen: "unfilled",
            spouse_first_name: intake.spouse.first_name,
            spouse_last_name: intake.spouse.last_name,
            spouse_email_address: intake.spouse_email_address,
            spouse_us_citizen: "unfilled",
            dependents_attributes: {
              "0" => { id: intake.dependents.first.id, first_name: "Updated Dependent", last_name: "Name", birth_date_year: "2001", birth_date_month: "10", birth_date_day: "9" },
              "1" => { first_name: "A New", last_name: "Dependent", birth_date_year: "2007", birth_date_month: "12", birth_date_day: "1" },
              "2" => { id: intake.dependents.last.id, _destroy: "1" }
            },
            was_blind: "no",
            was_full_time_student: "unfilled",
            spouse_was_blind: "no",
            claimed_by_another: "unfilled",
            had_disability: "unfilled",
            spouse_had_disability: "unfilled",
            issued_identity_pin: "unfilled",
            spouse_was_full_time_student: "unfilled",
          }
        }
      }

      it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_13614c_form_page1

      context "with a signed in user" do
        let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

        before do
          sign_in user
        end

        it "updates the clients intake with the 13614c page 1 data, creates a system note, and regenerates the pdf when client clicks Save" do
          expect do
            put :update_13614c_form_page1, params: params
          end.to have_enqueued_job(GenerateF13614cPdfJob)

          expect(flash[:notice]).to eq "Changes saved"
          expect(response).to redirect_to edit_13614c_form_page1_hub_client_path(id: client)

          client.reload
          expect(client.intake.primary.first_name).to eq "Updated"
          expect(client.legal_name).to eq "Updated Name"
          first_dependent.reload
          expect(first_dependent.first_name).to eq "Updated Dependent"
          expect(client.intake.dependents.count).to eq 2

          system_note = SystemNote::ClientChange.last
          expect(system_note.client).to eq(client)
          expect(system_note.user).to eq(user)
          expect(system_note.data['changes']).to match({
                                                         "primary_last_name" => [intake.primary.last_name, "Name"],
                                                         "primary_first_name" => [intake.primary.first_name, "Updated"],
                                                       })

          expect(client.last_13614c_update_at).to be_within(1.second).of(DateTime.now)
        end

        it "updates the clients intake with the 13614c page 1 data, and direct to hub client page when client clicks Save and Exit" do
          expect do
            put :update_13614c_form_page1, params: params.update(commit: I18n.t('general.save_and_exit'))
          end.to have_enqueued_job(GenerateF13614cPdfJob)

          expect(flash[:notice]).to eq "Changes saved"
          expect(response).to redirect_to hub_client_path(id: client.id)

          client.reload
          expect(client.intake.primary.first_name).to eq "Updated"
        end

        context "with invalid params" do
          let(:params) {
            {
              id: client.id,
              hub_update13614c_form_page1: {
                primary_first_name: "",
              }
            }
          }

          it "renders edit" do
            put :update_13614c_form_page1, params: params

            expect(response).to render_template :edit_13614c_form_page1
          end
        end

        context "with invalid dependent params" do
          let(:params) {
            {
              id: client.id,
              hub_update13614c_form_page1: {
                dependents_attributes: { 0 => { "first_name": "", last_name: "", birth_date_month: "", birth_date_year: "", birth_date_day: "" } },
              }
            }
          }

          it "renders edit" do
            put :update_13614c_form_page1, params: params

            expect(response).to render_template :edit_13614c_form_page1

          end

          context "with invalid params" do
            let(:params) {
              {
                id: client.id,
                hub_update13614c_form_page1: {
                  primary_first_name: "",
                }
              }
            }

            it "renders edit" do
              put :update_13614c_form_page1, params: params

              expect(response).to render_template :edit_13614c_form_page1
            end
          end

          context "with invalid dependent params" do
            let(:params) {
              {
                id: client.id,
                hub_update13614c_form_page1: {
                  dependents_attributes: { 0 => { "first_name": "", last_name: "", birth_date_month: "", birth_date_year: "", birth_date_day: "" } },
                }
              }
            }

            it "renders edit" do
              put :update_13614c_form_page1, params: params

              expect(response).to render_template :edit_13614c_form_page1
            end

            it "displays a flash message" do
              put :update_13614c_form_page1, params: params
              expect(flash[:alert]).to eq "Please fix indicated errors before continuing."
            end
          end
        end
      end
    end

    describe "#update_13614c_form_page2" do
      let(:params) {
        {
          id: client.id,
          commit: I18n.t('general.save'),
          hub_update13614c_form_page2: {
            job_count: "3",
            had_wages: "yes",
            had_tips: "unfilled",
            had_interest_income: "unfilled",
            had_local_tax_refund: "unfilled",
            received_alimony: "unfilled",
            had_self_employment_income: "unfilled",
            has_crypto_income: false,
            had_asset_sale_income: "unfilled",
            had_disability_income: "no",
            had_retirement_income: "no",
            had_unemployment_income: "yes",
            had_social_security_income: "unsure",
            had_rental_income: "unsure",
            had_other_income: "no",
            paid_alimony: "unfilled",
            paid_retirement_contributions: "unfilled",
            paid_dependent_care: "unfilled",
            paid_school_supplies: "unfilled",
            paid_student_loan_interest: "unfilled",
            had_hsa: "unfilled",
            had_debt_forgiven: "unfilled",
            adopted_child: "unfilled",
            had_tax_credit_disallowed: "unfilled",
            bought_energy_efficient_items: "unfilled",
            received_homebuyer_credit: "unfilled",
            made_estimated_tax_payments: "unfilled",
            had_scholarships: "unfilled",
            had_cash_check_digital_assets: "unfilled",
            has_ssn_of_alimony_recipient: "unfilled",
            contributed_to_ira: "unfilled",
            contributed_to_roth_ira: "unfilled",
            contributed_to_401k: "unfilled",
            contributed_to_other_retirement_account: "unfilled",
            paid_post_secondary_educational_expenses: "unfilled",
            wants_to_itemize: "unfilled",
            paid_local_tax: "yes",
            paid_mortgage_interest: "unfilled",
            paid_medical_expenses: "unfilled",
            paid_charitable_contributions: "unfilled",
            paid_self_employment_expenses: "unfilled",
            tax_credit_disallowed_year: nil,
            made_estimated_tax_payments_amount: nil,
            had_capital_loss_carryover: "unfilled",
            bought_marketplace_health_insurance: "yes"
          }
        }
      }

      it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_13614c_form_page2

      context "with a signed in user" do
        let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

        before do
          sign_in user
        end

        it "updates the clients intake with the 13614c data, creates a system note, and regenerates the pdf when a client presses Save" do
          expect do
            put :update_13614c_form_page2, params: params
          end.to have_enqueued_job(GenerateF13614cPdfJob)

          expect(flash[:notice]).to eq I18n.t("general.changes_saved")
          expect(response).to redirect_to edit_13614c_form_page2_hub_client_path(id: client)
          client.reload
          expect(client.intake.job_count).to eq 3
          expect(client.intake.had_wages_yes?).to eq true
          expect(client.intake.had_tips_unfilled?).to eq true
          expect(client.intake.had_interest_income_unfilled?).to eq true
          expect(client.intake.had_local_tax_refund_unfilled?).to eq true
          expect(client.intake.paid_alimony_unfilled?).to eq true
          expect(client.intake.had_self_employment_income_unfilled?).to eq true
          expect(client.intake.has_crypto_income).to eq false
          expect(client.intake.had_asset_sale_income_unfilled?).to eq true
          expect(client.intake.had_disability_income_no?).to eq true
          expect(client.intake.had_retirement_income_no?).to eq true
          expect(client.intake.had_unemployment_income_yes?).to eq true
          expect(client.intake.had_social_security_income_unsure?).to eq true
          expect(client.intake.had_rental_income_unsure?).to eq true
          expect(client.intake.had_other_income_no?).to eq true
          expect(client.intake.paid_alimony_unfilled?).to eq true
          expect(client.intake.paid_retirement_contributions_unfilled?).to eq true
          expect(client.intake.paid_dependent_care_unfilled?).to eq true
          expect(client.intake.paid_school_supplies_unfilled?).to eq true
          expect(client.intake.paid_student_loan_interest_unfilled?).to eq true
          expect(client.intake.had_hsa_unfilled?).to eq true
          expect(client.intake.had_debt_forgiven_unfilled?).to eq true
          expect(client.intake.adopted_child_unfilled?).to eq true
          expect(client.intake.had_tax_credit_disallowed_unfilled?).to eq true
          expect(client.intake.bought_energy_efficient_items_unfilled?).to eq true
          expect(client.intake.received_homebuyer_credit_unfilled?).to eq true
          expect(client.intake.made_estimated_tax_payments_unfilled?).to eq true
          expect(client.intake.paid_local_tax_yes?).to eq true
          expect(client.intake.paid_mortgage_interest_unfilled?).to eq true
          expect(client.intake.paid_medical_expenses_unfilled?).to eq true
          expect(client.intake.paid_charitable_contributions_unfilled?).to eq true
          expect(client.intake.paid_self_employment_expenses_unfilled?).to eq true
          expect(client.intake.had_capital_loss_carryover_unfilled?).to eq true
          expect(client.intake.bought_marketplace_health_insurance_yes?).to eq true

          system_note = SystemNote::ClientChange.last
          expect(system_note.client).to eq(client)
          expect(system_note.user).to eq(user)
          expect(system_note.data['changes']).to match({
                                                         "had_disability_income" => [intake.had_disability_income, "no"],
                                                         "bought_energy_efficient_items" => [intake.bought_energy_efficient_items, "unfilled"],
                                                         "had_other_income" => [intake.had_other_income, "no"],
                                                         "had_rental_income" => [intake.had_rental_income, "unsure"],
                                                         "had_retirement_income" => [intake.had_retirement_income, "no"],
                                                         "had_social_security_income" => [intake.had_social_security_income, "unsure"],
                                                         "had_unemployment_income" => [intake.had_unemployment_income, "yes"],
                                                         "had_wages" => [intake.had_wages, "yes"],
                                                         "job_count" => [intake.job_count, 3],
                                                         "paid_local_tax" => [intake.paid_local_tax, "yes"],
                                                         "bought_marketplace_health_insurance" => [intake.bought_marketplace_health_insurance, "yes"]
                                                       })
          expect(client.last_13614c_update_at).to be_within(1.second).of(DateTime.now)
        end

        it "updates the clients intake with the 13614c page 2 data, and direct to hub client page when client clicks Save and Exit" do
          expect do
            put :update_13614c_form_page2, params: params.update(commit: I18n.t('general.save_and_exit'))
          end.to have_enqueued_job(GenerateF13614cPdfJob)

          expect(flash[:notice]).to eq "Changes saved"
          expect(response).to redirect_to hub_client_path(id: client.id)

          client.reload
          expect(client.intake.job_count).to eq 3
        end
      end
    end

    describe "#update_13614c_form_page3" do
      let(:params) {
        {
          id: client.id,
          commit: I18n.t('general.save'),
          hub_update13614c_form_page3: {
            preferred_written_language: "Greek",
            receive_written_communication: intake.receive_written_communication,
            refund_payment_method: intake.refund_payment_method,
            savings_purchase_bond: intake.savings_purchase_bond,
            savings_split_refund: intake.savings_split_refund,
            balance_pay_from_bank: intake.balance_pay_from_bank,
            had_disaster_loss: intake.had_disaster_loss,
            received_irs_letter: intake.received_irs_letter,
            presidential_campaign_fund_donation: intake.presidential_campaign_fund_donation,
            had_disaster_loss_where: intake.had_disaster_loss_where,
            register_to_vote: intake.register_to_vote,
            demographic_english_conversation: intake.demographic_english_conversation,
            demographic_english_reading: intake.demographic_english_reading,
            demographic_disability: intake.demographic_disability,
            demographic_veteran: intake.demographic_veteran,
            demographic_primary_american_indian_alaska_native: intake.demographic_primary_american_indian_alaska_native,
            demographic_primary_asian: intake.demographic_primary_asian,
            demographic_primary_black_african_american: intake.demographic_primary_black_african_american,
            demographic_primary_native_hawaiian_pacific_islander: intake.demographic_primary_native_hawaiian_pacific_islander,
            demographic_primary_white: intake.demographic_primary_white,
            demographic_primary_prefer_not_to_answer_race: intake.demographic_primary_prefer_not_to_answer_race,
            demographic_spouse_american_indian_alaska_native: intake.demographic_spouse_american_indian_alaska_native,
            demographic_spouse_asian: intake.demographic_spouse_asian,
            demographic_spouse_black_african_american: intake.demographic_spouse_black_african_american,
            demographic_spouse_native_hawaiian_pacific_islander: intake.demographic_spouse_native_hawaiian_pacific_islander,
            demographic_spouse_white: intake.demographic_spouse_white,
            demographic_spouse_prefer_not_to_answer_race: intake.demographic_spouse_prefer_not_to_answer_race,
            demographic_primary_ethnicity: intake.demographic_primary_ethnicity,
            demographic_spouse_ethnicity: intake.demographic_spouse_ethnicity,
          }
        }
      }

      it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_13614c_form_page3

      context "with a signed in user" do
        let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

        before do
          sign_in user
        end

        it "updates the clients intake with the 13614c data, creates a system note, and regenerates the pdf when clients press Save" do
          expect do
            put :update_13614c_form_page3, params: params
          end.to have_enqueued_job(GenerateF13614cPdfJob)

          expect(flash[:notice]).to eq I18n.t("general.changes_saved")
          expect(response).to redirect_to edit_13614c_form_page3_hub_client_path(id: client)
          client.reload
          expect(client.intake.preferred_written_language).to eq "Greek"

          system_note = SystemNote::ClientChange.last
          expect(system_note.client).to eq(client)
          expect(system_note.user).to eq(user)
          expect(system_note.data['changes']).to match({ "preferred_written_language" => [intake.preferred_written_language, "Greek"] })
          expect(client.last_13614c_update_at).to be_within(1.second).of(DateTime.now)
        end

        it "updates the clients intake with the 13614c page 3 data, and direct to hub client page when client clicks Save and Exit" do
          expect do
            put :update_13614c_form_page3, params: params.update(commit: I18n.t('general.save_and_exit'))
          end.to have_enqueued_job(GenerateF13614cPdfJob)

          expect(flash[:notice]).to eq "Changes saved"
          expect(response).to redirect_to hub_client_path(id: client.id)

          client.reload
          expect(client.intake.preferred_written_language).to eq "Greek"
        end
      end
    end
  end

  context "as a greeter" do
    context "when the organization allows greeters" do
      before { sign_in(user) }

      let!(:organization) { create :organization, allows_greeters: true }
      let(:user) { create(:user, role: create(:greeter_role), timezone: "America/Los_Angeles") }

      let(:client) do
        build(
          :client,
          vita_partner: organization,
          tax_returns: [
            build(
              :tax_return,
              year: 2019,
              service_type: "drop_off",
              filing_status: nil
            ),
            build(
              :tax_return,
              year: 2018, service_type: "online_intake",
              filing_status: nil
            )
          ]
        )
      end

      let!(:george_sr) do
        create(
          :client,
          vita_partner: organization,
          intake: build(
            :intake,
            :filled_out,
            preferred_name: "George Sr.",
            needs_help_2019: "yes",
            needs_help_2018: "yes",
            preferred_interview_language: "en", locale: "en"
          )
        )
      end

      let!(:george_sr_2019_return) do
        create(
          :tax_return,
          :intake_in_progress,
          client: george_sr,
          year: 2019,
          assigned_user: user
        )
      end

      describe "#index" do
        it 'should have clients assigned when there is an intake_ready return' do
          create(
            :tax_return,
            :intake_ready,
            client: george_sr,
            year: 2018,
            assigned_user: user
          )
          get :index
          expect(assigns(:clients)).not_to be_empty
        end

        it 'should not have clients assigned when there are no intake_ready returns' do
          get :index
          expect(assigns(:clients)).to be_empty
        end
      end

      describe '#edit' do
        it 'should forbid clients without an intake_ready return' do
          get :edit, params: { id: george_sr.id }
          expect(response).to be_forbidden
        end

        it 'should be ok for clients with an intake_ready return' do
          create(
            :tax_return,
            :intake_ready,
            client: george_sr,
            year: 2018,
            assigned_user: user
          )
          get :edit, params: { id: george_sr.id }
          expect(response).to be_ok
        end
      end
    end

    context "when the organization does not allow greeters" do
      before { sign_in(user) }

      let!(:organization) { create :organization, allows_greeters: false }
      let(:user) { create(:user, role: create(:greeter_role), timezone: "America/Los_Angeles") }

      let(:client) do
        build(
          :client,
          vita_partner: organization,
          tax_returns: [
            build(
              :tax_return,
              year: 2019,
              service_type: "drop_off",
              filing_status: nil
            ),
            build(
              :tax_return,
              year: 2018, service_type: "online_intake",
              filing_status: nil
            )
          ]
        )
      end

      let!(:george_sr) do
        create(
          :client,
          vita_partner: organization,
          intake: build(
            :intake,
            :filled_out,
            preferred_name: "George Sr.",
            needs_help_2019: "yes",
            needs_help_2018: "yes",
            preferred_interview_language: "en", locale: "en"
          )
        )
      end
      let!(:george_sr_2019_return) do
        create(
          :tax_return,
          :intake_in_progress,
          client: george_sr,
          year: 2019,
          assigned_user: user
        )
      end

      describe "#index" do
        it 'should not have clients assigned when there is an intake_ready return' do
          create(
            :tax_return,
            :intake_ready,
            client: george_sr,
            year: 2018,
            assigned_user: user
          )
          get :index
          expect(assigns(:clients)).to be_empty
        end

        it 'should not have clients assigned when there are no intake_ready returns' do
          get :index
          expect(assigns(:clients)).to be_empty
        end
      end

      describe '#edit' do
        it 'should forbid clients without an intake_ready return' do
          get :edit, params: { id: george_sr.id }
          expect(response).to be_forbidden
        end

        it 'should be forbidden for clients with an intake_ready return' do
          create(
            :tax_return,
            :intake_ready,
            client: george_sr,
            year: 2018,
            assigned_user: user
          )
          get :edit, params: { id: george_sr.id }
          expect(response).to be_forbidden
        end
      end
    end
  end
end
