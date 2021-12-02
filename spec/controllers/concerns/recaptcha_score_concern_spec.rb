require "rails_helper"

RSpec.describe RecaptchaScoreConcern, type: :controller do

  controller(ApplicationController) do
    include RecaptchaScoreConcern
  end

  describe "#recaptcha_score_param" do
    include MockDogapi

    before do
      DatadogApi.configure do |c|
        allow(c).to receive(:enabled).and_return(true)
      end

      @emit_point_params = []
      allow(@mock_dogapi).to receive(:emit_point) do |*params|
        @emit_point_params << params
      end
    end

    context "when able to verify" do
      before do
        allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:recaptcha_reply).and_return({ 'score' => "0.7" })
      end

      it "returns a score" do
        expect(subject.recaptcha_score_param("test")).to eq({ recaptcha_score: "0.7", recaptcha_action: "test" })
        expect(@emit_point_params).to eq([
          ["vita-min.dogapi.recaptcha.success", 1, {:tags=>["env:test"], :type=>"count"}]
        ])
      end
    end

    context "when unable to verify" do
      before do
        allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:verify_recaptcha).and_return(false)
        allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:recaptcha_reply).and_return({ 'error-codes' => ['a-terrible-test-failure'] })
      end

      it "sends a Sentry message and returns an empty hash" do
        expect(subject.recaptcha_score_param("test")).to eq({})
        expect(@emit_point_params).to eq([
          ["vita-min.dogapi.recaptcha.failure.with_error", 1, {:tags=>["error_codes:a-terrible-test-failure", "env:test"], :type=>"count"}]
        ])
      end

      context "when no reply is available" do
        before do
          allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:recaptcha_reply).and_return(nil)
        end

        it "sends a more dire Sentry message and returns an empty hash" do
          expect(subject.recaptcha_score_param("test")).to eq({})
          expect(@emit_point_params).to eq([
            ["vita-min.dogapi.recaptcha.failure.unknown", 1, {:tags=>["env:test"], :type=>"count"}]
          ])
        end
      end
    end
  end
end
