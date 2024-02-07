require "rails_helper"

shared_examples :start_intake_concern do |intake_class:, intake_factory:|
  describe "start of intake" do
    before do
      cookies.encrypted[:visitor_id] = "visitor-id"
      session[:source] = "some-source"
      session[:referrer] = "https://www.goggles.com/get-tax-refund"
    end

    it "stores referrer, visitor_id, and referrer onto the intake" do
      expect {
        post :update, params: valid_params
      }.to change { intake_class.count }.by 1
      intake = intake_class.find(session["warden.user.#{intake_class.name.underscore}.key"].first.first)
      expect(intake).to be_present
      expect(intake.visitor_id).to eq "visitor-id"
      expect(intake.source).to eq "some-source"
      expect(intake.referrer).to eq "https://www.goggles.com/get-tax-refund"
    end

    context "with an existing intake in the session" do
      let(:existing_intake) do
        create(intake_factory)
      end

      before { sign_in existing_intake }

      it "replaces the existing intake in the session with a new one" do
        post :update, params: valid_params
        intake = intake_class.find(session["warden.user.#{intake_class.name.underscore}.key"].first.first)
        expect(intake).not_to eq existing_intake
      end
    end
  end
end