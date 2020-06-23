require "rails_helper"

RSpec.describe Stimulus::StimulusController do
  let(:user_agent_string) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.360" }

  controller do
    def index
      head :ok
    end
  end

  describe "#send_mixpanel_event" do
    let(:mixpanel_spy) { spy(MixpanelService) }

    before do
      allow(MixpanelService).to receive(:instance).and_return(mixpanel_spy)
      cookies[:visitor_id] = "123"
      session[:source] = "vdss"
      session[:utm_state] = "CA"
      request.headers["HTTP_USER_AGENT"] = user_agent_string
      request.headers["HTTP_REFERER"] = "http://coolwebsite.horse/tax-help/vita"
    end

    context "with a current stimulus triage" do
      let(:stimulus_triage) do
        build(
          :stimulus_triage,
          chose_to_file: "no",
          filed_prior_years: "yes",
          filed_recently: "yes",
          need_to_correct: "no",
          need_to_file: "no",
          source: "horse-ad-campaign-26",
          referrer: "http://coolwebsite.horse/tax-help/vita"
        )
      end

      before do
        allow(subject).to receive(:current_stimulus_triage).and_return(stimulus_triage)
      end

      it "sends fields about the stimulus triage" do
        get :index

        expect(mixpanel_spy).to have_received(:run).with(
          unique_id: "123",
          event_name: "page_view",
          data: hash_including(
            stimulus_triage_source: "horse-ad-campaign-26",
            stimulus_triage_referrer: "http://coolwebsite.horse/tax-help/vita",
            chose_to_file: "no",
            filed_prior_years: "yes",
            filed_recently: "yes",
            need_to_correct: "no",
            need_to_file: "no"
          )
        )
      end
    end
  end
end