require "rails_helper"

RSpec.describe Documents::StudentAccountStatementsController do
  let(:attributes) { {} }
  let(:intake) do
    create(
      :intake,
      intake_ticket_id: 1234,
      primary_first_name: "Henrietta",
      primary_last_name: "Huckleberry",
      spouse_first_name: "Helga",
      spouse_last_name: "Huckleberry",
      **attributes
    )
  end

  describe ".show?" do
    context "when they had a student in the family" do
      let(:attributes) { { had_student_in_family: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { had_student_in_family: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    render_views
    before do
      allow(subject).to receive(:current_intake).and_return intake
    end

    context "when everyone is a full time student" do
      let(:attributes) do
        {
          was_full_time_student: "yes",
          spouse_was_full_time_student: "yes"
        }
      end

      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "yes"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "yes"
      end

      it "shows all their names on the page" do
        get :edit

        expect(response.body).to include("Henrietta Huckleberry")
        expect(response.body).to include("Helga Huckleberry")
        expect(response.body).to include("Harriet Huckleberry")
        expect(response.body).to include("Henry Huckleberry")
      end
    end

    context "when only one household member is a full time student" do
      let(:attributes) do
        {
          was_full_time_student: "no",
          spouse_was_full_time_student: "no"
        }
      end

      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "yes"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "no"
      end

      it "only shows the one name" do
        get :edit

        expect(response.body).not_to include("Henrietta Huckleberry")
        expect(response.body).not_to include("Helga Huckleberry")
        expect(response.body).to include("Harriet Huckleberry")
        expect(response.body).not_to include("Henry Huckleberry")
      end
    end
  end
end

