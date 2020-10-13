shared_examples :an_offseason_intake_page do |get_action|
  before do
    allow(Rails).to receive(:env).and_return("production".inquiry)
  end

  context "when we're redirecting because it is the off season" do

    it "redirects to home" do
      get get_action

      expect(response).to redirect_to root_path
    end
  end
end
