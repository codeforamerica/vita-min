require "rails_helper"

RSpec.describe Hub::MessagesController do
  let(:organization) { create :vita_partner }
  let(:client) { create :client, vita_partner: organization }
  let!(:intake) { create :intake, client: client }
  let(:params) do
    { client_id: client.id }
  end
  let(:timezone) { "America/New_York" }
  let(:user) { create(:organization_lead_user, organization: organization, timezone: timezone) }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as an authenticated user" do
      before { sign_in(user) }

      context "with a message from a suspended user" do
        before do
          create(:outgoing_email, client: client, user: create(:user, suspended_at: DateTime.now, name: "Suspended Succotash"))
        end

        it "shows the suspended user's name with the message" do
          get :index, params: params

          expect(assigns(:messages_by_day).values.flatten[0].user.name).to eq("Suspended Succotash")
        end
      end

      context "viewing communication preferences" do
        render_views
        context "without way to communicate" do
          before do
            intake.update(sms_notification_opt_in: "no", email_notification_opt_in: "no", email_address: "", sms_phone_number: nil)
          end

          it "includes the cannot communicate text" do
            get :index, params: params
            comms = Nokogiri::HTML.parse(response.body).css(".communication-preferences")
            expect(comms.text).to include "Client has not provided contact info"
          end
        end

        context "when opted into text messages only" do
          before do
            intake.update(sms_notification_opt_in: "yes", sms_phone_number: "+18324658840", email_notification_opt_in: "no")
          end
          it "includes the text message preference text" do
            get :index, params: params
            comms = Nokogiri::HTML.parse(response.body).css(".communication-preferences")
            expect(comms.text).to include "#{client.preferred_name} has opted in to contact by"
            expect(comms.text).to include "Text Message"
            expect(comms.text).not_to include "Email"
          end
        end

        context "when opted into emails only" do
          before do
            intake.update(sms_notification_opt_in: "no", sms_phone_number: "+18324658840", email_notification_opt_in: "yes", email_address: "mango@example.com")
          end
          it "includes the text message preference text" do
            get :index, params: params
            comms = Nokogiri::HTML.parse(response.body).css(".communication-preferences")
            expect(comms.text).to include "#{client.preferred_name} has opted in to contact by"
            expect(comms.text).to include "Email"
            expect(comms.text).not_to include "Text Message"
          end
        end

        context "when opted into both" do
          before do
            intake.update(sms_notification_opt_in: "yes", sms_phone_number: "+18324658840", email_notification_opt_in: "yes", email_address: "mango@example.com")
          end
          it "includes the text message preference text" do
            get :index, params: params
            comms = Nokogiri::HTML.parse(response.body).css(".communication-preferences")
            expect(comms.text).to include "#{client.preferred_name} has opted in to contact by"
            expect(comms.text).to include "Email"
            expect(comms.text).to include "Text Message"
          end
        end
      end

      context "with existing contact history" do
        render_views

        let(:twilio_status) { nil }
        let(:client) { create(:client, vita_partner: organization) }
        let(:intake) { create(:intake, client: client, preferred_name: "George Sr.", phone_number: "+14155551233", email_address: "money@banana.stand") }
        let!(:expected_contact_history) do
          [
            create(:outgoing_text_message, body: "You're very welcome", created_at: DateTime.new(2020, 1, 2, 3, 0, 5), to_phone_number: '+14155532222', client: client, twilio_status: twilio_status, user: create(:user, name: "Lucille")),
            create(:outgoing_email, body: "Can you send me a photo of your ID", created_at: DateTime.new(2020, 1, 2, 1, 0, 3), client: client, user: create(:user, name: "Gob"), to: "always@banana.stand"),
            create(:incoming_email, body_plain: "Me too! Happy to get every notification", received_at: DateTime.new(2020, 1, 1, 18, 0, 4), client: client, from: "Georgie <money@banana.stand>"),
            create(:outgoing_email, body: "We are really excited to work with you", sent_at: DateTime.new(2020, 1, 1, 14, 0, 3), client: client, user: create(:user, name: "Gob"), to: "always@banana.stand"),
            create(:incoming_text_message, body: "Thx appreciate yr gratitude", received_at: DateTime.new(2020, 1, 1, 0, 0, 2), from_phone_number: "+14155537865", client: client),
            create(:outgoing_text_message, body: "Your tax return is great", sent_at: DateTime.new(2019, 12, 31, 0, 0, 1), to_phone_number: '+14155532222', client: client, twilio_status: twilio_status, user: create(:user, name: "Lucille")),
          ].reverse
        end

        before do
          create :outgoing_text_message #unrelated message
        end

        it "displays all message bodies sorted by date" do
          get :index, params: params

          expect(assigns(:messages_by_day).values.flatten).to eq expected_contact_history

          messages = Nokogiri::HTML.parse(response.body).css(".message__body")

          expect(messages[0]).to have_text("Your tax return is great")
          expect(messages[1]).to have_text("Thx appreciate yr gratitude")
          expect(messages[2]).to have_text("We are really excited to work with you")
          expect(messages[3]).to have_text("Me too! Happy to get every notification")
        end

        it "adds a 'last-item' id attribute to the last contact record" do
          get :index, params: params

          last_message = Nokogiri::HTML.parse(response.body).css(".message:last-child").first
          expect(last_message.attr("id")).to eq "last-item"
        end

        it "groups messages by date" do
          get :index, params: params

          expect(assigns(:messages_by_day).values.flatten).to eq expected_contact_history

          expect(assigns(:messages_by_day).keys.count).to eq 3
          expect(assigns(:messages_by_day).keys[0]).to eq DateTime.new(2019, 12, 31, 0, 0, 1).in_time_zone('America/New_York').beginning_of_day
          expect(assigns(:messages_by_day).keys[1]).to eq DateTime.new(2020, 1, 1, 0, 0, 2).in_time_zone('America/New_York').beginning_of_day
          expect(assigns(:messages_by_day).keys[2]).to eq DateTime.new(2020, 1, 1, 14, 0, 3).in_time_zone('America/New_York').beginning_of_day
        end

        context "outgoing text messages" do
          context "with Twilio status" do
            let(:twilio_status) { "queued" }

            it "displays the name of the author, time of message, type, body, and Twilio status" do
              get :index, params: params

              message_record = Nokogiri::HTML.parse(response.body).at_css(".message--outgoing_text_message")
              expect(message_record).to have_text("Lucille")
              expect(message_record).to have_text("7:00 PM EST")
              expect(message_record).to have_text("(415) 553-2222")
              expect(message_record).to have_css(".message__status[alt='queued']")
              expect(message_record).to have_text("Your tax return is great")
            end
          end

          context "without Twilio status" do
            let(:twilio_status) { nil }

            it "shows sending as Twilio status" do
              get :index, params: params

              message_record = Nokogiri::HTML.parse(response.body).at_css(".message--outgoing_text_message")
              expect(message_record).to have_css(".message__status[alt='sending']")
            end
          end
        end

        context "incoming text messages" do
          it "displays the time of message, type, body" do
            get :index, params: params

            message_record = Nokogiri::HTML.parse(response.body).at_css(".message--incoming_text_message")
            expect(message_record).to have_text("7:00 PM EST")
            expect(message_record).to have_text("(415) 553-7865")
            expect(message_record).to have_text("Thx appreciate yr gratitude")
          end
        end

        context "outgoing emails" do
          it "displays the author, time of message, type, body, recipient" do
            get :index, params: params

            message_record = Nokogiri::HTML.parse(response.body).at_css(".message--outgoing_email")
            expect(message_record).to have_text("Gob")
            expect(message_record).to have_text("9:00 AM EST")
            expect(message_record).to have_text("always@banana.stand")
            expect(message_record).to have_text("We are really excited to work with you")
          end
        end

        context "incoming emails" do
          it "displays the name of the client, time of message, type, body" do
            get :index, params: params

            message_record = Nokogiri::HTML.parse(response.body).at_css(".message--incoming_email")
            expect(message_record).to have_text("1:00 PM EST")
            expect(message_record).to have_text("Georgie <money@banana.stand>")
            expect(message_record).to have_text("Me too! Happy to get every notification")
          end
        end

        context "with messages from different days" do
          let(:timezone) { "America/Los_Angeles" }

          before do
            create(:outgoing_email, sent_at: DateTime.new(2019, 10, 4, 14), client: client)
            create(:incoming_email, received_at: DateTime.new(2020, 10, 4, 18), client: client)
          end

          it "correctly groups messages by day created" do
            get :index, params: params
            day1 = DateTime.new(2019, 10, 4, 14).in_time_zone('America/Los_Angeles').beginning_of_day
            day2 = DateTime.new(2020, 10, 4, 18).in_time_zone('America/Los_Angeles').beginning_of_day

            expect(assigns(:messages_by_day).keys.first).to eq day1
            expect(assigns(:messages_by_day).keys.last).to eq day2
          end
        end
      end

      context "with messages that have attachments" do
        render_views

        before do
          create(:outgoing_email, client: client,
            attachment: Rack::Test::UploadedFile.new("spec/fixtures/files/test-pattern.png", "image/png")
          )

          create(:incoming_email, client: client, documents: [
            create(:document, upload_path: (Rails.root.join("spec", "fixtures", "files", "test-pattern.png"))),
            create(:document, upload_path: (Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf")))
          ])

          create(:incoming_text_message, body: nil, client: client, documents: [
            create(:document, upload_path: (Rails.root.join("spec", "fixtures", "files", "test-pattern.png")))
          ])
        end

        it "displays the attachments" do
          get :index, params: params

          html_body = Nokogiri::HTML.parse(response.body)
          outgoing_email_attachments = html_body.at_css(".message--outgoing_email .message__body .attachments-list")
          expect(outgoing_email_attachments).to have_text "test-pattern.png"
          incoming_email_attachments = html_body.at_css(".message--incoming_email .message__body .attachments-list")
          expect(incoming_email_attachments).to have_text "test-pattern.png"
          expect(incoming_email_attachments).to have_text "test-pdf.pdf"
          text_message_attachments = html_body.at_css(".message--incoming_text_message .message__body .attachments-list")
          expect(text_message_attachments).to have_text "test-pattern.png"
        end
      end
    end
  end
end
