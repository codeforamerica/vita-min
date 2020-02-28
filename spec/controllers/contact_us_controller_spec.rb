require 'rails_helper'

RSpec.describe ContactUsController, type: :controller do
  render_views

  describe "#new" do
    it "renders" do
      get :new
      expect(response).to be_success
      expect(response.body).to include("Contact Us")
    end
  end

  describe "#create" do
    let(:params) { }

    context "without an email" do
      it "renders an error"
    end

    context "for a new user" do
      it "creates a Zendesk user and ticket" do
      end
    end

    context "when there is already a zendesk user with that email" do
      it "creates a Zendesk ticket using the existing user" do
      end
    end

    context "with a return_path param" do
      it "redirects back to that place"
    end
  end
end
