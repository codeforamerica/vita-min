require "rails_helper"

shared_examples :start_intake_concern do
  describe "start of intake" do
    before do
      cookies.encrypted[:visitor_id] = "visitor-id"
      session[:source] = "some-source"
      session[:referrer] = "https://www.goggles.com/get-tax-refund"
    end

    let(:intake_classes) do
      {
        "ny" => StateFileNyIntake,
        "az" => StateFileAzIntake
      }
    end
    let(:intake_class) { intake_classes[valid_params[:us_state]] }

    it "stores referrer, visitor_id, and referrer onto the intake" do
      expect {
        post :update, params: valid_params
      }.to change { intake_class.count }.by 1

      intake = GlobalID.find(session[:state_file_intake])
      expect(intake).to be_present
      expect(intake.visitor_id).to eq "visitor-id"
      expect(intake.source).to eq "some-source"
      expect(intake.referrer).to eq "https://www.goggles.com/get-tax-refund"
    end

    context "with an existing intake in the session" do
      let(:existing_intake) do
        factory_key = :"state_file_#{valid_params[:us_state]}_intake"
        create(factory_key)
      end

      before { session[:state_file_intake] = existing_intake.to_global_id }

      it "replaces the existing intake in the session with a new one" do
        post :update, params: valid_params

        intake = GlobalID.find(session[:state_file_intake])
        expect(intake).not_to eq existing_intake
      end
    end
  end
end