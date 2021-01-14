require 'rails_helper'

describe TaxReturnsController do
  describe "#authorize_signature" do
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
               document_type: DocumentTypes::UnsignedForm8879.key
      end

      it "renders a template" do
        get :authorize_signature, params: params

        expect(response).to render_template("authorize_signature")
      end

      it "sets the signer as primary" do
        get :authorize_signature, params: params
        expect(assigns(:primary_signer)).to eq true
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

  describe "#spouse_authorize_signature" do
    let(:tax_return) { create :tax_return }
    let(:params) { { tax_return_id: tax_return.id } }

    before do
      allow_any_instance_of(TaxReturn).to receive(:filing_joint?).and_return true
    end

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
               document_type: DocumentTypes::UnsignedForm8879.key
      end

      it "renders a template" do
        get :spouse_authorize_signature, params: params

        expect(response).to render_template("authorize_signature")
      end

      it "sets primary_signer to be false" do
        get :spouse_authorize_signature, params: params

        expect(assigns(:primary_signer)).to eq false
      end
    end
  end

  describe "#sign" do
    let(:tax_return) { create :tax_return, client: (create :client, intake: (create :intake, filing_joint: "no")) }

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
                 document_type: DocumentTypes::UnsignedForm8879.key,
                 tax_return: tax_return,
                 client: tax_return.client,
                 upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
        }
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id } }

        it "redirects to homepage" do
          post :sign, params: params
          expect(flash[:notice]).to eq I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
          expect(response).to redirect_to root_path
        end
      end

      context "because there is no Form8879 to sign" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id }}

        it "redirects to home" do
          post :sign, params: params
          expect(flash[:notice]).to eq I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
          expect(response).to redirect_to root_path
        end
      end

      context "because the primary signature is already recorded on the tax return" do
        let(:tax_return) { create :tax_return, primary_signature: "Primary Signature", primary_signed_ip: IPAddr.new, primary_signed_at: DateTime.now }
        let(:params) { { tax_return_id: tax_return.id } }

        it "redirects to home" do
          post :sign, params: params
          expect(flash[:notice]).to eq "This tax return form cannot be signed."
          expect(response).to redirect_to root_path
        end
      end
    end

    context "client can sign the tax return" do
      let(:params) { { tax_return_id: tax_return.id, portal_primary_sign_form8879: { primary_accepts_terms: "yes", primary_confirms_identity: "yes" } } }
      let!(:document_to_sign) {
        create :document,
               document_type: DocumentTypes::UnsignedForm8879.key,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
      }

      it "sets @tax_return from the params[:tax_return_id]" do
        post :sign, params: params

        expect(assigns(:tax_return)).to eq tax_return
        expect(assigns(:form)).to be_an_instance_of Portal::PrimarySignForm8879
      end

      context "when efile terms are accepted and identity confirmed" do
        let(:params) { { tax_return_id: tax_return.id, portal_primary_sign_form8879: { primary_accepts_terms: "yes", primary_confirms_identity: "yes" } } }

        context "when form successfully saves" do
          it "redirects to success page" do
            post :sign, params: params
            expect(response).to redirect_to(tax_return_success_path(tax_return_id: tax_return.id))
          end
        end

        context "when form fails to save" do
          let(:form_double) { double }
          before do
            allow(Portal::PrimarySignForm8879).to receive(:new).and_return(form_double)
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
        let(:params) { { tax_return_id: tax_return.id, portal_primary_sign_form8879: { primary_accepts_terms: "no" } } }

        it "re-renders the page with a flash message" do
          post :sign, params: params

          expect(response).to render_template :authorize_signature
          expect(flash[:alert]).to eq "Please click the authorize checkbox to continue."
        end
      end

      context "when certification of identity is not checked" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id, portal_primary_sign_form8879: { primary_accepts_terms: "yes", primary_confirms_identity: "no" } } }

        it "re-renders the page with a flash message" do
          post :sign, params: params
          expect(response).to render_template :authorize_signature
          expect(flash[:alert]).to eq "Please confirm that you are the listed taxpayer to continue."
        end
      end
    end
  end

  describe "#spouse_sign" do
    let(:tax_return) { create :tax_return, client: (create :client, intake: (create :intake, filing_joint: "no")) }
    before do
      allow_any_instance_of(TaxReturn).to receive(:filing_joint?).and_return true
    end
    context "tax return cannot be signed" do

      context "because the signed tax return document is already created" do
        let!(:signed_document) {
          create :document,
                 document_type: DocumentTypes::CompletedForm8879.key,
                 tax_return: tax_return,
                 client: tax_return.client,
                 upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
        }
        let!(:document_to_sign) {
          create :document,
                 document_type: DocumentTypes::UnsignedForm8879.key,
                 tax_return: tax_return,
                 client: tax_return.client,
                 upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")
        }
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id } }

        it "redirects to homepage" do
          post :spouse_sign, params: params
          expect(flash[:notice]).to eq I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
          expect(response).to redirect_to root_path
        end
      end

      context "because there is no Form8879 to sign" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id }}

        it "redirects to home" do
          post :spouse_sign, params: params
          expect(flash[:notice]).to eq I18n.t("controllers.tax_returns_controller.errors.cannot_sign")
          expect(response).to redirect_to root_path
        end
      end

      context "because it does not require a spouse signature" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id } }

        before do
          allow_any_instance_of(TaxReturn).to receive(:filing_joint?).and_return false
        end

        it "redirects to home" do
          post :spouse_sign, params: params
          expect(flash[:notice]).to eq "This tax return form cannot be signed."
          expect(response).to redirect_to root_path
        end
      end

      context "because the spouse signature is already recorded on the tax return" do
        let(:tax_return) { create :tax_return, spouse_signature: "Spouse Signature", spouse_signed_ip: IPAddr.new, spouse_signed_at: DateTime.now }
        let(:params) { { tax_return_id: tax_return.id } }

        it "redirects to home" do
          post :spouse_sign, params: params
          expect(flash[:notice]).to eq "This tax return form cannot be signed."
          expect(response).to redirect_to root_path
        end
      end
    end

    context "spouse can sign the tax return" do
      let(:params) { { tax_return_id: tax_return.id, portal_spouse_sign_form8879: { spouse_accepts_terms: "yes", spouse_confirms_identity: "yes" } } }

      before do
        create :document,
               document_type: DocumentTypes::UnsignedForm8879.key,
               tax_return: tax_return,
               client: tax_return.client,
               upload_path:  Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf")

        allow_any_instance_of(TaxReturn).to receive(:filing_joint?).and_return true
      end

      it "sets @tax_return from the params[:tax_return_id]" do
        post :spouse_sign, params: params

        expect(assigns(:tax_return)).to eq tax_return
        expect(assigns(:form)).to be_an_instance_of Portal::SpouseSignForm8879
      end

      context "when efile terms are accepted and identity confirmed" do
        let(:params) { { tax_return_id: tax_return.id, portal_spouse_sign_form8879: { spouse_accepts_terms: "yes", spouse_confirms_identity: "yes" } } }

        context "when form successfully saves" do
          it "redirects to success page" do
            post :spouse_sign, params: params
            expect(response).to redirect_to(tax_return_success_path(tax_return_id: tax_return.id))
          end
        end

        context "when form fails to save" do
          let(:form_double) { double }
          before do
            allow(Portal::SpouseSignForm8879).to receive(:new).and_return(form_double)
            allow(form_double).to receive(:sign).and_return false
            allow(form_double).to receive_message_chain(:errors, :keys).and_return [:transaction_failed]
          end

          it "re-renders the page with a flash message" do
            post :spouse_sign, params: params

            expect(flash[:alert]).to eq("Error signing tax return. Try again or contact support.")
            expect(response).to render_template(:authorize_signature)
          end
        end
      end

      context "when efile terms are not accepted" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id, portal_spouse_sign_form8879: { spouse_accepts_terms: "no" } } }

        it "re-renders the page with a flash message" do
          post :spouse_sign, params: params

          expect(response).to render_template :authorize_signature
          expect(flash[:alert]).to eq "Please click the authorize checkbox to continue."
        end
      end

      context "when certification of identity is not checked" do
        let(:tax_return) { create :tax_return }
        let(:params) { { tax_return_id: tax_return.id, portal_spouse_sign_form8879: { spouse_accepts_terms: "yes", spouse_confirms_identity: "no" } } }

        it "re-renders the page with a flash message" do
          post :spouse_sign, params: params
          expect(response).to render_template :authorize_signature
          expect(flash[:alert]).to eq "Please confirm that you are the listed taxpayer to continue."
        end
      end
    end
  end
end