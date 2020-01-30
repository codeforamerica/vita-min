require "rails_helper"

RSpec.describe Questions::W2sController do
  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:user_signed_in?).and_return(true)
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    context "with existing W-2 uploads" do
      it "assigns the documents to the form" do
        w2_doc = create :document, document_type: "W-2", intake: intake
        _other_doc = create :document, document_type: "Other", intake: intake

        get :edit

        expect(assigns(:documents)).to eq [w2_doc]
      end
    end
  end

  describe "#update" do
    render_views

    context "with valid params" do
      let(:valid_params) do
        {
          form: {
            document: fixture_file_upload("attachments/test-pattern.png")
          }
        }
      end

      it "appends the W-2 documents to the intake and rerenders :edit without redirecting" do
        expect{
          post :update, params: valid_params
        }.to change(intake.documents, :count).by 1

        latest_doc = intake.documents.last
        expect(latest_doc.document_type).to eq "W-2"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"

        expect(response.status).to eq 200
        expect(response).to render_template :edit
      end
    end
  end
end

