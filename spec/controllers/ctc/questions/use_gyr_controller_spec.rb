require "rails_helper"

describe Ctc::Questions::UseGyrController do
  describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end
  end
end