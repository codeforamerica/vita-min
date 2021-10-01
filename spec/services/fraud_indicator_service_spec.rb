require "rails_helper"

describe FraudIndicatorService do
  let(:submission) { create :efile_submission, :preparing }
  let(:client) { submission.client }
  let(:user) { create :admin_user }

  describe "#hold_indicators" do
    context "recaptcha_score" do
      context "when a recaptcha score is fraudy" do
        before do
          create :efile_security_information, client: submission.client, recaptcha_score: 0.1
        end

        it "responds with an array that includes recaptcha_score" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq ['recaptcha_score']
        end
      end

      context "when recaptcha scores are not present" do
        before do
          create :efile_security_information, client: submission.client, recaptcha_score: nil
        end

        it "the response array does not include recaptcha_score" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq []
        end
      end

      context "when recaptcha score is present but above the fraud threshold" do
        before do
          create :efile_security_information, client: submission.client, recaptcha_score: 0.3
        end

        it "the response array does not include recaptcha_score" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq []
        end
      end
    end

    context "timezones" do
      context "when a timezone is international" do
        before do
          create :efile_security_information, client: submission.client, timezone: "West Africa"
        end

        it "responds with an array that includes recaptcha_score" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq ['international_timezone']
        end
      end

      context "when timezone is not present" do
        before do
          submission.client.efile_security_informations.first.update(timezone: nil)
        end

        it "the response array does not include recaptcha_score" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq ['empty_timezone']
        end
      end

      context "when a us timezone is present" do
        before do
          submission.client.efile_security_informations.first.update(timezone: "America/Chicago")
        end

        it "the response array does not include recaptcha_score" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq []
        end
      end

      context "when a timezone is present and not an international timezone (alternate format)" do
        before do
          submission.client.efile_security_informations.first.update(timezone: "Central Time (US & Canada)")
        end

        it "the response array does not include international_timezone" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq []
        end
      end

      context "when a us timezone is present but another one is empty" do
        before do
          submission.client.efile_security_informations.first.update(timezone: "Central Time (US & Canada)")
          create :efile_security_information, client: submission.client, timezone: nil
        end

        it "the response array includes international_timezone" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq ['empty_timezone']

        end
      end
    end

  end
end