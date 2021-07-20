require "rails_helper"

describe Ctc::Questions::RemoveSpouseController do
  let(:intake) do
    create :ctc_intake,
           spouse_first_name: "Madeline",
           spouse_middle_initial: "J",
           spouse_last_name: "Mango",
           spouse_birth_date: Date.new(1983, 5, 10),
           spouse_ssn: "111228888",
           spouse_tin_type: 'ssn',
           spouse_veteran: "no"
  end

  before do
    sign_in intake.client
  end

  it_behaves_like :a_question_where_an_intake_is_required, CtcQuestionNavigation

  describe "#edit" do
    context "there is data on the spouse" do
      it "renders edit template" do
        get :edit, params: {}
        expect(response).to render_template :edit
      end
    end

    context "there is no data on the spouse" do
      let(:intake) do
        create :ctc_intake,
               spouse_first_name: nil,
               spouse_middle_initial: nil,
               spouse_last_name: nil,
               spouse_birth_date: nil,
               spouse_ssn: nil,
               spouse_tin_type: nil,
               spouse_veteran: nil
      end

      it "redirects to filing status" do
        get :edit, params: {}

        expect(response).to redirect_to Ctc::Questions::FilingStatusController.to_path_helper
      end
    end

    context "when rendering views" do
      render_views

      it "has has a nevermind link" do
        get :edit, params: {}

        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("a[href=\"#{questions_spouse_review_path}\"]")).to be_present
      end
    end
  end

  describe "#update" do
    context "if they chose 'yes remove them'" do
      it "sets all spouse fields to nil" do
        put :update, params: {}
        expect(intake.reload.spouse_first_name).to be nil
        expect(intake.reload.spouse_birth_date).to be nil
        expect(response).to redirect_to questions_filing_status_path
      end
    end
  end
end