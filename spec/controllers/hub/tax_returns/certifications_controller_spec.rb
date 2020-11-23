require 'rails_helper'

RSpec.describe Hub::TaxReturns::CertificationsController do
  describe "#update" do
    let(:vita_partner) { create(:vita_partner) }
    let(:user) { create(:user_with_org, vita_partner: vita_partner) }
    let(:tax_return) { create :tax_return, client: (create :client, vita_partner: vita_partner)}
    let(:next_path) { "/next/path" }
    let(:params) { { id: tax_return.id, certification_level: "advanced", is_hsa: true, next: next_path }}

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the tax return certification level" do
        expect {
          patch :update, params: params
          tax_return.reload
        }.to change(tax_return, :certification_level).to('advanced')
      end

      it "updates the tax_return is_hsa value" do
        expect {
          patch :update, params: params
          tax_return.reload
        }.to change(tax_return, :is_hsa).to(true)
      end

      context "redirecting on success" do
        context "with next param" do
          it "redirects to referring path without params" do
            patch :update, params: params
            expect(response).to redirect_to(next_path)
          end
        end

        context "without next param" do
          let(:next_path) { nil }
          it "redirect to client show page" do
            patch :update, params: params
            expect(response).to redirect_to(hub_client_path(id: tax_return.client.id))
          end
        end

        context "with full URL next param" do
          let(:next_path) { "https://example.com/somewhere/else" }

          it "ignores next and redirects to client show page" do
            patch :update, params: params
            expect(response).to redirect_to(hub_client_path(id: tax_return.client.id))
          end
        end
      end
    end
  end
end