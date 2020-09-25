require "rails_helper"

RSpec.describe Documents::W2sController do
  render_views

  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  before do
    allow(subject).to receive(:current_intake).and_return intake
    allow(MixpanelService).to receive(:send_event)
  end

  describe ".show?" do
    it "always returns false" do
      expect(subject.class.show?(intake)).to eq false
    end
  end
end

