shared_examples :a_question_where_an_intake_is_required do |question_navigator|
  context "with an anonymous client" do
    before do
      allow(subject).to receive(:current_intake).and_return nil
    end

    it "redirects to the login path" do
      get :edit, params: {}

      expect(response).to redirect_to question_navigator.first.to_path_helper
    end
  end
end