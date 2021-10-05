require "rails_helper"

RSpec.describe RecaptchaScoreConcern, type: :controller do

  controller(ApplicationController) do
    include RecaptchaScoreConcern
  end

  describe "#recaptcha_score_param" do
    context "when able to verify" do
      before do
        allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:recaptcha_reply).and_return({ 'score' => "0.7" })
      end

      it "returns a score" do
        expect(subject.recaptcha_score_param("test")).to eq({ recaptcha_score: "0.7", recaptcha_action: "test" })
      end
    end

    context "when unable to verify" do
      before do
        allow(Sentry).to receive(:capture_message)
        allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:verify_recaptcha).and_return(false)
        allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:recaptcha_reply).and_return({ 'error-codes' => "[a-terrible-test-failure]" })
      end

      it "sends a Sentry message and returns an empty hash" do
        expect(subject.recaptcha_score_param("test")).to eq({})
        expect(Sentry).to have_received(:capture_message).with("Failed to verify recaptcha token due to the following errors: [a-terrible-test-failure]")
      end

      context "when no reply is available" do
        before do
          allow_any_instance_of(Recaptcha::Adapters::ControllerMethods).to receive(:recaptcha_reply).and_return(nil)
        end

        it "sends a more dire Sentry message and returns an empty hash" do
          expect(subject.recaptcha_score_param("test")).to eq({})
          expect(Sentry).to have_received(:capture_message).with("Something bad happened when attempting recaptcha!")
        end
      end
    end
  end
end
