require "rails_helper"

RSpec.describe Hub::UserNotificationsController, type: :controller do
  let(:user) { create :team_member_user }
  let!(:notification_first) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
  let!(:notification_second) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
  let!(:notification_third) { create :user_notification, user: user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }
  let!(:other_notification) { create :user_notification, user: create(:user), read: false, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as a logged in user loading user notifications" do

      before { sign_in user }

      it "loads notifications in descending order" do
        get :index

        expect(response).to be_ok
        expect(assigns(:user_notifications)).not_to include other_notification
        expect(assigns(:user_notifications)).to eq [notification_third, notification_second, notification_first]
      end

      describe "bulk client message notification" do
        render_views

        let(:failed_clients) { [] }
        let(:successful_clients) { [] }
        let(:in_progress_clients) { [] }
        let(:bulk_client_message) { create :bulk_client_message }
        let!(:notification) { create :user_notification, user: user, notifiable: bulk_client_message }
        before do
          allow_any_instance_of(BulkClientMessage).to receive(:clients_with_no_successfully_sent_messages).and_return Client.where(id: failed_clients)
          allow_any_instance_of(BulkClientMessage).to receive(:clients_with_successfully_sent_messages).and_return Client.where(id: successful_clients)
          allow_any_instance_of(BulkClientMessage).to receive(:clients_with_in_progress_messages).and_return Client.where(id: in_progress_clients)
        end

        context "with any number of failed clients" do
          let(:failed_clients) { [ create(:client) ] }

          it "shows the count of failed clients" do
            get :index

            notification_html = Nokogiri::HTML.parse(response.body).at_css("#notification-#{notification.id}.notification--failed")
            expect(notification_html.at_css(".notification__heading")).to have_text "Unsuccessful Bulk Send a Message"
            expect(notification_html).to have_text "We could not contact 1 client."
          end
        end

        context "with any number of successful clients" do
          let(:successful_clients) { [ create(:client), create(:client) ] }
          let(:in_progress_clients) { [ create(:client), create(:client) ] }

          it "shows the count of successful clients" do
            get :index

            notification_html = Nokogiri::HTML.parse(response.body).at_css("#notification-#{notification.id}.notification--in-progress")
            expect(notification_html.at_css(".notification__heading")).to have_text "Bulk Send a Message In Progress"
            expect(notification_html).to have_text "You successfully contacted 2 clients."
          end

          context "with no in-progress clients" do
            let(:in_progress_clients) { [] }

            it "does not show the in-progress client count" do
              get :index

              notification_html = Nokogiri::HTML.parse(response.body).at_css("#notification-#{notification.id}.notification--succeeded")
              expect(notification_html.at_css(".notification__heading")).to have_text "Successful Bulk Send a Message"
              expect(notification_html.at_css("p.in-progress")).not_to be_present
            end
          end
        end

        context "with any number of in progress clients" do
          let(:in_progress_clients) { [ create(:client), create(:client) ] }

          it "shows the correct title, the count of in progress clients" do
            get :index

            notification_html = Nokogiri::HTML.parse(response.body).at_css("#notification-#{notification.id}")
            expect(notification_html.at_css(".notification__heading")).to have_text "Bulk Send a Message In Progress"
            expect(notification_html.at_css("p.in-progress")).to have_text "We are still contacting 2 clients."
          end

          context "with only in progress clients" do
            it "does not show failed or successful client counts" do
              get :index

              notification_html = Nokogiri::HTML.parse(response.body).at_css("#notification-#{notification.id}")
              expect(notification_html.at_css("p.failed")).not_to be_present
              expect(notification_html.at_css("p.succeeded")).not_to be_present
            end
          end

          context "with failed clients" do
            let(:failed_clients) { [ create(:client) ] }
            it "shows the correct title" do
              get :index

              notification_html = Nokogiri::HTML.parse(response.body).at_css("#notification-#{notification.id}")
              expect(notification_html.at_css(".notification__heading")).to have_text "Bulk Send a Message In Progress"
            end
          end
        end
      end
    end
  end

  describe "#mark_all_notifications_read" do
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :mark_all_notifications_read

    context "as an authenticated hub user" do
      before { sign_in user }

      it "marks all the notifications as read" do
        post :mark_all_notifications_read

        expect(response.status).to eq 302
        expect(notification_first.reload.read).to eq true
        expect(notification_second.reload.read).to eq true
        expect(other_notification.reload.read).to eq false
        expect(response).to redirect_to hub_user_notifications_path
      end
    end
  end
end
