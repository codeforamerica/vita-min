require "rails_helper"

describe Hub::ZipCodesController do
  let(:admin_user) { create :admin_user }

  describe "#create" do
    let(:vita_partner) { create :organization }
    let(:zip_code) { "94121" }
    let(:params) do
      {
          hub_zip_code_routing_form: {
              zip_code: zip_code
          },
          vita_partner_id: vita_partner.id
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "an authenticated admin user" do
      before do
        sign_in (create :admin_user)
      end

      it "responds with js" do
        post :create, params: params, format: :js, xhr: true
        expect(response.media_type).to eq "text/javascript"
      end

      it "does not respond with html" do
        expect { post :create, params: params }.to raise_error ActionController::UnknownFormat
      end

      context "when the code does not already exist" do
        it "creates a new source parameter" do
          expect {
            post :create, params: params, format: :js, xhr: true
          }.to change(vita_partner.serviced_zip_codes, :count).by 1
        end
      end

      context "when the code already exists" do
        before do
          create :vita_partner_zip_code, zip_code: zip_code, vita_partner: create(:organization)
        end

        it "does not make a new source parameter" do
          expect {
            post :create, params: params, format: :js, xhr: true
          }.not_to change(VitaPartnerZipCode, :count)
        end
      end
    end

    context "other user types" do
      describe "when attempting to create" do
        before do
          sign_in (create :greeter_user)
        end

        it "is not authorized" do
          post :create, params: params, format: :js, xhr: true
          expect(response.status).to eq 403
        end
      end
    end
  end

  describe "#destroy" do
    let(:vita_partner_zip_code) { create :vita_partner_zip_code, vita_partner: create(:organization), zip_code: "94121" }
    let(:id) { vita_partner_zip_code.id }
    let(:params) do
      { id: id }
    end

    before do
      sign_in admin_user
    end

    it "responds with js" do
      delete :destroy, params: params, format: :js, xhr: true
      expect(response.media_type).to eq "text/javascript"
    end

    it "does not respond with html" do
      expect { delete :destroy, params: params }.to raise_error ActionController::UnknownFormat
    end

    context "when the zip code object exists" do
      let!(:id) { vita_partner_zip_code.id }

      it "deletes the zip code object" do
        expect {
          delete :destroy, params: params, format: :js, xhr: true
        }.to change(VitaPartnerZipCode, :count).by(-1)
      end
    end
  end
end