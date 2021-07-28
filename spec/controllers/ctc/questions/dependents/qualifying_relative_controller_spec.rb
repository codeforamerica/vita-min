require 'rails_helper'

describe Ctc::Questions::Dependents::QualifyingRelativeController do
  let(:intake) { create :ctc_intake }
  let!(:dependent) do
    create :dependent,
           intake: intake,
           birth_date: birth_date,
           relationship: relationship,
           full_time_student: full_time_student
  end
  let(:birth_date) { Date.new(2011, 3, 5) }
  let(:full_time_student) { "no" }
  let(:relationship) { "daughter" }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
          ctc_dependents_qualifying_relative_form: {
            meets_misc_qualifying_relative_requirements: "yes"
          }
        }
      end

      it "updates the dependent and moves to the next page" do
        post :update, params: params

        expect(dependent.reload.meets_misc_qualifying_relative_requirements).to eq "yes"
      end
    end

    context "with an invalid dependent id" do
      let(:params) do
        {
          id: 'jeff',
          ctc_dependents_qualifying_relative_form: {
            meets_misc_qualifying_relative_requirements: "yes"
          }
        }
      end

      it "renders 404" do
        expect do
          post :update, params: params
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          id: dependent.id
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors.keys).to include(:meets_misc_qualifying_relative_requirements)
      end
    end
  end

  describe "#show" do
    context "dependent has a qualifying relative relationship" do
      let!(:birth_date) { 35.year.ago }
      let!(:relationship) { "aunt" }

      it "shows qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq true
      end
    end

    context "dependent is 19-23 years old and NOT a full time student" do
      let!(:birth_date) { 20.year.ago }
      let!(:full_time_student) { "no" }
      let!(:relationship) { "daughter" }

      it "shows qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq true
      end
    end

    context "dependent is 24 years old or older" do
      let!(:birth_date) { 24.year.ago }
      let!(:relationship) { "daughter" }

      it "shows qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq true
      end
    end

    context "dependent is around 22 and was a student" do
      let(:full_time_student) { "yes" }
      let!(:relationship) { "daughter" }
      let!(:birth_date) { 22.year.ago }

      it "doesn't shows qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq false
      end
    end

    context "dependent is definitely older than 24 and a fulltime student" do
      let!(:birth_date) { 30.year.ago }
      let!(:relationship) { "daughter" }
      let(:full_time_student) { "yes" }

      it "shows qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq true
      end
    end

    context "dependent is my child who is young and filed taxes with their spouse, has an ITIN/SSN, and no one else supports them" do
      let!(:birth_date) { 17.year.ago }
      let!(:relationship) { "daughter" }

      before do
        dependent.update(provided_over_half_own_support: "no", no_ssn_atin: "no", filed_joint_return: "yes")
      end

      it "shows qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq true
      end
    end

    context "dependent is my child who is young and didn't file taxes with a spouse, has an ITIN/SSN, and no one else supports them" do
      let!(:birth_date) { 17.year.ago }
      let!(:relationship) { "daughter" }

      before do
        dependent.update(provided_over_half_own_support: "no", no_ssn_atin: "no", filed_joint_return: "no")
      end

      it "does not show qualifying relative page" do
        expect(subject.class.show?(dependent)).to eq false
      end
    end
  end
end
