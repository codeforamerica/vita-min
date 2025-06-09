require "rails_helper"

RSpec.describe Documents::SelfieInstructionsController do
  let(:attributes) { {} }
  let(:intake) { create :intake }

  before do
    sign_in intake.client
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
end
