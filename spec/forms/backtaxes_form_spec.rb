require "rails_helper"

RSpec.describe BacktaxesForm do
  describe "#save" do
    context "Mixpanel tracking" do
      let(:fake_tracker) { double('mixpanel tracker') }
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "saves the right attributes" do
        intake = Intake::GyrIntake.new

        form = BacktaxesForm.new(intake, {
          needs_help_2018: "no",
          needs_help_2019: "yes",
          needs_help_2020: "yes",
          needs_help_2021: "yes",
          visitor_id: "visitor_1",
          source: "source",
          referrer: "referrer",
          locale: "es"
        })
        form.save

        intake.reload
        expect(intake.needs_help_2018).to eq "no"
        expect(intake.needs_help_2019).to eq "yes"
        expect(intake.needs_help_2020).to eq "yes"
        expect(intake.needs_help_2021).to eq "yes"
        expect(intake.visitor_id).to eq "visitor_1"
        expect(intake.source).to eq "source"
        expect(intake.referrer).to eq "referrer"
        expect(intake.locale).to eq "es"
      end

      it "sends intake_started to Mixpanel" do
        intake = Intake::GyrIntake.new

        form = BacktaxesForm.new(intake, {
          needs_help_2018: "no",
          needs_help_2019: "yes",
          needs_help_2020: "yes",
          needs_help_2021: "yes",
          visitor_id: "visitor_1"
        })
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
