require "rails_helper"

RSpec.describe DependentsController do
  let(:intake) { create :intake }
  let(:user) { create :user, intake: intake }

  before do
    allow(subject).to receive(:current_user).and_return user
  end

  describe "#index" do
    render_views

    context "with existing dependents" do
      let!(:dependent_one) { create :dependent, first_name: "Kylie", last_name: "Kiwi", birth_date: Date.new(2012, 4, 21), intake: intake}
      let!(:dependent_two) { create :dependent, first_name: "Kelly", last_name: "Kiwi", birth_date: Date.new(2012, 4, 21), intake: intake}

      it "renders information about each dependent" do
        get :index

        expect(response.body).to include "Kylie Kiwi 4/21/2012"
        expect(response.body).to include "Kelly Kiwi 4/21/2012"
      end
    end
  end

  describe "#create" do
    context "with valid params" do
      let(:params) do
        {
          dependent: {
            first_name: "Kylie",
            last_name: "Kiwi",
            dob_month: "6",
            dob_day: "15",
            dob_year: "2015",
            relationship: "Nibling",
            months_in_home: "12",
            was_student: "no",
            on_visa: "no",
            north_american_resident: "yes",
            disabled: "no",
            was_married: "no"
          }
        }
      end

      it "creates a new dependent linked to the current intake and redirects to the index" do
        expect do
          post :create, params: params
        end.to change(Dependent, :count).by 1

        expect(response).to redirect_to(dependents_path)

        dependent = Dependent.last
        expect(dependent.intake).to eq intake
        expect(dependent.first_name).to eq "Kylie"
        expect(dependent.last_name).to eq "Kiwi"
        expect(dependent.birth_date).to eq Date.new(2015, 6, 15)
        expect(dependent.relationship).to eq "Nibling"
        expect(dependent.months_in_home).to eq 12
        expect(dependent.was_student).to eq "no"
        expect(dependent.on_visa).to eq "no"
        expect(dependent.north_american_resident).to eq "yes"
        expect(dependent.disabled).to eq "no"
        expect(dependent.was_married).to eq "no"
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          dependent: {
            first_name: "Kylie",
            dob_month: "16",
            dob_day: "2",
            dob_year: "2015",
            relationship: "Nibling",
            months_in_home: "12",
            was_student: "no",
            on_visa: "no",
            north_american_resident: "yes",
            disabled: "no",
            was_married: "no"
          }
        }
      end

      xit "renders new with validation errors" do
        expect do
          post :create, params: params
        end.not_to change(Dependent, :count)

        expect(response).to render_template(:new)

        expect(response.body).to include "Please enter a valid date."
        expect(response.body).to include "Last name can't be blank."
      end
    end
  end

  xdescribe "#edit" do

  end

  xdescribe "#update" do

  end

  xdescribe "#destroy" do
    it "deletes the dependent" do
      delete :destroy
    end
  end
end
