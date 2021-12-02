require "rails_helper"

RSpec.describe Hub::UpdateClientForm do
  describe "#save" do
    let(:intake) {
      create :intake,
             :with_contact_info,
             :with_dependents,
             email_notification_opt_in: "yes",
             state_of_residence: "CA",
             preferred_interview_language: "es",
             spouse_ssn: "912345678",
             primary_ssn: "123456789",
             primary_tin_type: "ssn",
             spouse_tin_type: "itin"
    }
    let!(:client) {
      create :client, intake: intake
    }
    let(:form_attributes) do
      { primary_first_name: intake.primary_first_name,
        primary_last_name: intake.primary_last_name,
        preferred_name: intake.preferred_name,
        preferred_interview_language: intake.preferred_interview_language,
        married: intake.married,
        separated: intake.separated,
        widowed: intake.widowed,
        lived_with_spouse: intake.lived_with_spouse,
        divorced: intake.divorced,
        divorced_year: intake.divorced_year,
        separated_year: intake.separated_year,
        widowed_year: intake.widowed_year,
        email_address: intake.email_address,
        phone_number: intake.phone_number,
        sms_phone_number: intake.sms_phone_number,
        primary_tin_type: intake.primary_tin_type,
        spouse_tin_type: intake.spouse_tin_type,
        primary_ssn: intake.primary_ssn,
        spouse_ssn: intake.spouse_ssn,
        street_address: intake.street_address,
        city: intake.city,
        state: intake.state,
        zip_code: intake.zip_code,
        sms_notification_opt_in: intake.sms_notification_opt_in,
        email_notification_opt_in: intake.email_notification_opt_in,
        spouse_first_name: intake.spouse_first_name,
        spouse_last_name: intake.spouse_last_name,
        spouse_email_address: intake.spouse_email_address,
        filing_joint: intake.filing_joint,
        interview_timing_preference: intake.interview_timing_preference,
        timezone: intake.timezone,
        state_of_residence: intake.state_of_residence,
        dependents_attributes: {
              "0" => {
                  id: intake.dependents.first.id,
                  first_name: intake.dependents.first.first_name,
                  last_name: intake.dependents.first.last_name,
                  birth_date_month: "May",
                  birth_date_day: "9",
                  birth_date_year: "2013",
              }
          }
      }
    end

    context "updating a client" do
      context "updating spouse ssn" do
        before do
          form_attributes[:spouse_ssn] = "922334455"
        end

        it "persists valid changes to spouse ssn" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :spouse_ssn).to "922334455"
        end
      end
    end

    context "adding/updating dependents" do
      before do
        form_attributes[:dependents_attributes]["0"] = {
            id: intake.dependents.first.id,
            first_name: "Julia",
            last_name: "Childs",
            birth_date_month: "August",
            birth_date_day: "15",
            birth_date_year: "1912"
        }

        form_attributes[:dependents_attributes]["1"] = {
            id: "",
            first_name: "New",
            last_name: "Dependent",
            birth_date_month: "September",
            birth_date_day: "4",
            birth_date_year: "2001"
        }
      end

      it "updates the related dependent objects too" do
        expect do
          form = described_class.new(client, form_attributes)
          form.save
          intake.reload
        end.to change(intake.dependents, :count).by 1

        expect(intake.dependents.first.first_name).to eq "Julia"
        expect(intake.dependents.first.last_name).to eq "Childs"
        expect(intake.dependents.first.birth_date).to eq DateTime.parse("1912-08-15")

        expect(intake.dependents.last.first_name).to eq "New"
        expect(intake.dependents.last.last_name).to eq "Dependent"
        expect(intake.dependents.last.birth_date).to eq DateTime.parse("2001-09-04")
      end

      it "can add more than one dependent" do
        form_attributes[:dependents_attributes]["2"] = {
            id: "",
            first_name: "Second New",
            last_name: "Dependent",
            birth_date_month: "May",
            birth_date_day: "5",
            birth_date_year: "2007"
        }

        expect do
          form = described_class.new(client, form_attributes)
          form.save
          intake.reload
        end.to change(intake.dependents, :count).by 2
      end
    end

    context "attempting to add a dependent with empty required values" do
      before do
        form_attributes[:primary_first_name] = "Patty"
        form_attributes[:dependents_attributes]["1"] = {
            id: "",
            first_name: "New",
            last_name: "",
            birth_date_month: "",
            birth_date_day: "",
            birth_date_year: "2001"
        }
      end

      it "adds an error to any dependants that fail validations" do
        form = described_class.new(client, form_attributes)
        form.save
        expect(form.valid?).to be false
        expect(form.dependents.map { |d| d.errors.attribute_names }).to match_array([[], [:last_name, :birth_date]])
      end
    end

    context "removing dependents" do
      before do
        form_attributes[:dependents_attributes]["0"]["_destroy"] = "1"
      end

      it "removes the dependent marked with _destroy" do
        expect do
          form = described_class.new(client, form_attributes)
          form.save
          intake.reload
        end.to change(intake.dependents, :count).by -1
      end
    end

    context "adding a dependent with blank fields" do
      before do
        form_attributes[:dependents_attributes]["1"] = {
            id: "",
            first_name: "New",
            last_name: "",
            birth_date_month: "September",
            birth_date_day: "4",
            birth_date_year: "2001"
        }
      end

      it "will show a validation message" do
        form = described_class.new(client, form_attributes)
        form.save
        expect(form).not_to be_valid
        expect(form.dependents.map { |d| d.errors.attribute_names }).to match_array([[], [:last_name]])
      end
    end
  end

  describe ".from_client" do
    let(:intake) {
      create :intake,
             :with_contact_info,
             :with_dependents,
             email_notification_opt_in: "yes",
             state_of_residence: "CA",
             preferred_interview_language: "es",
             spouse_ssn: "912345678",
             primary_ssn: "123456789",
             primary_tin_type: "ssn",
             spouse_tin_type: "itin",
             timezone: "America/Chicago"
    }
    let!(:client) {
      create :client, intake: intake
    }

    it "includes non-model primary_last_four_ssn and spouse_last_four_ssn" do
      form = described_class.from_client(client)
      expect(form.spouse_last_four_ssn).to eq "5678"
      expect(form.primary_last_four_ssn).to eq "1234"
      expect(form.timezone).to eq "America/Chicago"
    end
  end
end
