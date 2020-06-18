require "rails_helper"

RSpec.describe Documents::W2sController do
  render_views

  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe ".show?" do
    context "with wages" do
      let(:attributes) { { had_wages: "yes" } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "with jobs" do
      let(:attributes) { { job_count: 2 } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "with disability benefits" do
      let(:attributes) { { had_disability_income: "yes" } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        {
          job_count: 0,
          had_wages: "no",
          had_disability_income: "unfilled"
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
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

      it "appends the W-2 documents to the intake and rerenders :edit without redirecting" do
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
  end
end

