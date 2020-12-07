require "rails_helper"

RSpec.describe Hub::CreateClientForm do
  describe "#new" do
    it "initializes with empty tax_return objects for each valid filing year" do
      expect(described_class.new.tax_returns.map(&:year)).to eq(TaxReturn.filing_years)
    end
  end

  describe "#save" do
    let(:vita_partner) { create :vita_partner }
    let(:params) do
      {
          vita_partner_id: vita_partner.id,
          primary_first_name: "New",
          primary_last_name: "Name",
          preferred_name: "Newly",
          preferred_interview_language: "es",
          married: "yes",
          separated: "no",
          widowed: "no",
          lived_with_spouse: "yes",
          divorced: "no",
          divorced_year: "",
          separated_year: "",
          widowed_year: "",
          email_address: "someone@example.com",
          phone_number: "5005550006",
          sms_phone_number: "500-555-(0006)",
          street_address: "972 Mission St.",
          city: "San Francisco",
          state: "CA",
          zip_code: "94103",
          sms_notification_opt_in: "yes",
          email_notification_opt_in: "no",
          spouse_first_name: "Newly",
          spouse_last_name: "Wed",
          spouse_email_address: "spouse@example.com",
          filing_joint: "yes",
          timezone: "America/Chicago",
          needs_help_2020: "yes",
          needs_help_2019: "yes",
          needs_help_2018: "yes",
          needs_help_2017: "no",
          state_of_residence: "CA",
          service_type: "drop_off",
          signature_method: "online",
          tax_returns_attributes: {
              "0" => {
                  year: "2020",
                  is_hsa: "1",
                  certification_level: "basic"
              },
              "1" => {
                  year: "2019",
                  is_hsa: "0",
                  certification_level: "basic"
              },
              "2" => {
                  year: "2018",
                  is_hsa: "1",
                  certification_level: "basic"
              },
              "3" => {
                  year: "2017",
                  is_hsa: "0",
                  certification_level: "advanced"
              },
          }
      }
    end

    context "with valid params and context" do
      it "creates a client" do
        expect do
          described_class.new(params).save
        end.to change(Client, :count).by 1
        client = Client.last
        expect(client.vita_partner).to eq vita_partner
      end

      it "assigns client to an instance on the form object" do
        form = described_class.new(params)
        form.save
        expect(form.client).to eq Client.last
      end

      it "creates an intake" do
        expect do
          described_class.new(params).save
        end.to change(Intake, :count).by 1
        intake = Intake.last
        expect(intake.vita_partner).to eq vita_partner
      end

      it "creates tax returns for each tax_return where _create is true" do
        expect do
          described_class.new(params).save
        end.to change(TaxReturn, :count).by 3
        tax_returns = Client.last.tax_returns
        intake = Intake.last
        expect(intake.needs_help_2020).to eq "yes"
        expect(intake.needs_help_2019).to eq "yes"
        expect(intake.needs_help_2018).to eq "yes"
        expect(intake.needs_help_2017).to eq "no"
        expect(tax_returns.map(&:year)).to eq [2020, 2019, 2018]
        expect(tax_returns.map(&:client).uniq).to eq [intake.client]
        expect(tax_returns.map(&:service_type).uniq).to eq ["drop_off"]
      end

      context "phone numbers" do
        it "normalizes phone_number and sms_phone_number" do
          described_class.new(params.update(sms_phone_number: "650-555-1212", phone_number: "(650) 555-1212")).save
          client = Client.last
          expect(client.intake.sms_phone_number).to eq "+16505551212"
          expect(client.intake.phone_number).to eq "+16505551212"
        end
      end
    end

    context "with invalid params" do
      context "vita_partner_id" do
        before do
          params[:vita_partner_id] = nil
        end

        it "is not valid" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for attribute into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:vita_partner_id]).to eq ["Can't be blank."]
        end
      end

      context "signature method" do
        before do
          params[:signature_method] = nil
        end

        it "is required" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for signature method into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:signature_method]).to include "Can't be blank."
        end
      end

      context "tax returns attributes" do
        context "when there are some blank required fields" do
          before do
            params[:tax_returns_attributes]["0"][:is_hsa] = nil
            params[:tax_returns_attributes]["0"][:certification_level] = ""
          end

          it "is not valid" do
            expect(described_class.new(params).valid?).to eq false
          end

          it "adds an error to the attribute" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:tax_returns_attributes]).to eq ["Please provide all required fields for tax returns: certification level, is HSA."]
          end
        end
      end

      context "when no tax return years are selected for prep" do
        before do
          params[:needs_help_2017] = "no"
          params[:needs_help_2018] = "no"
          params[:needs_help_2019] = "no"
          params[:needs_help_2020] = "no"
        end

        it "is not valid" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes an error" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:tax_returns_attributes]).to include "Please pick at least one year."
        end
      end
    end
  end
end
