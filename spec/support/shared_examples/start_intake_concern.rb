require "rails_helper"

shared_examples :start_intake_concern do |intake_class:|
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
        create(intake_class.name.underscore)
      end

      before { sign_in existing_intake }

      it "replaces the existing intake in the session with a new one" do
        post :update, params: valid_params
        logged_in_intake = intake_class.find(session["warden.user.#{intake_class.name.underscore}.key"].first.first)
        expect(logged_in_intake).not_to eq existing_intake
        expect(logged_in_intake).to eq intake_class.send(:last)
      end
    end

    context "with an existing intake from another state" do
      let(:existing_intake) do
        intake_classes = StateFile::StateInformationService.state_intake_classes.excluding(StateFileNyIntake)
        other_intake_class_index = intake_classes.find_index(intake_class) - 1
        other_intake_class = intake_classes[other_intake_class_index]
        create(other_intake_class.name.underscore)
      end

      before { sign_in existing_intake }

      it "replaces the existing intake in the session with a new one" do
        post :update, params: valid_params
        logged_in_intakes = StateFile::StateInformationService.state_intake_classes.map do |klass|
          intake_id = session["warden.user.#{klass.name.underscore}.key"]&.first&.first
          intake_id.present? ? klass.find(intake_id) : nil
        end.compact
        expect(logged_in_intakes).not_to include existing_intake
        expect(logged_in_intakes).to include intake_class.send(:last)
      end
    end
  end
end