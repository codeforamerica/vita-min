require "rails_helper"

RSpec.describe ApplicationController do
  controller do
    def index
      head :ok
    end
  end

  describe "#include_google_analytics?" do
    it "returns false" do
      expect(subject.include_google_analytics?).to eq false
    end
  end

  describe "#set_visitor_id" do
    context "existing visitor id" do
      before do
        cookies[:visitor_id] = "123"
      end

      it "retains the existing visitor id" do
        get :index
        expect(cookies[:visitor_id]).to eq "123"
      end
    end

    context "no visitor id" do
      it "generates and sets a visitor id cookie" do
        get :index
        expect(cookies[:visitor_id]).to be_a String
        expect(cookies[:visitor_id]).to be_present
      end
    end
  end
end
