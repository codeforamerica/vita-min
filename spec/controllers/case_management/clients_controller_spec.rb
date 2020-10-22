require "rails_helper"

RSpec.describe CaseManagement::ClientsController do
  describe "#create" do
    let(:user) { create :beta_tester }
    let(:intake) { create :intake, email_address: "client@example.com", phone_number: "14155537865", preferred_name: "Casey", vita_partner: user.vita_partner }
    let(:params) do
      { intake_id: intake.id }
    end
    let!(:document) do
      create(:document, intake: intake)
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create
    it_behaves_like :a_post_action_for_beta_testers_only, action: :create

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
            expect(client.email_address).to eq "client@example.com"
            expect(client.phone_number).to eq "14155537865"
            expect(client.preferred_name).to eq "Casey"
            expect(client.documents.first).to eq(document)
            expect(client.intake).to eq(intake)
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
    let(:user) { create :beta_tester, vita_partner: vita_partner }
    let(:intake) do
      create :intake,
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

    let(:client) { create :client, intake: intake, vita_partner: vita_partner }
    let(:params) do
      { id: client.id }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show
    it_behaves_like :a_get_action_for_beta_testers_only, action: :show

    context "as an authenticated beta tester" do
      render_views

      before { sign_in(user) }

      it "shows client information" do
        get :show, params: params
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
          expect(profile).to have_text("Needs Response? Yes")
        end
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "as an authenticated beta tester" do
      render_views

      let(:vita_partner) { create(:vita_partner) }
      let(:user) { create(:beta_tester, vita_partner: vita_partner) }

      before { sign_in user }
      let!(:george_sr) { create :client, preferred_name: "George Sr.", vita_partner: vita_partner, intake: create(:intake, :filled_out, needs_help_2019: "yes", needs_help_2018: "yes", locale: "en") }
      let!(:michael) { create :client, preferred_name: "Michael", vita_partner: vita_partner, intake: create(:intake, :filled_out, needs_help_2019: "yes", needs_help_2017: "yes") }
      let!(:tobias) { create :client, preferred_name: "Tobias", vita_partner: vita_partner, intake: create(:intake, :filled_out, needs_help_2018: "yes", locale: "es") }
      let(:assigned_user) { create :user, name: "Lindsay", vita_partner: vita_partner }
      let!(:tobias_2019_return) { create :tax_return, client: tobias, year: 2019, assigned_user: assigned_user }
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
          expect(html.at_css("#client-#{michael.id} .client-attribute__needs-response")).to have_text "No"
          expect(html.at_css("#client-#{tobias.id} .client-attribute__needs-response")).to have_text "Yes"
        end
      end
    end
  end

  describe "#flag" do
    let(:params) do
      { id: client.id, client: {} }
    end
    let(:client) { create :client, vita_partner: create(:vita_partner) }
    let(:current_user) { create :beta_tester, vita_partner: client.vita_partner }
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
end
