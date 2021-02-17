require "rails_helper"

RSpec.describe Questions::QuestionsController do
  describe "#form_navigation" do
    context "without a current intake" do
      before do
        allow(subject).to receive(:current_intake).and_return(nil)
      end

      it "uses the QuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(QuestionNavigation)
      end
    end

    context "full service intake" do
      let(:intake) { create :intake }

      before do
        allow(subject).to receive(:current_intake).and_return(intake)
      end

      it "uses the QuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(QuestionNavigation)
      end
    end

    context "eip only intake" do
      let(:eip_intake) { create :intake, :eip_only }

      before do
        allow(subject).to receive(:current_intake).and_return(eip_intake)
      end

      it "uses the QuestionNavigation" do
        expect(subject.form_navigation).to be_an_instance_of(EipOnlyNavigation)
      end
    end
  end

  describe ".to_path_helper" do
    context "with a random child controller" do
      let(:controller_class) { Documents::IdsController }

      it "returns the correct path helper" do
        expect(controller_class.to_path_helper).to eq(ids_documents_path)
      end

      context "with a specific locale" do
        before do
          allow(I18n).to receive(:locale).and_return(:es)
        end

        it "computes the route appropriate to that locale" do
          expect(controller_class.to_path_helper).to eq(ids_documents_path(locale: :es))
        end
      end
    end
  end

  describe "#next_path" do

  end

  describe '#prev_path' do
    controller(Questions::DemographicSpouseRaceController) do
      def index;end
    end

    before do
      allow(Intake).to receive(:find_by_id).and_return intake
    end

    context "opted in to demo questions" do
      let(:intake) { create :intake, demographic_questions_opt_in: "yes" }

      it "returns the previous path based on form_navigation show? question response" do
        expect(subject.prev_path).to eq Questions::DemographicPrimaryRaceController.to_path_helper
      end
    end

    context "havent opted into demo questions but end up on a deep demo question" do
      let(:intake) { create :intake, demographic_questions_opt_in: "no" }

      it "returns the previous path based on form_navigation show? question response" do
        expect(subject.prev_path).to eq Questions::DemographicQuestionsController.to_path_helper
      end
    end
  end
end
