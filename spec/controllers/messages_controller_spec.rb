require "rails_helper"

RSpec.describe MessagesController do
  let(:client) { create :client }
  let(:params) do
    { client_id: client.id }
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    it_behaves_like :a_get_action_for_beta_testers_only, action: :index

    context "as an authenticated beta tester" do
      let(:beta_user) { create :beta_tester }
      before { sign_in(beta_user) }

      context "with existing contact history" do
        render_views

        let(:twilio_status) { nil }
        let!(:expected_contact_history) do
          [
            create(:incoming_email, body_plain: "Me too! Happy to get every notification", received_at: DateTime.new(2020, 1, 1, 0, 0, 4), client: client),
            create(:outgoing_email, body: "We are really excited to work with you", sent_at: DateTime.new(2020, 1, 1, 0, 0, 3), client: client),
            create(:incoming_text_message, body: "Thx appreciate yr gratitude", received_at: DateTime.new(2020, 1, 1, 0, 0, 2), client: client),
            create(:outgoing_text_message, body: "Your tax return is great", sent_at: DateTime.new(2020, 1, 1, 0, 0, 1), client: client, twilio_status: twilio_status),
          ].reverse
        end

        it "displays all message bodies sorted by date" do
          get :index, params: params

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
              get :index, params: params

              message_record = Nokogiri::HTML.parse(response.body).at_css(".contact-record--outgoing_text_message")
              expect(message_record).to have_text(beta_user.name)
              expect(message_record).to have_text("12:00 AM UTC")
              expect(message_record).to have_text("Text to #{client.formatted_phone_number}")
              expect(message_record).to have_text("queued")
            end
          end

          context "without Twilio status" do
            let(:twilio_status) { nil }

            it "shows sending... as Twilio status" do
              get :index, params: params

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
end