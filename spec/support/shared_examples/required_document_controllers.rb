shared_examples "required documents controllers" do
  context "requiring an upload" do
    render_views

    context "when they first arrive on the page" do
      it "does not render a validation error" do
        get :edit

        expect(response.body).not_to include("This document is required.")
      end
    end

    context "when they tried to continue with no documents" do
      it "renders a validation error" do
        post :update, params: { required_document_upload_form: { next_step: true } }
        expect(response.body).to include("Please upload at least 1 document")
      end
    end
  end
end
