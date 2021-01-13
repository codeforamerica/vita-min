require 'rails_helper'

describe TaxReturnsController do
  context "#authorize_signature" do
    let(:tax_return) { create :tax_return }
    let(:params) { { tax_return_id: tax_return.id } }
    context "without a tax form that is ready to sign" do
      it "redirects to root" do
        get :authorize_signature, params: params

        expect(response).to redirect_to :root
      end
    end

    context "with a tax form ready to sign" do
      before do
        create :document,
               tax_return: tax_return,
               client: tax_return.client,
               document_type: DocumentTypes::Form8879.key
      end

      it "renders a template" do
        get :authorize_signature, params: params

        expect(response).to render_template("authorize_signature")
      end
    end

    context "with an already signed tax form" do
      before do
        create :document,
               tax_return: tax_return,
               client: tax_return.client,
               document_type: DocumentTypes::CompletedForm8879.key
      end

      it "redirects to the root path" do
        get :authorize_signature, params: params

        expect(response).to redirect_to :root
      end
    end

  end

  context "#sign" do
    let(:tax_return) { create :tax_return }

    context "clients tax return cannot be signed" do
      context "because the tax_return is already signed" do
        let!(:signed_document) {
          create :document,
                 document_type: DocumentTypes::CompletedForm8879.key,
                 tax_return: tax_return,
                 client: tax_return.client,
                 upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
        }
        let!(:document_to_sign) {
          create :document,
                 document_type: DocumentTypes::Form8879.key,
                 tax_return: tax_return,
                 client: tax_return.client,
                 upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
        }
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id } }

        it "redirects to homepage" do
          post :sign, params: params
          expect(flash[:notice]).to eq I18n.t("controllers.tax_returns_controller.errors.already_signed")
          expect(response).to redirect_to root_path
        end
      end

      context "because there is no Form8879 to sign" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id }}

        it "redirects to home" do
          post :sign, params: params
          expect(flash[:notice]).to eq I18n.t("controllers.tax_returns_controller.errors.not_ready_to_sign")
          expect(response).to redirect_to root_path
        end
      end
    end

    context "client can sign the tax return" do
      let(:params) { { tax_return_id: tax_return.id, portal_sign_form8879: { primary_accepts_terms: "yes", primary_confirms_identity: "yes" } } }
      let!(:document_to_sign) {
        create :document,
               document_type: DocumentTypes::Form8879.key,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
      }

      it "sets @tax_return from the params[:tax_return_id]" do
        post :sign, params: params

        expect(assigns(:tax_return)).to eq tax_return
        expect(assigns(:form)).to be_an_instance_of Portal::SignForm8879
      end

      context "when efile terms are accepted and identity confirmed" do
        let(:params) { { tax_return_id: tax_return.id, portal_sign_form8879: { primary_accepts_terms: "yes", primary_confirms_identity: "yes" } } }

        context "when form successfully saves" do
          it "redirects to success page" do
            post :sign, params: params
            expect(response).to redirect_to(tax_return_success_path(tax_return_id: tax_return.id))
          end
        end

        context "when form fails to save" do
          let(:form_double) { double }
          before do
            allow(Portal::SignForm8879).to receive(:new).and_return(form_double)
            allow(form_double).to receive(:sign).and_return false
            allow(form_double).to receive_message_chain(:errors, :keys).and_return [:transaction_failed]
          end

          it "re-renders the page with a flash message" do
            post :sign, params: params

            expect(flash[:alert]).to eq("Error signing tax return. Try again or contact support.")
            expect(response).to render_template(:authorize_signature)
          end
        end
      end

      context "when efile terms are not accepted" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id, portal_sign_form8879: { primary_accepts_terms: "no" } } }

        it "re-renders the page with a flash message" do
          post :sign, params: params

          expect(response).to render_template :authorize_signature
          expect(flash[:alert]).to eq "Please click the authorize checkbox to continue."
        end
      end

      context "when certification of identity is not checked" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id, portal_sign_form8879: { primary_accepts_terms: "yes", primary_confirms_identity: "no" } } }

        it "re-renders the page with a flash message" do
          post :sign, params: params
          expect(response).to render_template :authorize_signature
          expect(flash[:alert]).to eq "Please confirm that you are the listed taxpayer to continue."
        end

      end
    end
  end
end