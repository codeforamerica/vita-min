require "rails_helper"

describe ClientLoginService do
  describe "#login_records_for_token" do
    before do
      allow_any_instance_of(described_class).to receive(:intakes_for_token).and_return "intakes"
      allow_any_instance_of(described_class).to receive(:clients_for_token).and_return "clients"
    end

    context "for state file" do
      subject { described_class.new(:statefile_az) }

      it "returns intake" do
        expect(subject.login_records_for_token("token")).to eq "intakes"

        expect(subject).to have_received(:intakes_for_token).with("token")
      end
    end

    context "for gyr" do
      subject { described_class.new(:gyr) }

      it "returns clients" do
        expect(subject.login_records_for_token("token")).to eq "clients"

        expect(subject).to have_received(:clients_for_token).with("token")
      end
    end

    context "for ctc" do
      subject { described_class.new(:ctc) }

      it "returns clients" do
        expect(subject.login_records_for_token("token")).to eq "clients"

        expect(subject).to have_received(:clients_for_token).with("token")
      end
    end
  end

  describe "#intakes_for_token" do
    before do
      allow(Devise.token_generator).to receive(:digest).and_return("hashed_token")
    end

    context "for state file" do
      context "with AZ intakes" do
        subject { described_class.new(:statefile_az) }

        it "returns the intake with matching phone number" do
          create :text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212"
          matching_intake = create :state_file_az_intake_after_transfer, phone_number: "+16505551212"
          create :state_file_az_intake_after_transfer, phone_number: "+15551231234"

          expect(subject.intakes_for_token("hashed_token")).to match_array [matching_intake]
        end

        it "returns the intake with matching email" do
          create :email_access_token, token: "hashed_token", email_address: "someone@example.com"
          matching_intake = create :state_file_az_intake_after_transfer, email_address: "someone@example.com"
          create :state_file_az_intake_after_transfer, email_address: "someone_else@example.com"

          expect(subject.intakes_for_token("hashed_token")).to match_array [matching_intake]
        end
      end

      context "with NY intakes" do
        subject { described_class.new(:statefile_ny) }

        it "returns the intake with matching phone number" do
          create :text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212"
          matching_intake = create :state_file_ny_intake_after_transfer, phone_number: "+16505551212"
          create :state_file_ny_intake_after_transfer, phone_number: "+15551231234"

          expect(subject.intakes_for_token("hashed_token")).to match_array [matching_intake]
        end

        it "returns the intake with matching email" do
          create :email_access_token, token: "hashed_token", email_address: "someone@example.com"
          matching_intake = create :state_file_ny_intake_after_transfer, email_address: "someone@example.com"
          create :state_file_ny_intake_after_transfer, email_address: "someone_else@example.com"

          expect(subject.intakes_for_token("hashed_token")).to match_array [matching_intake]
        end
      end


      context "with US intakes" do
        subject { described_class.new(:statefile) }

        it "returns the az intake with matching phone number" do
          create :text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212"
          matching_intake = create :state_file_az_intake_after_transfer, phone_number: "+16505551212"
          create :state_file_az_intake_after_transfer, phone_number: "+15551231234"

          expect(subject.intakes_for_token("hashed_token")).to match_array [matching_intake]
        end

        it "returns the ny intake with matching email" do
          create :email_access_token, token: "hashed_token", email_address: "someone@example.com"
          matching_intake = create :state_file_ny_intake_after_transfer, email_address: "someone@example.com"
          create :state_file_ny_intake_after_transfer, email_address: "someone_else@example.com"

          expect(subject.intakes_for_token("hashed_token")).to match_array [matching_intake]
        end
      end
    end
  end

  describe "#clients_for_token" do
    let(:service_type) { "online_intake" }
    let!(:tax_return) { build :gyr_tax_return, service_type: service_type }
    let!(:client) { create :client, tax_returns: [tax_return] }

    before do
      allow(Devise.token_generator).to receive(:digest).and_return("hashed_token")
    end

    context "service_type: :gyr" do
      subject { described_class.new(:gyr) }

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
        end

        context "with a ctc service type and ctc intake with verified contact info" do
          subject { described_class.new(:ctc) }

          before do
            create(:email_access_token, token: "hashed_token", email_address: "someone@example.com")
            create(:text_message_access_token, token: "hashed_token", sms_phone_number: "+16505551212")
            create(:ctc_intake, client: client, sms_phone_number_verified_at: Time.current, spouse_email_address: "someone@example.com", sms_phone_number: "+16505551212")
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
    let!(:client) { create :client, intake: intake, tax_returns: [tax_return] }
    let(:sms_notification_opt_in) { "yes" }
    let(:primary_consented_to_service) { "yes" }
    let(:service_type) { "online_intake" }

    context "service_type is :gyr" do
      subject { described_class.new(:gyr) }
      let(:intake) { (build :intake, sms_phone_number: phone_number, primary_consented_to_service: primary_consented_to_service, sms_notification_opt_in: sms_notification_opt_in) }
      let(:tax_return) { build :gyr_tax_return }

      context "when client phone number maps to online, consented return with sms opt in" do
        it "is true" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be true
        end
      end

      context "when a clients phone number is linked to a return that has not consented" do
        let(:primary_consented_to_service) { "unfilled" }

        it "is false" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be false
        end
      end

      context "when a client is associated to a drop off service type" do
        let(:service_type) { "drop_off" }

        it "is true" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be true
        end
      end

      context "when there are no matching intakes with that data" do
        it "is false" do
          expect(subject.can_login_by_sms_verification?("+1111111111")).to be false
        end
      end
    end

    context "service_type is :ctc" do
      subject { described_class.new(:ctc) }

      let(:intake) { (build :ctc_intake, phone_number: other_phone_number, sms_phone_number: sms_phone_number, primary_consented_to_service: primary_consented_to_service, sms_notification_opt_in: sms_notification_opt_in, sms_phone_number_verified_at: verified_at_time, navigator_has_verified_client_identity: navigator_verified) }
      let(:tax_return) { build :ctc_tax_return }
      let(:sms_phone_number) { phone_number }
      let(:other_phone_number) { nil }
      let(:verified_at_time) { Time.current }
      let(:navigator_verified) { false }

      context "when there are no matching intakes with that data" do
        it "is false" do
          expect(subject.can_login_by_sms_verification?("+1111111111")).to be false
        end
      end

      context "when there is an existing client, a ctc intake, a phone number, and sms opt in" do
        let(:other_phone_number) { phone_number }
        let(:sms_phone_number) { nil }

        it "returns false" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be false
        end
      end

      context "when there is an existing client, a ctc intake, verified sms phone number, and sms opt in" do
        it "returns true" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be true
        end
      end

      context "when there is an existing client a ctc intake and navigator verified identity" do
        let(:verified_at_time) { nil }
        let(:navigator_verified) { true }

        it "returns true" do
          expect(subject.can_login_by_sms_verification?(phone_number)).to be true
        end
      end
    end
  end

  describe ".can_login_by_sms_verification? statefile service types" do
    let(:phone_number) { "+16505551212" }

    context ":statefile_az" do
      subject { described_class.new(:statefile_az) }
      let!(:intake) { create :state_file_az_intake_after_transfer, phone_number: phone_number }

      it "returns true" do
        expect(subject.can_login_by_sms_verification?(phone_number)).to be true
      end
    end

    context ":statefile_ny" do
      subject { described_class.new(:statefile_ny) }
      let!(:intake) { create :state_file_ny_intake_after_transfer, phone_number: phone_number }

      it "returns true" do
        expect(subject.can_login_by_sms_verification?(phone_number)).to be true
      end
    end
  end

  # TODO add tests for `can_login_by_email_verification?` ?

  describe ".handle_email_request" do
    context "when service_type is :gyr" do
      subject { described_class.new(:gyr) }
      context "when there is a consented intake with matching email" do
        let(:email_address) { "mango@example.com" }
        before do
          create :client, intake: (build :intake, email_address: email_address, primary_consented_to_service: "yes"), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep, service_type: "online_intake")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a consented intake with a matching spouse email" do
        let(:email_address) { "mangospouse@example.com" }
        before do
          create :client, intake: (build :intake, spouse_email_address: email_address, primary_consented_to_service: "yes"), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep, service_type: "online_intake")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a drop off intake with a matching email" do
        let(:email_address) { "persimmion@example.com" }
        before do
          create :client, intake: (build :intake, :primary_consented, email_address: email_address), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep, service_type: "drop_off")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a drop off intake with a matching spouse email" do
        let(:email_address) { "persimmion@example.com" }
        before do
          create :client, intake: (build :intake, :primary_consented, spouse_email_address: email_address), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep, service_type: "drop_off")]
        end

        it "is true" do
          expect(subject.can_login_by_email_verification?(email_address)).to be true
        end
      end

      context "when there is a matching intake that has not consented to service" do
        let(:email_address) { "noconsent@example.com" }
        before do
          create :client, intake: (build :intake, spouse_email_address: email_address, primary_consented_to_service: "unfilled"), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep, service_type: "online_intake")]
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

      context "when there is an existing client a ctc intake and verified email" do
        before do
          create :ctc_intake, email_address: "something@example.com", email_address_verified_at: Time.current, client: client
        end

        it "returns true" do
          expect(subject.can_login_by_email_verification?(client.email_address)).to be true
        end
      end

      context "when there is an existing client a ctc intake and verified sms w matching email" do
        before do
          create :ctc_intake, sms_phone_number: "+15125551234", sms_phone_number_verified_at: Time.current, client: client
        end

        it "returns true" do
          expect(subject.can_login_by_email_verification?(client.email_address)).to be true
        end
      end

      context "when there is an existing client a ctc intake and verified sms w matching email" do
        before do
          create :ctc_intake, sms_phone_number: "+15125551234", navigator_has_verified_client_identity: true, client: client
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
