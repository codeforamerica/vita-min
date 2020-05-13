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
    it "redirects to the start of the questions workflow" do
      get get_action

      expect(response).to redirect_to(question_path(QuestionNavigation.first))
    end
  end

  context "with no intake at all" do
    let(:intake) { nil }
    it "redirects to the start of the questions workflow" do
      get get_action

      expect(response).to redirect_to(question_path(QuestionNavigation.first))
    end
  end
end