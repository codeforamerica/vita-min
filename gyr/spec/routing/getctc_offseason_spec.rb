require 'rails_helper'

context "GetCTC offseason spec", type: :request do
  before do
    allow_any_instance_of(Routes::CtcDomain).to receive(:matches?).and_return(true)
  end

  context "when intake is closed" do
    before do
      allow(Rails.configuration).to receive(:start_of_unique_links_only_intake).and_return(1.minute.ago)
      allow(Rails.configuration).to receive(:start_of_open_intake).and_return(1.minute.ago)
      allow(Rails.configuration).to receive(:end_of_intake).and_return(1.minute.ago)
    end

    context "login" do
      it "does not redirect to home" do
        get "/portal/login"
        expect(response).not_to redirect_to root_path
        expect(response).to be_ok
      end
    end

    context "/login/check-verification" do
      it "does not redirect to home" do
        put "/portal/login/check-verification"
        expect(response).not_to redirect_to root_path
      end
    end

    context "/login/locked" do
      it "does not redirect to home" do
        get "/portal/login/locked"
        expect(response).not_to redirect_to root_path
        expect(response).to be_ok
      end
    end
  end
end
