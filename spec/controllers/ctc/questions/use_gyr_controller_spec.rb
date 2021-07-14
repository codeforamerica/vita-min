require "rails_helper"

describe Ctc::Questions::UseGyrController do
  let(:intake) { create :ctc_intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  it_behaves_like :a_question_where_an_intake_is_required, CtcQuestionNavigation

  describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end
  end
end