require "rails_helper"

RSpec.describe Questions::OtherStatesController do
  let(:intake) { create :intake, state_of_residence: "ND" }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    render_views

    it "displays the state that we assume the user lived in" do
      get :edit

      expect(response.body).to include "did you live or work in any other states besides North Dakota?"
    end
  end
end
