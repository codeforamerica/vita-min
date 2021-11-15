shared_examples :a_controller_which_is_skipped_when_vita_partner_source_param_is_present do
  let(:params) { {} } unless method_defined?(:params)

  context "with a valid source param in the session" do
    let(:source) { "validsource" }
    before do
      session[:source] = source
      allow(SourceParameter).to receive(:find_vita_partner_by_code).with(source).and_return (create :organization)
    end

    it "redirects from edit to /questions/file-with-help" do
      get :edit, params: params

      expect(response).to redirect_to file_with_help_questions_path
    end

    it "redirects from update to /questions/file-with-help" do
      post :update, params: params

      expect(response).to redirect_to file_with_help_questions_path
    end
  end
end