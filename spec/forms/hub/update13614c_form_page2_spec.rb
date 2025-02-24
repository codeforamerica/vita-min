require "rails_helper"

RSpec.describe Hub::Update13614cFormPage2 do
  let(:intake) {
    build :intake,
          :with_contact_info,
          email_notification_opt_in: "yes",
          state_of_residence: "CA",
          preferred_interview_language: "en",
          primary_ssn: "123456789",
          primary_tin_type: "ssn",
          signature_method: "online",
          cv_p2_notes_comments: nil
  }
  let!(:client) { Hub::ClientsController::HubClientPresenter.new(create :client, intake: intake) }
  let(:form_attributes) do
    { had_wages: "yes",
      job_count: 1,
      had_tips: "yes",
      had_retirement_income: "no",
      had_disability_income: "yes",
      had_social_security_income: "no",
      had_unemployment_income: "yes",
      had_local_tax_refund: "no",
      had_interest_income: "no",
      cv_p2_notes_comments: "money in the banana stand"
    }
  end

  describe "#save" do
    it "persists valid changes" do
      expect do
        form = described_class.new(client, form_attributes)
        form.save
        intake.reload
      end.to change(intake, :had_wages).to "yes"

      expect(intake.job_count).to eq 1
      expect(intake.had_tips).to eq "yes"
      expect(intake.had_retirement_income).to eq "no"
      expect(intake.had_disability_income).to eq "yes"
      expect(intake.had_social_security_income).to eq "no"
      expect(intake.had_unemployment_income).to eq "yes"
      expect(intake.had_local_tax_refund).to eq "no"
      expect(intake.had_interest_income).to eq "no"
      expect(intake.cv_p2_notes_comments).to eq "money in the banana stand"
    end
  end
end
