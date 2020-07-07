require "rails_helper"

RSpec.describe Questions::AtCapacityController do
  render_views
  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#edit" do
    it "saves viewed_at_capacity" do
      get :edit

      expect(intake.viewed_at_capacity).to be_truthy
    end
  end

  describe "#update" do
    it "saves continued_at_capacity" do
      post :update

      expect(intake.continued_at_capacity).to be_truthy
    end
  end
end
