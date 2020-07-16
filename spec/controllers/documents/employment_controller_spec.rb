require "rails_helper"

RSpec.describe Documents::EmploymentController, type: :controller do
  let(:intake) { create :intake, intake_ticket_id: 1234 }
  render_views

  before do
    allow(controller).to receive(:current_intake).and_return intake
  end

  describe ".show?" do
    let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

    # W-2s

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

    # 1099-K & 1099-MISC

    context "when they had self employment income" do
      let(:attributes) { { had_self_employment_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for case where user has clicked no" do
      let(:attributes) do
        {
            had_disability_income: 'no',
            job_count: 0,
            had_self_employment_income: 'no',
            had_wages: 'no',
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end

    context "for case where user has not yet filled these in" do
      let(:attributes) do
        {
            had_wages: 'unfilled',
            job_count: nil,
            had_disability_income: 'unfilled',
            had_self_employment_income: 'unfilled',
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    let(:attributes) { { had_wages: "yes" } }

    context "with existing employment-related uploads" do
      it "assigns the documents to the form" do
        # legacy document types: W-2, 1099-K, 1099-MISC: these might have been created earlier
        w2_doc = create :document, :with_upload, document_type: "W-2", intake: intake
        ten99k_doc = create :document, :with_upload, document_type: "1099-K", intake: intake
        ten99_misc_doc = create :document, :with_upload, document_type: "1099-MISC", intake: intake
        # Doc type for the EmploymentController
        employment_doc = create :document, :with_upload, document_type: "Employment", intake: intake
        _other_doc = create :document, :with_upload, document_type: "Other", intake: intake

        get :edit

        expect(assigns(:documents)).to eq [w2_doc, ten99k_doc, ten99_misc_doc, employment_doc]
      end
    end

    context "with a non-image document" do
      let(:document_path) { Rails.root.join("spec", "fixtures", "attachments", "document_bundle.pdf") }

      it "renders the thumbnails" do
        w2_doc = create :document, :with_upload, document_type: "Employment", intake: intake,
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
        expect(latest_doc.document_type).to eq "Employment"
        expect(latest_doc.upload.filename).to eq "test-pattern.png"

        expect(response).to redirect_to employment_documents_path
      end

      it "sends the document type to mixpanel" do
        post :update, params: valid_params

        expect(subject).to have_received(:send_mixpanel_event).with(
          event_name: "document_uploaded",
          data: {
              document_type: "Employment",
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

      it "redirects back to the same page" do
        expect do
          post :update, params: params
        end.not_to raise_error
        expect(response).to redirect_to employment_documents_path
      end
    end
  end
end

