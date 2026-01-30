require "rails_helper"

RSpec.describe EligibilityWagesForm do
  let(:intake) { Intake::GyrIntake.new }
  let(:income_level) { "1_to_69000" }
  let(:vita_income_ineligible) { "no" }
  let(:had_rental_income) { "no" }
  let(:has_crypto_income) { false }
  let(:params) do
    {
      triage_income_level: income_level,
      triage_vita_income_ineligible: vita_income_ineligible,
      had_rental_income: had_rental_income,
      has_crypto_income: has_crypto_income,
      visitor_id: "visitor_1",
      source: "source",
      referrer: "referrer",
      locale: "en"
    }
  end

  describe "validations" do
    describe '#triage_income_level' do
      context 'when params include a bad income level value' do
        let(:income_level) { "other" }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_income_level]).to be_present
        end
      end

      context "when params includes an empty value for income" do
        let(:income_level) { nil }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_income_level]).to be_present
        end
      end

      context "when params includes a valid value for income" do
        let(:income_level) { "1_to_69000" }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end

    describe "#answered_vita_income_ineligible" do
      context "when none apply is not selected and neither property nor crypto is selected" do
        let(:vita_income_ineligible) { "yes" }
        let(:had_rental_income) { "no" }
        let(:has_crypto_income) { false }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:triage_vita_income_ineligible]).to be_present
        end
      end

      context "when none apply is selected" do
        let(:vita_income_ineligible) { "no" }
        let(:had_rental_income) { "no" }
        let(:has_crypto_income) { false }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end

      context "when property income is selected" do
        let(:vita_income_ineligible) { "yes" }
        let(:had_rental_income) { "yes" }
        let(:has_crypto_income) { false }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end

      context "when crypto income is selected" do
        let(:vita_income_ineligible) { "yes" }
        let(:had_rental_income) { "no" }
        let(:has_crypto_income) { true }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end

      context "when both property and crypto income are selected" do
        let(:vita_income_ineligible) { "yes" }
        let(:had_rental_income) { "yes" }
        let(:has_crypto_income) { true }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end
  end

  describe "#save" do
    let(:valid_params) do
      {
        triage_income_level: "1_to_69000",
        triage_vita_income_ineligible: "no",
        had_rental_income: "no",
        has_crypto_income: false,
        visitor_id: "visitor_1",
        source: "source",
        referrer: "referrer",
        locale: "en"
      }
    end

    it "makes a new client and intake" do
      form = described_class.new(intake, valid_params)
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
      form = described_class.new(intake, valid_params)
      form.valid?
      form.save

      intake = Intake.last
      expect(intake.type).to eq "Intake::GyrIntake"
      expect(intake.triage_income_level).to eq "1_to_69000"
      expect(intake.triage_vita_income_ineligible).to eq "no"
      expect(intake.had_rental_income).to eq "no"
      expect(intake.has_crypto_income).to eq false
      expect(intake.visitor_id).to eq "visitor_1"
      expect(intake.source).to eq "source"
      expect(intake.referrer).to eq "referrer"
      expect(intake.locale).to eq "en"
    end

    context "when none apply is selected" do
      let(:params_none_apply) do
        valid_params.merge(
          triage_vita_income_ineligible: "no",
          had_rental_income: "no",
          has_crypto_income: "no"
        )
      end

      it "sets all related income fields to 'no'" do
        form = described_class.new(intake, params_none_apply)
        form.valid?
        form.save

        intake = Intake.last
        expect(intake.triage_vita_income_ineligible).to eq "no"
        expect(intake.had_rental_income).to eq "no"
        expect(intake.had_rental_income_from_personal_property).to eq "no"
        expect(intake.primary_owned_or_held_any_digital_currencies).to eq "no"
        expect(intake.spouse_owned_or_held_any_digital_currencies).to eq "no"
      end
    end


    context "Mixpanel tracking" do
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "sends intake_started to Mixpanel" do
        form = described_class.new(intake, valid_params)
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
end

