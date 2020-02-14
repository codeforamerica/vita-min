require "rails_helper"

RSpec.describe Questions::SsnItinsController do
  render_views

  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:user_signed_in?).and_return(true)
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    let!(:dependent_1) { create :dependent, first_name: "Vera", last_name: "Vegetable", intake: intake }
    let!(:dependent_2) { create :dependent, first_name: "Victor", last_name: "Vegetable", intake: intake }

    it "renders the dependent names" do
      get :edit

      expect(response.body).to include("Vera Vegetable, Victor Vegetable")
    end
  end
end

