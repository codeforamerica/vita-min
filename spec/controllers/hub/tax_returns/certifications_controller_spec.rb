require 'rails_helper'

RSpec.describe Hub::TaxReturns::CertificationsController do
  let(:user) { create :organization_lead_user }
  let!(:unauthorized_org_lead) { create :organization_lead_user }
  let(:intake){ create :intake, product_year: product_year, client: create(:client, :with_gyr_return, vita_partner: user.role.organization)}
  let(:product_year) { Rails.configuration.product_year }
  let(:tax_return) { intake.client.tax_returns.first }

  describe "#update" do
    let(:next_path) { "/next/path" }
    let(:params) { { id: tax_return.id, certification_level: "foreign_student", next: next_path } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the tax return certification level" do
        expect {
          patch :update, params: params
          tax_return.reload
        }.to change(tax_return, :certification_level).to('foreign_student')
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

      context "with an archived intake" do
        let(:product_year) { Rails.configuration.product_year - 1 }
        it "response is forbidden (403)" do
          patch :update, params: params
          expect(response).to be_forbidden
        end
      end
    end

    context "with an unauthorized user" do
      before do
        sign_in unauthorized_org_lead
      end

      it "is not allowed to access the page" do
        patch :update, params: params
        expect(response).to be_forbidden
      end
    end
  end
end
