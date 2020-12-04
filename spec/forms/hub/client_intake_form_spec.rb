require "rails_helper"

RSpec.describe Hub::ClientIntakeForm do
  describe ".save" do
    let!(:intake) {
      create :intake,
             :with_contact_info,
             :with_dependents,
             email_notification_opt_in: "yes",
             state_of_residence: "CA"
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

    context "contact preferences" do
      context "no contact method selected" do
        before do
          form_attributes[:sms_notification_opt_in] = "no"
          form_attributes[:email_notification_opt_in] = "no"
        end

        it "is invalid, with errors" do
          form = described_class.new(intake, form_attributes)
          form.valid?
          expect(form.errors[:communication_preference]).to eq ["Please choose some way for us to contact you."]
        end
      end
    end

    context "with invalid form attributes" do
      context "primary_first_name" do
        before do
          form_attributes[:primary_first_name] = nil
        end

        it "is not valid, has error" do
          form = described_class.new(intake, form_attributes)
          expect(form.valid?).to eq false
          expect(form.errors[:primary_first_name]).to eq ["Please enter your first name."]
        end
      end

      context "primary_last_name" do
        before do
          form_attributes[:primary_last_name] = nil
        end

        it "is not valid, has error" do
          form = described_class.new(intake, form_attributes)
          expect(form.valid?).to eq false
          expect(form.errors[:primary_last_name]).to eq ["Please enter your last name."]
        end
      end

      context "sms_phone_number" do
        context "when opted out of sms and number not provided" do
          before do
            form_attributes[:sms_phone_number] = nil
            form_attributes[:sms_notification_opt_in] = "no"
          end

          it "is valid" do
            form = described_class.new(intake, form_attributes)
            expect(form.valid?).to eq true
            expect(form.errors[:sms_phone_number]).to match_array([])
          end
        end

        context "when opted in to texting, but number not provided" do
          before do
            form_attributes[:sms_phone_number] = nil
            form_attributes[:sms_notification_opt_in] = "yes"
          end

          it "is not valid, has error" do
            form = described_class.new(intake, form_attributes)
            expect(form.valid?).to eq false
            expect(form.errors[:sms_phone_number]).to include "Can't be blank."
          end
        end

        context "when opted in to texting, but number is invalid" do
          before do
            form_attributes[:sms_phone_number] = "some-invalid-phone-number"
            form_attributes[:sms_notification_opt_in] = "yes"
          end

          it "is not valid, has error" do
            form = described_class.new(intake, form_attributes)
            expect(form.valid?).to eq false
            expect(form.errors[:sms_phone_number]).to eq ["Please enter a valid phone number."]
          end
        end

        context "when opted in to texting, number is valid, but improperly formatted" do
          before do
            form_attributes[:sms_phone_number] = "500-555-0006"
            form_attributes[:sms_notification_opt_in] = "yes"
          end

          it "is valid, phone is re-formatted" do
            form = described_class.new(intake, form_attributes)
            expect(form.valid?).to eq true
            expect(form.errors[:sms_phone_number]).to match_array([])
            expect(form.sms_phone_number).to eq "+15005550006"
          end
        end
      end

      context "state_of_residence" do
        context "when state_of_residence is not provided" do
          before do
            form_attributes[:state_of_residence] = ""
          end

          it "is valid" do
            expect(described_class.new(intake, form_attributes).valid?).to eq true
          end
        end

        context "when state_of_residence is not in list" do
          before do
            form_attributes[:state_of_residence] = "France"
          end

          it "adds an error to the attribute" do
            form = described_class.new(intake, form_attributes)
            form.valid?
            expect(form.errors[:state_of_residence]).to eq ["Please select a state from the list."]
          end
        end
      end

      context "email_address" do
        context "when provided but not valid" do
          before do
            form_attributes[:email_address] = "not_valid!!"
          end

          it "is not valid, has error" do
            form = described_class.new(intake, form_attributes)
            expect(form.valid?).to eq false
            expect(form.errors[:email_address]).to eq ["Please enter a valid email address."]
          end
        end

        context "when not provided" do
          before do
            form_attributes[:email_address] = nil
            form_attributes[:email_notification_opt_in] = "no"
          end

          it "is not valid" do
            expect(described_class.new(intake, form_attributes).valid?).to eq false
          end
        end
      end
    end

    context "preferred name" do
      context "when blank" do
        before do
          intake.update(preferred_name: "")
          form_attributes[:preferred_name] = nil
        end

        it "uses legal name to create preferred name" do
          described_class.new(intake, form_attributes).save
          expect(Client.last.preferred_name).to eq form_attributes[:primary_first_name] + " " + form_attributes[:primary_last_name]
        end
      end

      context "when present" do
        before do
          form_attributes[:preferred_name] = "Preferred Name"
        end

        it "uses provided name to create preferred name" do
          form = described_class.new(intake, form_attributes)
          form.save
          expect(form.errors).to be_blank
          expect(Client.last.preferred_name).to eq "Preferred Name"
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
          form = Hub::ClientIntakeForm.new(intake, form_attributes)
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
          form = Hub::ClientIntakeForm.new(intake, form_attributes)
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

      it "adds an error onto the form object for dependents_attributes" do
        form = Hub::ClientIntakeForm.new(intake, form_attributes)
        form.save
        expect(form.valid?).to be false
        expect(form.errors[:dependents_attributes]).to be_present
      end
    end

    context "removing dependents" do
      before do
        form_attributes[:dependents_attributes]["0"]["_destroy"] = "1"
      end

      it "removes the dependent marked with _destroy" do
        expect do
          form = Hub::ClientIntakeForm.new(intake, form_attributes)
          form.save
          intake.reload
        end.to change(intake.dependents, :count).by -1
      end
    end

    context "adding a dependent with blank fields" do
      before do
        form_attributes[:dependents_attributes]["1"] = {
            "id" => "",
            "first_name" => "New",
            "last_name" => "",
            "birth_date_month" => "September",
            "birth_date_day" => "4",
            "birth_date_year" => "2001"
        }
      end

      it "will show a validation message" do
        form = Hub::ClientIntakeForm.new(intake, form_attributes)
        form.save
        expect(form).not_to be_valid
        expect(form.errors).to include :dependents_attributes
        expect(form.errors[:dependents_attributes]).to eq(["Please enter the last name of each dependent."])
      end
    end
  end

  describe "#dependents_attributes" do
    context "without dependents_attributes or current dependents" do
      let(:intake) { create :intake, :filled_out, :with_contact_info }
      let(:form) { Hub::ClientIntakeForm.new(intake, { primary_first_name: "Patty" }) }
      it "returns an empty array" do
        expect(form.dependents_attributes).to eq []
      end
    end

    context "with current dependents and no dependents attributes" do
      let(:intake) { create :intake, :filled_out, :with_contact_info, dependents: [create(:dependent)] }
      let(:form) { Hub::ClientIntakeForm.new(intake, { primary_first_name: "Patty" }) }
      it "returns an empty array" do
        expect(form.dependents_attributes).to eq []
      end
    end

    context "with dependents attributes" do
      let(:intake) { create :intake, dependents: [(create :dependent)] }
      let(:form) { Hub::ClientIntakeForm.new(intake, dependents_attributes: [{ id: intake.dependents.first.id, first_name: "Paul", last_name: "Persimmon", birth_date: "2009-12-12" }]) }
      it "returns an array with dependent attributes" do
        expect(form.dependents_attributes.length).to eq 1
        expect(form.dependents_attributes.first).to have_key(:birth_date)
        expect(form.dependents_attributes.first).to have_key(:first_name)
        expect(form.dependents_attributes.first).to have_key(:id)
        expect(form.dependents_attributes.first).to have_key(:last_name)
      end
    end
  end
end
