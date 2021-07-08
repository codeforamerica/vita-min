require "rails_helper"

describe ClientLoginService do
  describe ".clients_for_token" do
    let(:service_type) { "online_intake" }
    let!(:tax_return) { create :tax_return, service_type: service_type }
    let!(:client) { create :client, login_token: login_token, tax_returns: [tax_return] }
    let(:login_token) { nil }

    before do
      allow(Devise.token_generator).to receive(:digest).and_return("hashed_token")
    end

    context "with a client with a matching token" do
      let(:login_token) { "hashed_token" }

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client matching a TextMessageAccessToken" do
      before do
        create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
        create(:intake, :primary_consented, client: client, sms_phone_number: "+16505551212")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose email matches an EmailAccessToken" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:intake, :primary_consented, client: client, email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose spouse email matches an EmailAccessToken" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:intake, :primary_consented, client: client, spouse_email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose email is contained in a comma-separated EmailAccessToken" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com,other@example.com")
        create(:intake, :primary_consented, client: client, email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
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
        expect(described_class.clients_for_token("raw_token")).to match_array []
      end
    end

    context "with no matching token" do
      it "returns a blank set" do
        expect(described_class.clients_for_token("raw_token")).to match_array []
      end
    end

    context "with a client with no consent to service" do
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
        create(:intake, client: client, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
      end

      it "returns a blank set" do
        expect(described_class.clients_for_token("raw_token")).to match_array []
      end

      context "with a client that is a drop off" do
        let(:service_type) { "drop_off" }

        it "returns the client" do
          expect(described_class.clients_for_token("raw_token")).to match_array [client]
        end
      end
    end
  end

  shared_examples "a phone number we can send a code to" do
    it "enqueues a job to request a code" do
      expect {
        described_class.handle_sms_request(**params)
      }.to have_enqueued_job(RequestVerificationCodeTextMessageJob).with(a_hash_including(**params, service_type: :gyr))
    end
  end

  shared_examples "a phone number we cannot send a code to" do
    before do
      allow(TwilioService).to receive(:send_text_message)
    end

    it "sends the no match text message" do
      text_message_body = if params[:locale].to_sym == :es
                            <<~ESTEXT
      Alguien intentó ingresar a GetYourRefund con este número de teléfono, pero no encontramos el número en nuestro registro. ¿Usó otro número para registrarse?
      También puede ir a http://test.host/es y seleccione “Empiece ahora” para empezar su declaración.
                            ESTEXT
                          else
                            <<~ENTEXT
      Someone tried to sign in to GetYourRefund with this phone number, but we couldn't find a match. Did you sign up with a different phone number?
      You can also visit http://test.host/en and click “Get Started” to start the filing process.
                            ENTEXT
                          end
      expect {
        described_class.handle_sms_request(**params)
      }.not_to have_enqueued_job(RequestVerificationCodeTextMessageJob)
      expect(TwilioService).to have_received(:send_text_message).with(a_hash_including(
                                                                          to: params[:phone_number],
                                                                          body: text_message_body
                                                                      )
      )
    end
  end

  describe ".handle_sms_request" do
    let(:locale) { :en }
    let(:visitor_id) { 16 }
    let(:params) do
      {
          phone_number: phone_number,
          locale: locale,
          visitor_id: visitor_id
      }
    end
    context "when client phone number maps to online and consented return" do
      let(:phone_number) { "+18324651680" }
      before do
        create :client, intake: (create :intake, phone_number: phone_number, primary_consented_to_service: "yes"), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
      end

      it_behaves_like "a phone number we can send a code to"
    end

    context "when a clients phone number is linked to a return that has not consented" do
      let(:phone_number) { "+18324651111" }
      before do
        create :client, intake: (create :intake, phone_number: phone_number), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
      end

      it_behaves_like "a phone number we cannot send a code to"
    end

    context "when a client is associated to a drop off service type" do
      let(:phone_number) { "+18324651111" }
      before do
        create :client, intake: (create :intake, phone_number: phone_number), tax_returns: [create(:tax_return, service_type: "drop_off", status: "prep_ready_for_prep")]
      end

      it_behaves_like "a phone number we can send a code to"
    end

    context "when there are no matching returns with that data" do
      let(:locale) { "es" }
      let(:phone_number) { "+1111111111" }

      it_behaves_like "a phone number we cannot send a code to"
    end
  end

  describe ".handle_email_request" do
    let(:locale) { "en" }
    let(:visitor_id) { "150" }
    let(:params) do
      {
        email_address: email_address,
        locale: locale,
        visitor_id: visitor_id
      }
    end

    shared_examples "an email we cannot send a code to" do
      it "enqueus no match email" do
        expect {
          described_class.handle_email_request(**params)
        }.to have_enqueued_email(VerificationCodeMailer, :no_match_found)

      end
    end

    shared_examples "an email we can send a code to" do
      it "enqueues a job to generate and send the code" do
        expect {
          described_class.handle_email_request(**params)
        }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(a_hash_including(**params, service_type: :gyr))
      end
    end

    context "when there is a consented online intake with matching email" do
      let(:email_address) { "mango@example.com" }
      before do
        create :client, intake: (create :intake, email_address: email_address, primary_consented_to_service: "yes"), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
      end

      it_behaves_like "an email we can send a code to"
    end

    context "when there is a consented online intake with a matching spouse email" do
      let(:email_address) { "mangospouse@example.com" }
      before do
        create :client, intake: (create :intake, spouse_email_address: email_address, primary_consented_to_service: "yes"), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
      end

      it_behaves_like "an email we can send a code to"
    end

    context "when there is a drop off intake with a matching email" do
      let(:email_address) { "persimmion@example.com" }
      before do
        create :client, intake: (create :intake, email_address: email_address), tax_returns: [create(:tax_return, service_type: "drop_off", status: "prep_ready_for_prep")]
      end

      it_behaves_like "an email we can send a code to"
    end

    context "when there is a drop off intake with a matching spouse email" do
      let(:email_address) { "persimmion@example.com" }
      before do
        create :client, intake: (create :intake, spouse_email_address: email_address), tax_returns: [create(:tax_return, service_type: "drop_off", status: "prep_ready_for_prep")]
      end

      it_behaves_like "an email we can send a code to"
    end

    context "when there is a matching online intake that has not consented to service" do
      let(:email_address) { "noconsent@example.com" }
      before do
        create :client, intake: (create :intake, spouse_email_address: email_address), tax_returns: [create(:tax_return, service_type: "online_intake", status: "prep_ready_for_prep")]
      end

      it_behaves_like "an email we cannot send a code to"
    end

    context "with no associated intakes" do
      let(:email_address) { "nomatch1234567@example.com" }

      it_behaves_like "an email we cannot send a code to"
    end
  end
end
