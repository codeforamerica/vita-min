require "rails_helper"

describe Diy::LocationController do
  describe "PUT update" do
    it "sets the source, referrer, locale, and visitor_id on the form" do
      allow(I18n).to receive(:locale).and_return("en")
      cookies[:visitor_id] = "visitor-id-from-cookies"

      expect {
        put :update, params: { diy_location_form: { zip_code: "80304" } },
            session: { source: "source-from-session", referrer: "referrer-from-session" }
      }.to change { DiyIntake.count }.by(1)

      diy_intake = DiyIntake.last
      expect(diy_intake.source).to eq "source-from-session"
      expect(diy_intake.referrer).to eq "referrer-from-session"
      expect(diy_intake.locale).to eq "en"
      expect(diy_intake.visitor_id).to eq "visitor-id-from-cookies"
    end

    it "sets a diy_intake_id on the session" do
      expect {
        put :update, params: { diy_location_form: { zip_code: "80304" } }
      }.to change { DiyIntake.count }.by(1)

      diy_intake = DiyIntake.last
      expect(session[:diy_intake_id]).to eq diy_intake.id
    end
  end
end