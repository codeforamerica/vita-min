require "rails_helper"

describe Ctc::Questions::FileFullReturnController do
  describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end
  end
end