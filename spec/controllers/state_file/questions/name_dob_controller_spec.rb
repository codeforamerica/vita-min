require "rails_helper"

RSpec.describe StateFile::Questions::NameDobController do
  let(:intake) { create :state_file_az_intake }
  let(:params) do
    {
      state_file_name_dob_form: {
        primary_first_name: "Jo",
        primary_last_name: "Parker",
        primary_birth_date_month: "8",
        primary_birth_date_day: "12",
        primary_birth_date_year: "1981"
      },
    }
  end

  before do
    sign_in intake
  end

  describe "#edit" do
    let(:state_file_analytics) { intake.state_file_analytics }

    context "when it is the client's first visit to this page" do
      it "saves the timestamp for the first visit" do
        expect {
          get :edit
          state_file_analytics.reload
        }.to change(state_file_analytics, :name_dob_first_visit_at)

        expect(state_file_analytics.name_dob_first_visit_at).to be_within(1.second).of(DateTime.now)
      end
    end

    context "when it is not the client's first visit to the page" do
      it "does nothing" do
        state_file_analytics.update(name_dob_first_visit_at: 1.day.ago)
        expect {
          get :edit
          state_file_analytics.reload
        }.not_to change(state_file_analytics, :name_dob_first_visit_at)
      end
    end
  end
end