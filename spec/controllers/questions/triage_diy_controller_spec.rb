require 'rails_helper'

RSpec.describe Questions::TriageDiyController do
  describe "#edit" do
    before do
      session[:source] = "some-source"
      vita_partner = create :organization, accepts_itin_applicants: false
      create :source_parameter, code: "some-source", vita_partner: vita_partner
    end

    context "with an active skip parameter" do
      it "skips triage" do
        get :edit
        expect(response).to redirect_to('/en/questions/environment-warning')
      end
    end

    context "with an inactive skip parameter" do
      it "does not skip triage" do
        SourceParameter.last.update(active: false)
        get :edit
        expect(response).to be_ok
      end
    end
  end
end
