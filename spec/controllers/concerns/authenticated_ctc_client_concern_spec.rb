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

  describe "#track_first_visit" do
    context "when a client is authenticated" do
      let(:client) { create(:ctc_intake, visitor_id: "visitor-123").client }

      before do
        sign_in client
        allow(subject).to receive(:send_mixpanel_event)
      end

      context "when the click event does not exist" do
        it "creates one, sets the timestamp, and sends a Mixpanel event" do
          freeze_time do
            expect { subject.track_first_visit(:w2_logout_add_later) }.to change(Analytics::Event, :count).by(1)
            record = Analytics::Event.last
            expect(record.client).to eq(client)
            expect(record.created_at).to eq(DateTime.now)
            expect(record.event_type).to eq("first_visit_w2_logout_add_later")
            expect(subject).to have_received(:send_mixpanel_event).with(event_name: "visit_w2_logout_add_later")
          end
        end
      end

      context "when the click event does exist" do
        let!(:old_event) { create(:analytics_event, client: client, event_type: :w2_logout_add_later) }

        it "sends a Mixpanel event and does not create a new event" do
          expect { subject.track_first_visit(:w2_logout_add_later) }.to change(DataScience::ClickHistory, :count).by(0)
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "visit_w2_logout_add_later")
        end
      end
    end
  end
end
