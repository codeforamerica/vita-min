require "rails_helper"

RSpec.describe CaseManagement::ClientsController do
  describe "#create" do
    let(:intake) { create :intake, email_address: "client@example.com", phone_number: "14155537865", preferred_name: "Casey" }
    let(:params) do
      { intake_id: intake.id }
    end
    let!(:document) do
      create(:document, intake: intake)
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create
    it_behaves_like :a_post_action_for_beta_testers_only, action: :create

    context "as an authenticated admin user" do
      before { sign_in(create :beta_tester) }

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
            expect(client.intakes).to include(intake)
            expect(intake.reload.client).to eq client
            expect(response).to redirect_to case_management_client_path(id: client.id)
          end
        end

        context "with an intake that already has a client" do
          let(:client) { create :client }
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
    let(:intake) do
      create :intake,
             client: (create :client),
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
             spouse_last_name: "Spouse"
    end

    let(:client) { intake.client }
    let(:params) do
      { id: client.id }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show
    it_behaves_like :a_get_action_for_beta_testers_only, action: :show

    context "as an authenticated beta tester" do
      render_views

      let(:current_user) { create :beta_tester }
      before { sign_in(current_user) }

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
        before { client.touch(:updated_at, :last_response_at) }

        it "adds the needs attention icon into the DOM" do
          get :show, params: params
          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css(".client-header .needs-attention")).to be_present
        end
      end
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "as an authenticated beta tester" do
      render_views

      before { sign_in create(:beta_tester) }
      let!(:george_sr) { create :client, preferred_name: "George Sr.", intakes: [create(:intake, :filled_out, needs_help_2019: "yes", needs_help_2018: "yes", locale: "en")] }
      let!(:michael) { create :client, preferred_name: "Michael", intakes: [create(:intake, :filled_out, needs_help_2019: "yes", needs_help_2017: "yes") ] }
      let!(:tobias) { create :client, preferred_name: "Tobias", intakes: [create(:intake, :filled_out, needs_help_2018: "yes", locale: "es")] }
      let(:assigned_user) { create :user, name: "Lindsay" }
      let!(:tobias_2019_return) { create :tax_return, client: tobias, year: 2019, assigned_user: assigned_user }
      let!(:tobias_2018_return) { create :tax_return, client: tobias, year: 2018, assigned_user: assigned_user }

      it "shows a list of clients and client information" do
        get :index

        expect(assigns(:clients).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html).to have_text("Updated At")
        expect(html.at_css("#client-#{george_sr.id}")).to have_text("George Sr.")
        expect(html.at_css("#client-#{george_sr.id}")).to have_text(george_sr.intakes.first.vita_partner.display_name)
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
          tobias.touch(:updated_at, :last_response_at)
          get :index
          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css("#client-#{michael.id} .needs-attention")).not_to be_present
          expect(html.at_css("#client-#{tobias.id} .needs-attention")).to be_present
        end
      end
    end
  end
end
