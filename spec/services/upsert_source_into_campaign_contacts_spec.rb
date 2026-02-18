require "rails_helper"

RSpec.describe Campaign::UpsertSourceIntoCampaignContacts do
  describe ".call" do
    subject(:call_service) do
      described_class.call(
        source: source,
        source_id: source_id,
        first_name: first_name,
        last_name: last_name,
        email: email,
        phone: phone,
        email_opt_in: email_opt_in,
        sms_opt_in: sms_opt_in,
        locale: locale,
        latest_signup_at: latest_signup_at,
        latest_gyr_intake_at: latest_gyr_intake_at
      )
    end

    let(:source) { :gyr }
    let(:source_id) { 123 }
    let(:first_name) { "NewFirst" }
    let(:last_name) { "NewLast" }
    let(:email) { "new@example.com" }
    let(:phone) { "+15551234567" }
    let(:email_opt_in) { true }
    let(:sms_opt_in) { true }
    let(:locale) { "es" }
    let(:latest_signup_at) { 1.day.ago }
    let(:latest_gyr_intake_at) { 2.days.ago }

    context "when no existing contact matches" do
      it "creates a new CampaignContact" do
        expect { call_service }.to change(CampaignContact, :count).by(1)
      end

      it "sets email/phone when present" do
        call_service
        contact = CampaignContact.last
        expect(contact.email_address).to eq("new@example.com")
        expect(contact.sms_phone_number).to eq("+15551234567")
      end

      it "updates the names" do
        contact = call_service
        expect(contact.first_name).to eq("Newfirst")
        expect(contact.last_name).to eq("Newlast")
      end

      it "sets opt-ins from incoming when contact has false/nil" do
        contact = call_service
        expect(contact.email_notification_opt_in).to eq(true)
        expect(contact.sms_notification_opt_in).to eq(true)
      end

      it "sets locale when provided" do
        contact = call_service
        expect(contact.locale).to eq("es")
      end

      it "updates latest signup and gyr_intake at" do
        contact = call_service
        expect(contact.latest_signup_at).to eq(latest_signup_at)
        expect(contact.latest_gyr_intake_at).to eq(latest_gyr_intake_at)
      end

      context "when source is :gyr" do
        let(:source) { :gyr }
        let(:source_id) { 111 }

        it "adds source_id to gyr_intake_ids (unique)" do
          contact = call_service
          expect(contact.gyr_intake_ids).to match_array([111])
          expect(contact.sign_up_ids).to be_blank.or eq([])
        end
      end

      context "when source is :signup" do
        let(:source) { :signup }
        let(:source_id) { 222 }

        it "adds source_id to sign_up_ids (unique)" do
          contact = call_service
          expect(contact.sign_up_ids).to match_array([222])
          expect(contact.gyr_intake_ids).to be_blank.or eq([])
        end
      end
    end

    context "when an existing contact matches by email" do
      let!(:existing) do
        create(
          :campaign_contact,
          email_address: "new@example.com",
          sms_phone_number: "+19998887777",
          first_name: "ExistingFirst",
          last_name: "ExistingLast",
          email_notification_opt_in: false,
          sms_notification_opt_in: true,
          locale: "en",
          gyr_intake_ids: [5],
          sign_up_ids: [9],
          state_file_intake_refs: []
        )
      end

      it "does not create a new record" do
        expect { call_service }.not_to change(CampaignContact, :count)
      end

      it "finds by email and overwrites email/phone only if incoming present" do
        contact = call_service
        expect(contact.id).to eq(existing.id)

        expect(contact.email_address).to eq("new@example.com")
        expect(contact.sms_phone_number).to eq("+15551234567")
      end

      context "when incoming email is blank" do
        let(:email) { "" }
        let(:phone) { "+19998887777" }
        let(:email_opt_in) { false }

        before do
          existing.update!(email_address: nil)
        end

        it "keeps the existing email address (nil) and does not overwrite" do
          contact = call_service
          expect(contact.email_address).to be_nil
        end
      end

      context "when incoming phone is blank" do
        let(:phone) { nil }

        it "keeps the existing phone number" do
          call_service
          contact = CampaignContact.last
          expect(contact.sms_phone_number).to eq("+19998887777")
        end
      end

      context "name selection rules" do
        context "when source is :signup" do
          let(:source) { :signup }

          it "keeps existing names when both existing and incoming are present" do
            call_service
            contact = CampaignContact.last
            expect(contact.first_name).to eq("Existingfirst")
            expect(contact.last_name).to eq("Existinglast")
          end
        end

        context "when source is :gyr" do
          let(:source) { :gyr }

          it "overwrites with incoming names when both existing and incoming are present" do
            call_service
            contact = CampaignContact.last
            expect(contact.first_name).to eq("Newfirst")
            expect(contact.last_name).to eq("Newlast")
          end
        end

        context "when incoming name is blank" do
          let(:first_name) { "" }
          let(:last_name) { nil }

          it "keeps existing names" do
            call_service
            contact = CampaignContact.last
            expect(contact.first_name).to eq("Existingfirst")
            expect(contact.last_name).to eq("Existinglast")
          end
        end

        context "when existing name is blank" do
          before do
            existing.update!(first_name: nil, last_name: "")
          end

          it "uses incoming names" do
            call_service
            contact = CampaignContact.last
            expect(contact.first_name).to eq("Newfirst")
            expect(contact.last_name).to eq("Newlast")
          end
        end
      end

      it "opt-ins once true won't get overwritten" do
        contact = call_service
        expect(contact.email_notification_opt_in).to eq(true)
        expect(contact.sms_notification_opt_in).to eq(true)
      end

      context "when incoming opt-ins are false" do
        let(:email_opt_in) { false }
        let(:sms_opt_in) { false }

        it "does not turn off existing true opt-ins" do
          existing.update!(email_notification_opt_in: true, sms_notification_opt_in: true)
          contact = call_service
          expect(contact.email_notification_opt_in).to eq(true)
          expect(contact.sms_notification_opt_in).to eq(true)
        end
      end

      context "when locale is nil" do
        let(:locale) { nil }

        it "does not overwrite existing locale" do
          contact = call_service
          expect(contact.locale).to eq("en")
        end
      end

      context "when source is :gyr" do
        let(:source) { :gyr }
        let(:source_id) { 5 }

        it "adds source_id to gyr_intake_ids without duplicating" do
          call_service
          contact = CampaignContact.last
          expect(contact.gyr_intake_ids).to match_array([5])
        end
      end

      context "when source is :signup" do
        let(:source) { :signup }
        let(:source_id) { 10 }

        it "adds source_id to sign_up_ids without duplicating" do
          call_service
          contact = CampaignContact.last
          expect(contact.sign_up_ids).to match_array([9, 10])
        end
      end
    end

    context "when matching by phone" do
      let(:source) { :gyr }
      let(:source_id) { 123 }
      let(:first_name) { "NewFirst" }
      let(:last_name) { "NewLast" }
      let(:email) { nil }
      let(:phone) { "+15551234567" }
      let(:sms_opt_in) { true }
      let(:locale) { "en" }

      let!(:existing) do
        create(
          :campaign_contact,
          email_address: nil,
          sms_phone_number: "+15551234567",
          first_name: "ExistingFirst",
          last_name: "ExistingLast",
          email_notification_opt_in: false,
          sms_notification_opt_in: false
        )
      end

      context "and email_opt_in is false" do
        let(:email_opt_in) { false }

        it "finds by sms_phone_number (only among email-less contacts) and does not create a new record" do
          expect { call_service }.not_to change(CampaignContact, :count)

          contact = call_service
          expect(contact.id).to eq(existing.id)
          expect(contact.sms_phone_number).to eq("+15551234567")
        end
      end

      context "and email_opt_in is true" do
        let(:email_opt_in) { true }

        it "does not match by phone and creates a new contact" do
          expect { call_service }.to change(CampaignContact, :count).by(1)

          contact = call_service
          expect(contact.id).not_to eq(existing.id)
          expect(contact.sms_phone_number).to eq("+15551234567")
        end
      end

      context "and the only phone match has an email" do
        let(:email_opt_in) { false }

        before do
          existing.update!(email_address: "someone@example.com")
        end

        it "does not match (because find_contact requires email_address nil) and creates a new contact" do
          expect { call_service }.to change(CampaignContact, :count).by(1)
        end
      end
    end

    context "persistence" do
      it "saves the contact (bang) and returns it" do
        call_service
        contact = CampaignContact.last
        expect(contact).to be_persisted
      end

      it "raises if save! fails" do
        allow_any_instance_of(CampaignContact).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(CampaignContact.new))
        expect { call_service }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
