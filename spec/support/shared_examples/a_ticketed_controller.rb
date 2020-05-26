shared_examples "a ticketed controller" do |get_action|
  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  context "with an intake that has an intake (zendesk) ticket" do
    let(:intake) { create :intake, intake_ticket_id: 234234234 }

    it "renders normally" do
      get get_action

      expect(response).to be_ok
    end
  end

  context "with an intake that does _not_ have an intake (zendesk) ticket" do
    let(:intake) { create :intake, intake_ticket_id: nil }

    context "in production or test" do
      before { allow(Rails).to receive(:env).and_return "production".inquiry }

      it "redirects to the start of the questions workflow" do
        get get_action

        expect(response).to redirect_to(question_path(:id => QuestionNavigation.first))
      end
    end

    context "in any other environment" do
      before { allow(Rails).to receive(:env).and_return "demo".inquiry }

      it "adds a flash message to warn staff who are testing features" do
        get get_action

        expect(flash[:alert]).to match("You're missing a ticket or intake. In production, we would have redirected you to the beginning.")
      end
    end
  end

  context "with no intake at all" do
    let(:intake) { nil }

    context "in production or test" do
      before { allow(Rails).to receive(:env).and_return "production".inquiry }

      it "redirects to the start of the questions workflow" do
        get get_action

        expect(response).to redirect_to(question_path(:id => QuestionNavigation.first))
      end
    end

    context "in any other environment" do
      before { allow(Rails).to receive(:env).and_return "demo".inquiry }

      it "adds a flash message to warn staff who are testing features" do
        get get_action

        expect(flash[:alert]).to match("You're missing a ticket or intake. In production, we would have redirected you to the beginning.")
      end
    end
  end
end