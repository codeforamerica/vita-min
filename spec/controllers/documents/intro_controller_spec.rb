require "rails_helper"

RSpec.describe Documents::IntroController do
  render_views
  let(:attributes) { {} }
  let(:intake) { create :intake, visitor_id: "visitor_id", **attributes }
  before { sign_in intake.client }

  describe ".show?" do
    context "when there are any document_types_definitely_needed" do
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when intake.document_types_definitely_needed is empty" do
      before do
        create :document, intake: intake, document_type: DocumentTypes::Identity.key
        create :document, intake: intake, document_type: DocumentTypes::SsnItin.key
        create :document, intake: intake, document_type: DocumentTypes::Employment.key
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    context "with a set of answers on an intake" do
      let(:attributes) { { had_wages: "yes", had_retirement_income: "yes" } }

      it "shows section headers for the expected document types" do
        get :edit

        expect(response.body).to include("Employment")
        expect(response.body).to include("Retirement Income")
        expect(response.body).not_to include("Other")
      end
    end


    describe "#delete" do
      let!(:document) { create :document, intake: intake }

      let(:params) do
        { id: document.id }
      end

      it "allows client to delete their own document and records a paper trail" do
        delete :destroy, params: params

        expect(PaperTrail::Version.last.event).to eq "destroy"
        expect(PaperTrail::Version.last.whodunnit).to eq intake.client.id.to_s
        expect(PaperTrail::Version.last.item_id).to eq document.id
      end
    end

    context "when no documents are required" do
      before do
        allow(subject.class).to receive(:show?).and_return(false)
      end

      it "redirects to the overview controller" do
        get :edit
        expect(response).to redirect_to(Documents::OverviewController.to_path_helper)
      end
    end

    context "mixpanel" do
      let(:fake_tracker) { double('mixpanel tracker') }
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "sends intake_ids_uploaded event to Mixpanel" do
        get :edit

        expect(MixpanelService).to have_received(:send_event).with(
          distinct_id: intake.visitor_id,
          event_name: "intake_ids_uploaded",
          data: fake_mixpanel_data
        )

        expect(MixpanelService).to have_received(:data_from).with([intake.client, intake])
      end
    end
  end
end
