require "rails_helper"

RSpec.describe AuthenticatedCtcClientConcern, type: :controller do
  controller(ApplicationController) do
    include AuthenticatedCtcClientConcern

    def index
      head :ok
    end
  end

  describe "before actions" do
    context "when a client is not authenticated" do
      it "redirects to a login page" do
        get :index

        expect(response).to redirect_to new_ctc_portal_client_login_path
      end

      it "adds the current path to the session" do
        get :index, params: { with_querystring: "cool" }

        expect(session[:after_client_login_path]).to eq("/anonymous?with_querystring=cool")
      end

      context "with a POST request" do
        it "redirects but does not store the current path in the session" do
          post :index

          expect(response).to redirect_to new_ctc_portal_client_login_path
          expect(session).not_to include :after_client_login_path
        end
      end
    end

    context "when a client is authenticated" do
      let(:client) { create(:client) }
      before { sign_in client }

      it "does not redirect and doesn't store the current path in the session" do
        get :index

        expect(response).to be_ok
        expect(session).not_to include :after_client_login_path
      end

      it "updates Client last_seen_at" do
        fake_time = Time.utc(2021, 2, 6, 0, 0, 0)
        expect do
          Timecop.freeze(fake_time) do
            get :index
          end
        end.to change { client.reload.last_seen_at }.from(nil).to(fake_time)
      end
    end
  end

  describe "#track_click_history" do
    context "when a client is authenticated" do
      let(:client) { create(:ctc_intake, visitor_id: "visitor-123").client }

      before do
        sign_in client
        allow(subject).to receive(:send_mixpanel_event)
      end

      context "when the client's click history does not exist" do
        it "creates one, sets the timestamp, and sends a Mixpanel event" do
          freeze_time do
            expect { subject.track_click_history(:w2_logout_add_later) }.to change(DataScience::ClickHistory, :count).by(1)
            record = DataScience::ClickHistory.last
            expect(record.client).to eq(client)
            expect(record.w2_logout_add_later).to eq(DateTime.now)
            expect(subject).to have_received(:send_mixpanel_event).with(event_name: "w2_logout_add_later")
          end
        end
      end

      context "when the client's click history does exist" do
        context "when the timestamp is already set" do
          let(:old_timestamp) { DateTime.new(2022, 1, 1) }
          before do
            create(:data_science_click_history, client: client, w2_logout_add_later: old_timestamp)
          end

          it "sends a Mixpanel event and does not change the database" do
            expect { subject.track_click_history(:w2_logout_add_later) }.to change(DataScience::ClickHistory, :count).by(0)
            record = DataScience::ClickHistory.last
            expect(record.client).to eq(client)
            expect(record.w2_logout_add_later).to eq(old_timestamp)
            expect(subject).to have_received(:send_mixpanel_event).with(event_name: "w2_logout_add_later")
          end
        end
      end
    end
  end
end
