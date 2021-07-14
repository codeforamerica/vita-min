require "rails_helper"

describe ClientLoginService do
  describe "#clients_for_token" do
    let(:service_type) { "online_intake" }
    let!(:tax_return) { create :tax_return, service_type: service_type }
    let!(:client) { create :client, login_token: login_token, tax_returns: [tax_return] }
    let(:login_token) { nil }

    before do
      allow(Devise.token_generator).to receive(:digest).and_return("hashed_token")
    end

    context "service_type: :gyr" do
      subject { described_class.new(:gyr) }

      context "with a client with a matching token" do
        let(:login_token) { "hashed_token" }

        it "returns the client" do
          expect(subject.clients_for_token("raw_token")).to match_array [client]
        end
      end

      context "with a client matching a TextMessageAccessToken" do
        before do
          create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
          create(:intake, :primary_consented, client: client, sms_phone_number: "+16505551212")
        end

        it "returns the client" do
          expect(subject.clients_for_token("raw_token")).to match_array [client]
        end
      end

      context "with a client whose email matches an EmailAccessToken" do
        before do
          create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
          create(:intake, :primary_consented, client: client, email_address: "someone@example.com")
        end

        it "returns the client" do
          expect(subject.clients_for_token("raw_token")).to match_array [client]
        end
      end

      context "with a client whose spouse email matches an EmailAccessToken" do
        before do
          create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
          create(:intake, :primary_consented, client: client, spouse_email_address: "someone@example.com")
        end

        it "returns the client" do
          expect(subject.clients_for_token("raw_token")).to match_array [client]
        end
      end

      context "with a client whose email is contained in a comma-separated EmailAccessToken" do
        before do
          create(:email_access_token, token: "hashed_token", email_address: "someone@example.com,other@example.com")
          create(:intake, :primary_consented, client: client, email_address: "someone@example.com")
        end

        it "returns the client" do
          expect(subject.clients_for_token("raw_token")).to match_array [client]
        end
      end

      context "with a client with matching access tokens older than 2 days" do
        let!(:client) { create :client }
        before do
          create(:email_access_token, token: "hashed_token", email_address: "someone@example.com", created_at: Time.current - (2.1).days)
          create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212", created_at: Time.current - (2.1).days)
          create(:intake, :primary_consented, client: client, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
        end

        it "returns a blank set" do
          expect(subject.clients_for_token("raw_token")).to match_array []
        end
      end

      context "with no matching token" do
        it "returns a blank set" do
          expect(subject.clients_for_token("raw_token")).to match_array []
        end
      end

      context "with a client with no consent to service" do
        subject { described_class.new(:gyr) }
        context "with a gyr service_type" do
          before do
            create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
            create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
            create(:intake, client: client, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
          end

          it "returns a blank set" do
            expect(subject.clients_for_token("raw_token")).to match_array []
          end

          context "with a client that is a drop off" do
            let(:service_type) { "drop_off" }

            it "returns the client" do
              expect(subject.clients_for_token("raw_token")).to match_array [client]
            end
          end
        end

        context "with a ctc service type and ctc intake" do
          subject { described_class.new(:ctc) }

          before do
            create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
            create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
            create(:ctc_intake, client: client, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
          end

          it "finds a match, because consenting is not a prerequisite to logging in for CTC" do
            expect(subject.clients_for_token("raw_token")).to match_array [client]

          end
        end
      end
    end
  end

  describe ".can_login_by_sms_verification?" do
    let(:phone_number) { "+18324651680" }

    context "service_type is :gyr" do
      subject { described_class.new(:gyr) }

      context "when client phone number maps to online and consented return" do
        before do
          create :client, intake: (create :intake, phone_number: phone_number, primary_consented_to_service: "yes"), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
        end

        it "is true" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be true
        end
      end

      context "when a clients phone number is linked to a return that has not consented" do
        subject { described_class.new(:gyr) }

        let(:phone_number) { "+18324651111" }
        before do
          create :client, intake: (create :intake, phone_number: phone_number), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
        end

        it "is false" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be false
        end
      end

      context "when a client is associated to a drop off service type" do
        subject { described_class.new(:gyr) }

        let(:phone_number) { "+18324651111" }
        before do
          create :client, intake: (create :intake, phone_number: phone_number), tax_returns: [create(:tax_return, service_type: "drop_off", status: "prep_ready_for_prep")]
        end

        it "is true" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be true
        end
      end

      context "when there are no matching returns with that data" do
        it "is false" do
          expect(subject.can_login_by_sms_verification?("+1111111111")).to be false
        end
      end
    end

    context "service_type is :ctc" do
      context "when there are no matching returns with that data" do
        subject { described_class.new(:gyr) }

        let(:locale) { "es" }
        let(:phone_number) { "+1111111111" }

        it "is false" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be false
        end
      end
    end
  end

  describe ".handle_email_request" do
    context "when service_type is :gyr" do
      subject { described_class.new(:gyr) }
      context "when there is a consented online intake with matching email" do
        let(:email_address) { "mango@example.com" }
        before do
          create :client, intake: (create :intake, email_address: email_address, primary_consented_to_service: "yes"), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a consented online intake with a matching spouse email" do
        let(:email_address) { "mangospouse@example.com" }
        before do
          create :client, intake: (create :intake, spouse_email_address: email_address, primary_consented_to_service: "yes"), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a drop off intake with a matching email" do
        let(:email_address) { "persimmion@example.com" }
        before do
          create :client, intake: (create :intake, email_address: email_address), tax_returns: [create(:tax_return, service_type: "drop_off", status: "prep_ready_for_prep")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a drop off intake with a matching spouse email" do
        let(:email_address) { "persimmion@example.com" }
        before do
          create :client, intake: (create :intake, spouse_email_address: email_address), tax_returns: [create(:tax_return, service_type: "drop_off", status: "prep_ready_for_prep")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a matching online intake that has not consented to service" do
        let(:email_address) { "noconsent@example.com" }
        before do
          create :client, intake: (create :intake, spouse_email_address: email_address), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
        end

        it "is false" do
          expect(subject.can_login_by_email_verification?(email_address)).to be false
        end
      end

      context "with no associated intakes" do
        let(:email_address) { "nomatch1234567@example.com" }

        it "is false" do
          expect(subject.can_login_by_email_verification?(email_address)).to be false
        end
      end
    end
    context "when service_type is :ctc" do
      subject { described_class.new(:ctc) }

      let(:client) { create :client }
      context "when there is an existing client a ctc intake" do
        before do
          create :ctc_intake, email_address: "something@example.com", client: client
        end

        it "returns true" do
          expect(subject.can_login_by_email_verification?(client.email_address)).to be true
        end
      end

      context "when there is no matching client with a ctc intake" do
        before do
          create :intake, email_address: "something@example.com", client: client
        end

        it "returns false" do
          expect(subject.can_login_by_email_verification?(client.email_address)).to be false
        end
      end
    end
  end
end
