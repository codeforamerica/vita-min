require "rails_helper"

RSpec.describe PersonalInfoForm do
  let(:intake) { Intake::GyrIntake.new }

  let(:valid_params) do
    {
      preferred_name: "Greta",
      birth_date_year: "1983",
      birth_date_month: "3",
      birth_date_day: "12",
      phone_number: "8286065544",
      phone_number_confirmation: "828-606-5544",
      zip_code: "94107",
    }
  end
  let(:additional_params) do
    {
      visitor_id: "visitor_1",
      source: "source",
      referrer: "referrer",
      locale: "es"
    }
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = described_class.new(intake, valid_params.merge(additional_params))

        expect(form).to be_valid
      end
    end

    context "if we're trying to .save data that cannot make it into the db (mismatch between model and form validation)" do
      it "creates neither a client nor an intake" do
        weird_params = valid_params.merge(additional_params).merge(phone_number: '0000000000', phone_number_confirmation: '0000000000')
        form = described_class.new(intake, weird_params)

        expect do
          expect do
            expect do
              form.save
            end.to raise_error(ActiveRecord::RecordInvalid)
          end.not_to change { Client.count }
        end.not_to change { Intake.count }
      end
    end

    context "required params are missing" do
      let(:invalid_params) do
        {
          preferred_name: nil,
          phone_number: "8286065544",
          phone_number_confirmation: nil,
          zip_code: nil,
        }
      end

      it "adds errors for each" do
        form = described_class.new(intake, invalid_params.merge(additional_params))

        expect(form).not_to be_valid
        expect(form.errors[:preferred_name]).to be_present
        expect(form.errors[:phone_number_confirmation]).to be_present
        expect(form.errors[:zip_code]).to be_present
      end
    end

    context "when the date is not valid" do
      let(:params) { valid_params.merge(birth_date_month: "2", birth_date_day: "31") }

      it "adds a validation error" do
        form = described_class.new(intake, params)

        expect(form).not_to be_valid
        expect(form.errors[:birth_date]).to be_present
        expect(form.errors[:birth_date]).to include "Please select a valid date"
      end
    end
  end

  describe "#save" do
    it "makes a new client and intake" do
      form = described_class.new(intake, valid_params.merge(additional_params))
      expect(form).to be_valid
      expect do
        expect do
          form.save
        end.to change(Client, :count).by(1)
      end.to change(Intake, :count).by(1)

      intake = Intake.last
      client = Client.last
      expect(client.intake).to eq(intake)
    end

    it "parses & saves the right attributes" do
      form = described_class.new(intake, valid_params.merge(additional_params))
      form.valid?
      form.save

      intake = Intake.last
      expect(intake.type).to eq "Intake::GyrIntake"
      expect(intake.preferred_name).to eq "Greta"
      expect(intake.phone_number).to eq "+18286065544"
      expect(intake.primary.birth_date).to eq Date.new(1983, 3, 12)
      expect(intake.zip_code).to eq "94107"
      expect(intake.visitor_id).to eq "visitor_1"
      expect(intake.source).to eq "source"
      expect(intake.referrer).to eq "referrer"
      expect(intake.locale).to eq "es"
    end

    context "Mixpanel tracking" do
      let(:fake_tracker) { double('mixpanel tracker') }
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "sends intake_started to Mixpanel" do
        form = PersonalInfoForm.new(intake, valid_params.merge(additional_params))
        form.valid?
        form.save

        intake = Intake.last
        expect(MixpanelService).to have_received(:send_event).with(
          distinct_id: intake.visitor_id,
          event_name: "intake_started",
          data: fake_mixpanel_data
        )

        expect(MixpanelService).to have_received(:data_from).with([intake.client, intake])
      end
    end
  end

  describe "#existing_attributes" do
    let(:populated_intake) { build :intake, phone_number: "+18286065544", primary_birth_date: Date.parse("1996-10-12") }

    it "returns a hash with the date fields populated" do
      attributes = described_class.existing_attributes(populated_intake)

      expect(attributes[:phone_number]).to eq "+18286065544"
      expect(attributes[:birth_date_year]).to eq 1996
      expect(attributes[:birth_date_month]).to eq 10
      expect(attributes[:birth_date_day]).to eq 12
    end
  end
end
