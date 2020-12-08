require "rails_helper"

RSpec.describe Hub::ClientForm do
  context "validations" do
    let(:form_attributes) { {} }
    let(:form) { described_class.new(form_attributes)}
    describe "#primary_first_name" do
      before do
        form_attributes[:primary_first_name] = nil
        form.valid?
      end

      it "applies a form error" do
        expect(form.errors[:primary_first_name]).to eq ["Please enter your first name."]
      end
    end

    describe "#state_of_residence" do
      context "when not provided" do
        before do
          form_attributes[:state_of_residence] = nil
        end

        it "is not valid" do
          expect(described_class.new(form_attributes).valid?).to eq false
        end

        it "adds an error to the attribute" do
          obj = described_class.new(form_attributes)
          obj.valid?
          expect(obj.errors[:state_of_residence]).to eq ["Please select a state from the list."]
        end
      end

      context "when not in list of US States/territories" do
        before do
          form_attributes[:state_of_residence] = "France"
        end

        it "adds an error to the attribute" do
          obj = described_class.new(form_attributes)
          obj.valid?
          expect(obj.errors[:state_of_residence]).to eq ["Please select a state from the list."]
        end
      end
    end

    describe "#primary_last_name" do
      before do
        form_attributes[:primary_last_name] = nil
        form.valid?
      end

      it "applies a form error" do
        expect(form.errors[:primary_last_name]).to eq ["Please enter your last name."]
      end
    end

    describe "#phone_number" do
      context "when blank" do
        before do
          form_attributes[:phone_number] = nil
          form.valid?
        end

        it "does not apply an error" do
          expect(form.errors[:phone_number]).to be_blank
        end
      end

      context "when provided and invalid" do
        before do
          form_attributes[:phone_number] = "1"
          form.valid?
        end

        it "must be a valid phone number" do
          expect(form.errors[:phone_number]).to eq ["Please enter a valid phone number."]
        end
      end

      context "when provided and valid" do
        before do
          form_attributes[:phone_number] = "8324658840"
          form.valid?
        end

        it "does not apply an error to the field" do
          expect(form.errors[:phone_number]).to be_blank
        end

        it "formats the phone number" do
          expect(form.phone_number).to eq "+18324658840"
        end
      end
    end

    describe "#sms_phone_number" do
      context "when not sms opted in" do
        before do
          form_attributes[:sms_phone_number] = nil
          form_attributes[:sms_notification_opt_in] = "no"
          form.valid?
        end

        it "is valid" do
          expect(form.errors[:sms_phone_number]).to be_blank
        end
      end

      context "when opted in to sms notifications" do
        before do
          form_attributes[:sms_notification_opt_in] = "yes"
        end

        context "when a valid number" do
          before do
            form_attributes[:sms_phone_number] = "8324658840"
            form.valid?
          end

          it "is valid" do
            expect(form.errors[:sms_phone_number]).to be_blank
          end

          it "formats the phone number" do
            expect(form.sms_phone_number).to eq "+18324658840"
          end
        end

        context "when an invalid number" do
          before do
            form_attributes[:sms_phone_number] = "1"
            form.valid?
          end

          it "is valid" do
            expect(form.errors[:sms_phone_number]).to eq ["Please enter a valid phone number."]
          end

          it "leaves the phone number bare for editing" do
            expect(form.sms_phone_number).to eq "1"
          end
        end
      end

      describe "#email_address" do
        context "when not provided" do
          before do
            form_attributes[:email_address] = nil
            form.valid?
          end

          it "adds an error to the attribute" do
            expect(form.errors[:email_address]).to eq ["Can't be blank."]
          end
        end

        context "when not a valid email address" do
          before do
            form_attributes[:email_address] = "not_valid!!"
            form.valid?
          end

          it "adds an error to the attribute" do
            expect(form.errors[:email_address]).to eq ["Please enter a valid email address."]
          end
        end
      end

      describe "#preferred_interview_language" do
        context "when nil" do
          before do
            form_attributes[:preferred_interview_language] = nil
            form.valid?
          end

          it "adds an error to the field" do
            expect(form.errors[:preferred_interview_language]).to eq ["Can't be blank."]
          end
        end

        context "when blank" do
          before do
            form_attributes[:preferred_interview_language] = ""
            form.valid?
          end

          it "adds an error to the field" do
            expect(form.errors[:preferred_interview_language]).to eq ["Can't be blank."]
          end
        end
      end

      describe "at least one communication preference is required" do
        context "when neither sms or email are opted in to" do
          before do
            form_attributes[:sms_notification_opt_in] = "no"
            form_attributes[:email_notification_opt_in] = "no"
            form.valid?
          end

          it "adds an error for communication_preference" do
            expect(form.errors[:communication_preference]).to eq ["Please choose some way for us to contact you."]
          end
        end

        context "when sms is opted into but email is not" do
          before do
            form_attributes[:sms_notification_opt_in] = "yes"
            form_attributes[:email_notification_opt_in] = "no"
            form.valid?
          end

          it "is a valid field with no errors" do
            expect(form.errors[:communication_preference]).to be_blank
          end
        end

        context "when email is opted into but sms is not" do
          before do
            form_attributes[:sms_notification_opt_in] = "no"
            form_attributes[:email_notification_opt_in] = "yes"
            form.valid?
          end

          it "is a valid field with no errors" do
            expect(form.errors[:communication_preference]).to be_blank
          end
        end

        context "when both sms and email are opted into" do
          before do
            form_attributes[:sms_notification_opt_in] = "yes"
            form_attributes[:email_notification_opt_in] = "yes"
            form.valid?
          end

          it "is a valid field with no errors" do
            expect(form.errors[:communication_preference]).to be_blank
          end
        end
      end
    end
  end
end