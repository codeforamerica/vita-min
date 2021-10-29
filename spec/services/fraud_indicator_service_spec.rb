require "rails_helper"

describe FraudIndicatorService do
  let(:submission) { create :efile_submission, :preparing }
  let(:client) { submission.client }
  let(:user) { create :admin_user }

  describe "#hold_indicators" do
    context "recaptcha_score" do
      context "for old-style scores (on the efile security information)" do
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

      context "for new-style scores (on the RecaptchaScore table)" do
        context "when a recaptcha score is fraudy" do
          before do
            create :recaptcha_score, client: submission.client, score: 0.1, action: 'bank_account'
            create :recaptcha_score, client: submission.client, score: 0.3, action: 'confirm_legal'
          end

          it "responds with an array that includes recaptcha_score" do
            expect(FraudIndicatorService.new(client).hold_indicators).to eq ['recaptcha_score']
          end
        end

        context "when recaptcha scores are not present" do
          it "the response array does not include recaptcha_score" do
            expect(FraudIndicatorService.new(client).hold_indicators).to eq []
          end
        end

        context "when recaptcha score is present but above the fraud threshold" do
          before do
            create :recaptcha_score, client: submission.client, score: 0.3, action: 'bank_account'
            create :recaptcha_score, client: submission.client, score: 0.6, action: 'confirm_legal'
          end

          it "the response array does not include recaptcha_score" do
            expect(FraudIndicatorService.new(client).hold_indicators).to eq []
          end
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

      context "when a timezone is from the overrides yml file" do
        before do
          submission.client.efile_security_informations.first.update(timezone: "America/Indianapolis")
        end

        it "the response array is empty" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq []
        end
      end
    end

    context "duplicated bank account" do
      context "when there is a duplicate bank account" do
        before do
          client.intake.update(bank_account: (create :bank_account, routing_number: "122345678"))
          create :bank_account, routing_number: "122345678"
        end

        it "includes duplicated_bank_account in fraud concerns" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq ["duplicate_bank_account"]
        end
      end

      context "when there is no duplicated bank account" do
        before do
          create :bank_account, routing_number: "123456333", account_number: "1234345435", intake: submission.intake
        end

        it "includes duplicated_bank_account in fraud concerns" do
          expect(FraudIndicatorService.new(client).hold_indicators).to eq []
        end
      end
    end

    context "duplicated phone number" do
      let(:intake) { create :ctc_intake, phone_number: "+18324658840" }
      context "when there are 3 or more CTC Intakes with duplicated phone numbers" do
        before do
          3.times do
            create :ctc_intake, phone_number: "+18324658840"
          end
        end

        it "marks for fraud" do
          expect(FraudIndicatorService.new(intake.client).hold_indicators).to eq ["duplicate_phone_number"]
        end
      end

      context "when there are fewer than 3 CTC intakes with the same phone number" do
        let(:intake) { create :ctc_intake, phone_number: "+15124441234" }

        before do
          create :ctc_intake, phone_number: "+15124441234"
        end

        it "marks for fraud" do
          expect(FraudIndicatorService.new(intake.client).hold_indicators).to eq []
        end
      end

      context "when there are GYR intakes with the same phone number" do
        let(:intake) { create :ctc_intake, phone_number: "+18324658840" }

        before do
          3.times do
            create :intake, phone_number: "+18324758840", type: "Intake::GyrIntake"
          end
        end

        it "marks for fraud" do
          expect(FraudIndicatorService.new(intake.client).hold_indicators).to eq []
        end
      end
    end
  end
end