require "rails_helper"

RSpec.describe Documents::Form1095asController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they purchased health insurance" do
      let(:attributes) { { bought_marketplace_health_insurance: "yes" } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { bought_marketplace_health_insurance: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end


  describe "#delete" do
    before { sign_in intake.client }
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

