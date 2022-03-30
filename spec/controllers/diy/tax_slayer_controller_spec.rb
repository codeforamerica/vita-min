require "rails_helper"

RSpec.describe Diy::TaxSlayerController do
  describe "#show" do
    let(:diy_intake_id) { 4 }

    before do
      session[:diy_intake_id] = diy_intake_id
    end

    context "with a diy intake id in the session" do
      it "returns 200 OK" do
        get :show

        expect(response).to be_ok
      end
    end

    context "without a valid diy intake id in the session" do
      let(:diy_intake_id) { nil }

      it "redirects to file yourself page" do
        get :show

        expect(response).to redirect_to diy_file_yourself_path
      end
    end

    context "showing specific TS links to clients with specific source params" do
      context "GYR cohort" do
        before do
          session[:source] = "2022-taxes"
        end

        it "shows the right TS link" do
          get :show

          expect(assigns(:taxslayer_link)).to eq "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2021&sidn=34092122"
        end
      end

      context "GetCTC cohort" do
        before do
          session[:source] = "taxes-2022"
        end

        it "shows the right TS link" do
          get :show

          expect(assigns(:taxslayer_link)).to eq "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2021&sidn=31096682"
        end
      end

      context "clients with no special source" do
        before do
          allow(EnvironmentCredentials).to receive(:dig).with(:tax_slayer_link).and_return "https://example.com/taxslayer"
        end

        it "shows the normal taxslayer link" do
          get :show

          expect(assigns(:taxslayer_link)).to eq "https://example.com/taxslayer"
        end
      end
    end
  end
end
