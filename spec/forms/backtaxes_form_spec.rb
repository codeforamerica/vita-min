require "rails_helper"

RSpec.describe BacktaxesForm do
  describe "#save" do
    it "makes a new client with tax returns for each year they need" do
      intake = Intake::GyrIntake.new
      form = BacktaxesForm.new(intake, {
        visitor_id: "some_visitor_id",
        needs_help_2017: "yes",
        needs_help_2018: "no",
        needs_help_2019: "yes",
        needs_help_2020: "yes",
      })
      expect {
        form.save
      }.to change(Client, :count).by(1)
      client = Client.last
      expect(client.intake).to eq(intake.reload)
      expect(client.tax_returns.map(&:year).sort).to eq([2017, 2019, 2020])
      expect(client.tax_returns.map(&:service_type).uniq).to eq ["online_intake"]
    end

    context "Mixpanel tracking" do
      let(:fake_tracker) { double('mixpanel tracker') }
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "sends intake_started to Mixpanel" do
        intake = Intake::GyrIntake.new

        form = BacktaxesForm.new(intake, {
          needs_help_2017: "yes",
          needs_help_2018: "no",
          needs_help_2019: "yes",
          needs_help_2020: "yes",
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
