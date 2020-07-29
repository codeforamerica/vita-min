require "rails_helper"

RSpec.describe Documents::W2sController do
  render_views

  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  before do
    allow(subject).to receive(:current_intake).and_return intake
    allow(MixpanelService).to receive(:send_event)
  end

  describe ".show?" do
    it "always returns false" do
      expect(subject.class.show?(intake)).to eq false
    end
  end

  describe "#edit" do
    let(:attributes) { { had_wages: "yes" } }
    context "with existing W-2 uploads" do
      it "assigns the documents to the form" do
        w2_doc = create :document, :with_upload, document_type: "W-2", intake: intake
        _other_doc = create :document, :with_upload, document_type: "Other", intake: intake

        get :edit

        expect(assigns(:documents)).to eq [w2_doc]
      end
    end

    context "with a non-image document" do
      let(:document_path) { Rails.root.join("spec", "fixtures", "attachments", "document_bundle.pdf") }

      it "renders the thumbnails" do
        w2_doc = create :document, :with_upload, document_type: "W-2", intake: intake,
          upload_path: document_path

        expect { get :edit }.not_to raise_error
        expect(response.body).to include('document_bundle.pdf')
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:valid_params) do
        {
          document_type_upload_form: {
            document: fixture_file_upload("attachments/test-pattern.png", "image/png")
          }
        }
      end

      before do
        allow(subject).to receive(:send_mixpanel_event).and_return(true)
      end

      it "appends the W-2 documents to the intake and redirects to :edit" do
        expect{
          post :update, params: valid_params
        }.to change(intake.documents, :count).by 1

        latest_doc = intake.documents.last
        expect(latest_doc.document_type).to eq "W-2"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"

        expect(response).to redirect_to w2s_documents_path
      end

      it "sends the document type to mixpanel" do
        post :update, params: valid_params

        expect(subject).to have_received(:send_mixpanel_event).with(
          event_name: "document_uploaded",
          data: {
            document_type: "W-2",
            file_extension: ".png",
            file_content_type: "image/png"
          })
      end
    end

    context "with a nil document" do
      let(:params) do
        {
          document_type_upload_form: {}
        }
      end

      it "redirects back to the W2s page" do
        expect do
          post :update, params: params
        end.not_to raise_error
        expect(response).to redirect_to w2s_documents_path
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          document_type_upload_form: {
            document: fixture_file_upload("attachments/test-pattern.html")
          }
        }
      end

      it "does not upload the attachment, redirects to :edit and shows a validation error" do
        expect {
          post :update, params: invalid_params
        }.not_to change(intake.documents, :count)

        expect(response.body).to include I18n.t("validators.file_type")
        expect(response).to render_template(:edit)
      end

      it "sends the document type to mixpanel" do
        post :update, params: invalid_params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: hash_including({
            invalid_document: true
          })
        ))
      end
    end
  end
end

