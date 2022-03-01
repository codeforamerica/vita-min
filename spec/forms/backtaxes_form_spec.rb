require "rails_helper"

RSpec.describe BacktaxesForm do
  let(:intake) { create :intake }

  describe "#save" do
    let(:valid_params) do
      {
        needs_help_2021: "yes",
        needs_help_2018: "no",
        needs_help_2019: "yes",
        needs_help_2020: "yes",
      }
    end

    it "parses & saves the correct data to the model record" do
      form = described_class.new(intake, valid_params)
      expect(form).to be_valid
      form.save
      intake.reload

      expect(intake.needs_help_2021).to eq "yes"
      expect(intake.needs_help_2020).to eq "yes"
      expect(intake.needs_help_2019).to eq "yes"
      expect(intake.needs_help_2018).to eq "no"
    end

    context "Mixpanel tracking" do
      let(:fake_tracker) { double('mixpanel tracker') }
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "sends intake_started to Mixpanel" do
        form = BacktaxesForm.new(intake, {
          needs_help_2018: "no",
          needs_help_2019: "yes",
          needs_help_2020: "yes",
          needs_help_2021: "yes",
        })
        expect(form).to be_valid
        form.save

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
