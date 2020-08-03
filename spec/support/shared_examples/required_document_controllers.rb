shared_examples :a_required_document_controller do
  context "requiring an upload" do
    render_views

    context "when they first arrive on the page" do
      it "includes a disabled button but no link to next path" do
        get :edit

        expect(response.body).to have_css("button[disabled].button--disabled")
        expect(response.body).not_to have_css("a.button--primary")
      end
    end

    context "when they have uploaded one document" do
      before do
        create :document, :with_upload, intake: intake, document_type: controller.document_type_key
      end

      it "renders a link to the next path" do
        get :edit

        expect(response.body).to have_css("a.button--primary")
        expect(response.body).not_to have_css("button[disabled].button--disabled")
      end
    end
  end
end
