require "rails_helper"

RSpec.describe AjaxMixpanelEventsController, type: :controller do
  before { allow(subject).to receive(:send_mixpanel_event) }

  context "with valid params" do
    let(:valid_params) do
      {
        event_name: "clicked_link",
        full_path: "/page?key=value",
        controller_action: "Questions::TestQuestionController#edit",
        data: {
          link_text: "Sign in with ID.me",
        }
      }
    end

    it "sends an event to mixpanel" do
      post :create,  params: valid_params

      expect(subject).to have_received(:send_mixpanel_event).with(
        event_name: "clicked_link",
        data: {
          path: "/page",
          full_path: "/page?key=value",
          controller_action: "Questions::TestQuestionController#edit",
          controller_action_name: "edit",
          controller_name: "Questions::TestQuestion",
          "link_text" => "Sign in with ID.me",
        }
      )
    end

    context "with no custom data" do
      let(:valid_params) do
        {
          event_name: "clicked_link",
          full_path: "/page?key=value",
          controller_action: "Questions::TestQuestionController#edit",
        }
      end

      it "sends an event to mixpanel" do
        post :create,  params: valid_params

        expect(subject).to have_received(:send_mixpanel_event).with(
          event_name: "clicked_link",
          data: {
            path: "/page",
            full_path: "/page?key=value",
            controller_action: "Questions::TestQuestionController#edit",
            controller_action_name: "edit",
            controller_name: "Questions::TestQuestion",
          }
        )
      end
    end
  end

  context "with invalid params" do
    let(:invalid_params) do
      {
        data: {
          some_key: "some_value",
        }
      }
    end

    it "returns an error and doesn't send to mixpanel" do
      post :create,  params: invalid_params

      expect(response.status).to eq(400)
      expect(subject).not_to have_received(:send_mixpanel_event)
    end
  end
end