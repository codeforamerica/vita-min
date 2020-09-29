require "rails_helper"

RSpec.describe ClientsController do
  describe "#create" do
    let(:intake) { create :intake, email_address: "client@example.com", phone_number: "14155537865", preferred_name: "Casey" }
    let(:params) do
      { intake_id: intake.id }
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
            expect(intake.reload.client).to eq client
            expect(response).to redirect_to client_path(id: client.id)
          end
        end

        context "with an intake that already has a client" do
          let(:client) { create :client }
          let!(:intake) { create :intake, client: client }

          it "just redirects to the existing client" do
            expect {
              post :create, params: params
            }.not_to change(Client, :count)

            expect(response).to redirect_to client_path(id: client.id)
          end
        end
      end
    end
  end

  describe "#show" do
    let(:client) { create :client }
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

        expect(response.body).to include(client.preferred_name)
        expect(response.body).to include(client.email_address)
        expect(response.body).to include(client.phone_number)
      end

      context "with existing contact history" do
        let(:twilio_status) { nil }
        let!(:expected_contact_history) do
          [
            create(:incoming_email, body_plain: "Me too! Happy to get every notification", received_at: DateTime.new(2020, 1, 1, 0, 0, 4), client: client),
            create(:outgoing_email, body: "We are really excited to work with you", sent_at: DateTime.new(2020, 1, 1, 0, 0, 3), client: client),
            create(:incoming_text_message, body: "Thx appreciate yr gratitude", received_at: DateTime.new(2020, 1, 1, 0, 0, 2), client: client),
            create(:outgoing_text_message, body: "Your tax return is great", sent_at: DateTime.new(2020, 1, 1, 0, 0, 1), client: client, twilio_status: twilio_status),
          ].reverse
        end

        it "displays all message bodies" do
          get :show, params: { id: client.id }

          expect(assigns(:contact_history)).to eq expected_contact_history
          expect(response.body).to include("Your tax return is great")
          expect(response.body).to include("Thx appreciate yr gratitude")
          expect(response.body).to include("We are really excited to work with you")
          expect(response.body).to include("Me too! Happy to get every notification")
        end

        context "outgoing text messages" do
          context "with Twilio status" do
            let(:twilio_status) { "queued" }

            it "displays the name of the logged in person, time of message, type, and Twilio status" do
              get :show, params: { id: client.id }

              message_record = Nokogiri::HTML.parse(response.body).at_css(".contact-record--outgoing_text_message")
              expect(message_record).to have_text(current_user.name)
              expect(message_record).to have_text("12:00 AM UTC")
              expect(message_record).to have_text("Text to #{client.formatted_phone_number}")
              expect(message_record).to have_text("queued")
            end
          end

          context "without Twilio status" do
            let(:twilio_status) { nil }

            it "shows sending... as Twilio status" do
              get :show, params: { id: client.id }

              expect(response.body).to include("sending...")
            end
          end
        end

        xcontext "incoming text messages" do
        end

        xcontext "outgoing emails" do
        end

        xcontext "incoming emails" do
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
      let!(:george_sr) { create :client, preferred_name: "George Sr.", intakes: [ create(:intake, :filled_out) ] }
      let!(:michael) { create :client, preferred_name: "Michael", intakes: [ create(:intake, :filled_out) ] }
      let!(:tobias) { create :client, preferred_name: "Tobias", intakes: [ create(:intake, :filled_out) ] }

      it "shows a list of clients and client information" do
        get :index

        expect(assigns(:clients).count).to eq 3
        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("#client-#{george_sr.id}")).to have_text("George Sr.")
        expect(html.at_css("#client-#{george_sr.id}")).to have_text(george_sr.intakes.first.vita_partner.display_name)
        expect(html.at_css("#client-#{george_sr.id} a")["href"]).to eq client_path(id: george_sr)
      end
    end
  end
end
