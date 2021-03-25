require "rails_helper"

describe ClientLoginsService do
  before do
    allow(DatadogApi).to receive(:increment)
  end

  describe ".issue_email_token" do
    before do
      allow(Devise.token_generator).to receive(:generate).and_return(["raw_token", "hashed_token"])
    end

    it "generates a new token, saves it, and returns the raw_token" do
      expect do
        result = ClientLoginsService.issue_email_token("someone@example.com")

        expect(Devise.token_generator).to have_received(:generate).with(EmailAccessToken, :token)
        expect(result).to eq "raw_token"
      end.to change(EmailAccessToken, :count).by(1)
      token = EmailAccessToken.last
      expect(token.email_address).to eq "someone@example.com"
      expect(token.token_type).to eq "link"
      expect(token.token).to eq "hashed_token"
    end
  end

  describe ".issue_email_verification_code" do
    before do
      allow(VerificationCodeService).to receive(:generate).with("someone@example.com").and_return(["000004", "hashed_verification_code"])
      allow(Devise.token_generator).to receive(:digest).with(EmailAccessToken, :token, "hashed_verification_code").and_return("double_hashed_verification_code")
    end

    it "generates a new verification code and creates an access token" do
      expect(EmailAccessToken.count).to eq(0)
      raw_verification_code, access_token = described_class.issue_email_verification_code("someone@example.com")
      expect(raw_verification_code).to eq "000004"
      expect(access_token).to eq(EmailAccessToken.last)
      expect(access_token.token_type).to eq "verification_code"
      expect(access_token.email_address).to eq("someone@example.com")
      expect(Devise.token_generator).to have_received(:digest).with(EmailAccessToken, :token, "hashed_verification_code")
      expect(access_token.token).to eq "double_hashed_verification_code"
    end

    context "if there are already 5 live verification codes" do
      let!(:email_access_token_link) { create(:email_access_token, created_at: (1.5).days.ago, email_address: "someone@example.com", token_type: "link") }
      let!(:oldest_email_access_token) { create(:email_access_token, created_at: 1.day.ago, email_address: "someone@example.com", token_type: "verification_code") }
      let!(:email_access_tokens) { create_list(:email_access_token, 4, email_address: "someone@example.com", token_type: "verification_code") }

      it "deletes the oldest of the existing codes" do
        described_class.issue_email_verification_code("someone@example.com")

        expect {
          EmailAccessToken.find(oldest_email_access_token.id)
        }.to raise_error ActiveRecord::RecordNotFound
        expect(EmailAccessToken.find(email_access_token_link.reload.id)).to eq email_access_token_link
      end
    end

    context "Datadog" do
      it "increments a metric when creating an access token" do
        described_class.issue_email_verification_code("someone@example.com")
        expect(DatadogApi).to have_received(:increment).with("client_logins.verification_codes.email.created")
      end
    end
  end

  describe ".issue_text_message_token" do
    before do
      allow(Devise.token_generator).to receive(:generate).and_return(["raw_token", "hashed_token"])
    end

    it "generates a new token, saves it, and returns the raw_token" do
      expect do
        result = ClientLoginsService.issue_text_message_token("+15105551234")

        expect(Devise.token_generator).to have_received(:generate).with(TextMessageAccessToken, :token)
        expect(result).to eq "raw_token"
      end.to change(TextMessageAccessToken, :count).by(1)
      token = TextMessageAccessToken.last
      expect(token.sms_phone_number).to eq "+15105551234"
      expect(token.token_type).to eq "link"
      expect(token.token).to eq "hashed_token"
    end
  end

  describe ".issue_text_message_verification_code" do
    before do
      allow(VerificationCodeService).to receive(:generate).with("+14155551212").and_return(["000004", "hashed_verification_code"])
      allow(Devise.token_generator).to receive(:digest).with(TextMessageAccessToken, :token, "hashed_verification_code").and_return("double_hashed_verification_code")
    end

    it "generates a new verification code and creates an access token" do
      expect(TextMessageAccessToken.count).to eq(0)
      raw_verification_code, access_token = described_class.issue_text_message_verification_code("+14155551212")
      expect(raw_verification_code).to eq "000004"
      expect(access_token).to eq(TextMessageAccessToken.last)
      expect(access_token.token_type).to eq("verification_code")
      expect(access_token.sms_phone_number).to eq "+14155551212"
      expect(Devise.token_generator).to have_received(:digest).with(TextMessageAccessToken, :token, "hashed_verification_code")
      expect(access_token.token).to eq "double_hashed_verification_code"
    end

    context "if there are already 5 live verification codes" do
      let!(:text_message_access_token_link) { create(:text_message_access_token, created_at: (1.5).days.ago, sms_phone_number: "+14155551212", token_type: "link") }
      let!(:oldest_text_message_access_token) { create(:text_message_access_token, created_at: 1.day.ago, sms_phone_number: "+14155551212", token_type: "verification_code") }
      let!(:text_message_access_tokens) { create_list(:text_message_access_token, 4, sms_phone_number: "+14155551212", token_type: "verification_code") }

      it "deletes the oldest of the existing codes" do
        described_class.issue_text_message_verification_code("+14155551212")

        expect {
          TextMessageAccessToken.find(oldest_text_message_access_token.id)
        }.to raise_error ActiveRecord::RecordNotFound
        expect(TextMessageAccessToken.find(text_message_access_token_link.id)).to eq text_message_access_token_link
      end
    end

    context "Datadog" do
      it "increments a metric when creating an access token" do
        described_class.issue_text_message_verification_code("+14155551212")
        expect(DatadogApi).to have_received(:increment).with("client_logins.verification_codes.text_message.created")
      end
    end
  end

  describe ".request_email_login" do
    before do
      create :client, intake: create(:intake, email_address: "client@example.com")
      allow(ClientLoginsService).to receive(:create_email_login)
    end

    context "with an email that matches a client" do
      let(:arguments) do
        { email_address: "client@example.com", visitor_id: "a_visitor_id", locale: "es" }
      end

      it "creates an email login" do
        ClientLoginsService.request_email_login(arguments)

        expect(ClientLoginsService).to have_received(:create_email_login).with(arguments)
      end
    end

    context "with an email that doesn't match any clients" do
      let(:arguments) do
        { email_address: "not_a_client@example.com", visitor_id: "a_visitor_id", locale: "es" }
      end

      it "sends an email to let the person know we couldn't find their email" do
        expect do
          ClientLoginsService.request_email_login(arguments)
        end.to have_enqueued_mail(ClientLoginRequestMailer, :no_match_found).with(
          a_hash_including(params: { locale: "es", to: "not_a_client@example.com" })
        )
      end
    end
  end

  describe ".request_text_message_login" do
    let(:arguments) do
      { sms_phone_number: "+15105551234", visitor_id: "a_visitor_id", locale: "es" }
    end

    before do
      allow(ClientLoginsService).to receive(:create_text_message_login)
      allow(TwilioService).to receive(:send_text_message)
    end

    context "with a matching client" do
      before { create :client, intake: create(:intake, sms_phone_number: "+15105551234") }

      it "creates an text message login" do
        ClientLoginsService.request_text_message_login(arguments)

        expect(ClientLoginsService).to have_received(:create_text_message_login).with(arguments)
      end
    end

    context "with a client who matches on phone_number but not sms_phone_number" do
      let!(:client) { create :client, intake: create(:intake, phone_number: "+15105551234") }

      xit "adds a note to the client's profile and marks them as needing attention" do
        expect do
          ClientLoginsService.request_text_message_login(arguments)
        end.to change{ client.system_notes.count }.by(1)
        expected_note_body = <<~NOTE
          This client requested a text message login link, but their phone number is not designated for text messages.
        NOTE
        note = client.system_notes.last
        expect(note).body to eq expected_note_body
        # how to mark as an incoming interaction?
      end
    end

    context "without a matching client" do
      it "sends an text message to let the person know we couldn't find their phone number" do
        ClientLoginsService.request_text_message_login(arguments)

        expected_message_body = <<~BODY
          Alguien intentó ingresar a GetYourRefund con este número de teléfono, pero no encontramos el número en nuestro registro. ¿Usó otro número para registrarse?
          También puede ir a http://test.host/es y seleccione “Empiece ahora” para empezar su declaración.
        BODY
        expect(TwilioService).to have_received(:send_text_message).with(
          to: "+15105551234",
          body: expected_message_body
        )
      end
    end
  end

  describe ".create_email_login" do
    let(:arguments) do
      { email_address: "galloping@majestic.horse", visitor_id: "visitor id", locale: "es" }
    end

    before do
      allow(ClientLoginsService).to receive(:issue_email_verification_code) do
        ["000004", create(:email_access_token, token: "double_hashed_verification_mode", email_address: "galloping@majestic.horse")]
      end
    end

    it "generates an email verification code and saves the login request" do
      ClientLoginsService.create_email_login(arguments)
      expect(ClientLoginsService).to have_received(:issue_email_verification_code)
      access_token = EmailAccessToken.last
      login_request = EmailLoginRequest.last
      expect(access_token.email_address).to eq "galloping@majestic.horse"
      expect(access_token.token).to eq "double_hashed_verification_mode"
      expect(login_request.email_access_token).to eq access_token
      expect(login_request.visitor_id).to eq "visitor id"
    end

    it "enqueues a login email" do
      expect do
        ClientLoginsService.create_email_login(arguments)
      end.to have_enqueued_mail(ClientLoginRequestMailer, :login_email).with(
        a_hash_including(params: { locale: "es", verification_code: "000004", to: "galloping@majestic.horse" })
      )
    end
  end

  describe ".create_text_message_login" do
    let(:arguments) { { sms_phone_number: "+15105551234", visitor_id: "visitor id", locale: "es" } }

    before do
      allow(TwilioService).to receive(:send_text_message)
      allow(ClientLoginsService).to receive(:issue_text_message_verification_code) do
        ["000004", create(:text_message_access_token, token: "double_hashed_verification_code", sms_phone_number: "+15105551234")]
      end
    end

    it "generates a text message access token and saves a text message login request" do
      ClientLoginsService.create_text_message_login(arguments)
      expect(ClientLoginsService).to have_received(:issue_text_message_verification_code)
      access_token = TextMessageAccessToken.last
      login_request = TextMessageLoginRequest.last
      expect(access_token.sms_phone_number).to eq "+15105551234"
      expect(access_token.token).to eq "double_hashed_verification_code"
      expect(login_request.text_message_access_token).to eq access_token
      expect(login_request.visitor_id).to eq "visitor id"
    end

    it "sends a text message with the verification code" do
      ClientLoginsService.create_text_message_login(arguments)

      expected_message_body = <<~TEXT.strip
        Su código de verificación de 6 dígitos para GetYourRefund es: 000004. Este código expirará en dos días.
      TEXT

      expect(TwilioService).to have_received(:send_text_message).with(
        to: "+15105551234",
        body: expected_message_body
      )
    end
  end

  describe ".clients_for_token" do
    before do
      allow(Devise.token_generator).to receive(:digest).and_return("hashed_token")
    end

    context "with a client with a matching token" do
      let!(:client) { create :client, login_token: "hashed_token" }

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client matching a TextMessageAccessToken" do
      let!(:client) { create :client }
      before do
        create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
        create(:intake, client: client, sms_phone_number: "+16505551212")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose email matches an EmailAccessToken" do
      let!(:client) { create :client }
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:intake, client: client, email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose spouse email matches an EmailAccessToken" do
      let!(:client) { create :client }
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
        create(:intake, client: client, spouse_email_address: "someone@example.com")
      end

      it "returns the client" do
        expect(described_class.clients_for_token("raw_token")).to match_array [client]
      end
    end

    context "with a client whose email is contained in a comma-separated EmailAccessToken" do
      let!(:client) { create :client }
      before do
        create(:email_access_token, token: "hashed_token", email_address: "someone@example.com,other@example.com")
        create(:intake, client: client, email_address: "someone@example.com")
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
        create(:intake, client: client, spouse_email_address: "someone@example.com")
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
  end
end
