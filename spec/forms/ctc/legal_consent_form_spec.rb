require "rails_helper"

describe Ctc::LegalConsentForm, requires_default_vita_partners: true do
  let(:intake) { create :ctc_intake }

  context "initialization with from_intake" do
    before do
      intake.update(primary_tin_type: "ssn_no_employment")
    end

    context "coercing tin_type to the correct value when ssn_no_employment" do
      it "sets ssn_no_employment to yes, and primary_tin_type to ssn" do
        form = described_class.from_intake(intake)
        expect(form.primary_tin_type).to eq "ssn"
        expect(form.ssn_no_employment).to eq "yes"
      end
    end
  end

  context "validations" do
    let(:params) {
      {
        primary_first_name: "Marty",
        primary_middle_initial: "J",
        primary_last_name: "Mango",
        primary_birth_date_year: "1963",
        primary_birth_date_month: "9",
        primary_birth_date_day: "10",
        primary_ssn: "111-22-8888",
        primary_ssn_confirmation: "111-22-8888",
        phone_number: "831-234-5678",
        primary_active_armed_forces: "yes",
        primary_tin_type: "ssn",
        agree_to_privacy_policy: "1",
        was_blind: "yes"
      }
    }
    context "when all required information is provided" do
      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when first name is not provided" do
      before do
        params[:primary_first_name] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the names contain characters outside the allowed set" do
      before do
        params[:primary_first_name] = "sunshine😍"
        params[:primary_middle_initial] = "🍩"
        params[:primary_last_name] = "rainbow🌈"
      end

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).to_not be_valid
        expect(form.errors.attribute_names).to include(:primary_first_name, :primary_middle_initial, :primary_last_name)
      end
    end

    context "when the names contain characters that can be transliterated to A-Z" do
      before do
        params[:primary_first_name] = "Josè"
      end

      it "is valid" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
      end
    end

    context "when last name is not provided" do
      before do
        params[:primary_last_name] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "middle initial" do
      context "when middle initial is not a single letter" do
        before do
          params[:primary_middle_initial] = '.'
        end

        it "is invalid" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end

      context "when middle initial is blank" do
        before do
          params[:primary_middle_initial] = ''
        end

        it "is invalid" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end

    context "when itin format is correct" do
      before do
        params[:primary_tin_type] = "itin"
        params[:primary_ssn] = "999-87-9999"
        params[:primary_ssn_confirmation] = "999-87-9999"
      end

      it "is valid" do
        expect(described_class.new(intake, params)).to be_valid
      end
    end

    context "when ssn format is not correct" do
      before do
        params[:primary_tin_type] = "ssn"
        params[:primary_ssn] = "666-99-9999"
        params[:primary_ssn_confirmation] = "666-99-9999"
      end
      it "not valid" do
        expect(described_class.new(intake, params)).to_not be_valid
      end

      context "when the ssn_no_employment checkbox is yes" do
        let(:ssn_no_employment) { "yes" }
        it "still requires ssn to be formatted correctly" do
          expect(described_class.new(intake, params)).not_to be_valid
        end
      end
    end

    context "when itin format is not correct" do
      before do
        params[:primary_tin_type] = "itin"
        params[:primary_ssn] = "900-69-0000"
        params[:primary_ssn_confirmation] = "900-69-0000"
      end

      it "it not valid" do
        expect(described_class.new(intake, params)).to_not be_valid
      end
    end

    context "when ssn does not match confirmation" do
      before do
        params[:primary_ssn_confirmation] = "222-44-8888"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when ssn is not confirmed" do
      before do
        params[:primary_ssn_confirmation] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when phone number is not valid" do
      before do
        params[:phone_number] = "not-a-phone"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when phone number is not present" do
      before do
        params[:phone_number] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is missing a number" do
      before do
        params[:primary_birth_date_month] = nil
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is not a valid date" do
      before do
        params[:primary_birth_date_month] = "14"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the birth date is less than 16 years ago" do
      before do
        birthdate = 15.years.ago
        params[:primary_birth_date_year] = birthdate.year
        params[:primary_birth_date_month] = birthdate.month
        params[:primary_birth_date_day] = birthdate.day
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when the year is in the future" do
      before do
        params[:primary_birth_date_year] = "2035"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end

    context "when they did not agree to the privacy policy" do
      before do
        params[:agree_to_privacy_policy] = "0"
      end

      it "is not valid" do
        expect(described_class.new(intake, params)).not_to be_valid
      end
    end
  end

  describe "#save" do
    let(:params) {
      {
          primary_first_name: "Marty",
          primary_middle_initial: "J",
          primary_last_name: "Mango",
          primary_birth_date_year: "1963",
          primary_birth_date_month: "9",
          primary_birth_date_day: "10",
          primary_ssn: "111-22-8888",
          primary_ssn_confirmation: "111-22-8888",
          phone_number: "831-234-5678",
          primary_active_armed_forces: "yes",
          primary_tin_type: tin_type,
          ssn_no_employment: ssn_no_employment,
          agree_to_privacy_policy: "1",
          was_blind: "yes"
      }
    }
    let(:ssn_no_employment) { "no" }
    let(:tin_type) { "itin" }

    it "saves the attributes on the intake and creates a client, 2020 tax return and efile security information" do
      form = described_class.new(intake, params)
      form.valid? # the form only transforms the phone number if it is validated before calling save
      form.save

      intake = Intake.last
      expect(intake.primary.first_name).to eq "Marty"
      expect(intake.primary.middle_initial).to eq "J"
      expect(intake.primary.last_name).to eq "Mango"
      expect(intake.primary.birth_date).to eq Date.new(1963, 9, 10)
      expect(intake.primary.ssn).to eq "111228888"
      expect(intake.phone_number).to eq "+18312345678"
      expect(intake.primary_last_four_ssn).to eq "8888"
      expect(intake.primary_active_armed_forces).to eq "yes"
      expect(intake.client).to be_present
      expect(intake.primary.tin_type).to eq "itin"
      expect(intake.type).to eq "Intake::CtcIntake"
      expect(intake.was_blind).to eq "yes"
    end

    it 'enqueues a GetPhoneMetadataJob' do
      form = described_class.new(intake, params)
      form.valid? # the form only transforms the phone number if it is validated before calling save

      expect {
        form.save
      }.to have_enqueued_job(GetPhoneMetadataJob).with(intake)
    end

    context "tin types" do
      context "when tin type is ssn" do
        let(:tin_type) { "ssn" }
        context "when the ssn_no_employment checkbox is value yes" do
          let(:ssn_no_employment) { "yes" }

          it "has a resulting tin type of ssn_no_employment" do
            form = described_class.new(intake, params)
            form.valid?
            form.save
            expect(form.intake.primary.tin_type).to eq("ssn_no_employment")
          end
        end

        context "when the ssn_no_employment checkbox value is no" do
          let(:ssn_no_employment) { "no" }

          it "has a resulting tin type of ssn" do
            form = described_class.new(intake, params)
            form.valid?
            form.save
            Intake.last.primary_tin_type = "ssn"
          end
        end
      end

      context "when tin type is not ssn" do
        let(:ssn_no_employment) { "no" }
        let(:tin_type) { "itin" }

        it "sets the tin type to itin" do
          form = described_class.new(intake, params)
          form.valid?
          form.save
          Intake.last.primary_tin_type = "itin"
        end
      end
    end
  end
end
