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
        get :edit, params: { submitted_with_no_docs: true }

        expect(response.body).to include("This document is required.")
      end
    end
  end
end