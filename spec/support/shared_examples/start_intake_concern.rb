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

    context "with existing intakes in the session" do
      let(:existing_intake) do
        create(intake_class.name.underscore)
      end
      let(:existing_oos_intake) do
        intake_classes = StateFile::StateInformationService.state_intake_classes.excluding(StateFileNyIntake)
        other_intake_class_index = intake_classes.find_index(intake_class) - 1
        other_intake_class = intake_classes[other_intake_class_index]
        create(other_intake_class.name.underscore)
      end

      before do
        sign_in existing_intake
        sign_in existing_oos_intake
      end

      context "in production" do
        before do
          allow(Rails).to receive(:env).and_return("production".inquiry)
        end

        it "replaces the existing in-state intake and does not clear the out of state intakes" do
          post :update, params: valid_params
          logged_in_intakes = StateFile::StateInformationService.state_intake_classes.map do |klass|
            subject.send("current_#{klass.name.underscore}")
          end.compact
          expect(logged_in_intakes).not_to include existing_intake
          expect(logged_in_intakes).to include existing_oos_intake
          expect(logged_in_intakes).to include intake_class.send(:last)
        end
      end

      context "in any other environment" do
        before do
          allow(Rails).to receive(:env).and_return("demo".inquiry)
        end

        it "replaces the existing in-state intake and clears the out of state intakes" do
          post :update, params: valid_params
          logged_in_intakes = StateFile::StateInformationService.state_intake_classes.map do |klass|
            subject.send("current_#{klass.name.underscore}")
          end.compact
          expect(logged_in_intakes).not_to include existing_intake
          expect(logged_in_intakes).not_to include existing_oos_intake
          expect(logged_in_intakes).to include intake_class.send(:last)
        end
      end
    end
  end
end