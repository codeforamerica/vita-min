require 'rails_helper'

describe Ctc::W2s::MiscInfoForm do
  context "when completing the form for the first time" do
    let(:w2) { create(:w2, completed_at: nil) }

    it "saves completed_at" do
      freeze_time do
        expect {
          described_class.new(w2, {}).save
        }.to change { w2.reload.completed_at }.from(nil).to(DateTime.now)
      end
    end
  end

  context "when completing it a second time" do
    let(:w2) { create(:w2, completed_at: 1.day.ago) }

    it "does not change completed_at" do
      expect {
        described_class.new(w2, {}).save
      }.not_to change { w2.reload.completed_at }
    end
  end
end