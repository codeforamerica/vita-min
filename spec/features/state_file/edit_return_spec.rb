require "rails_helper"

RSpec.feature "Editing a rejected intake with an auto-wait error" do
  include StateFileIntakeHelper
  let(:email_address) { "someone@example.com" }
  let(:ssn) { "111223333" }
  let(:hashed_ssn) { "hashed_ssn" }
  let(:verification_code) { "000004" }
  let(:hashed_verification_code) { "hashed_verification_code" }
  let(:double_hashed_verification_code) { "double_hashed_verification_code" }

  let!(:ny_intake) { create :state_file_ny_intake, email_address: email_address, hashed_ssn: hashed_ssn, primary_first_name: "Jerry" }
  let!(:efile_submission) {
    create :efile_submission,
           :for_state,
           :transmitted,
           data_source: ny_intake
  }
  let!(:efile_error) {
    create :efile_error,
           message: "The IRS Submission ID referenced in the State Submission Manifest must be present in the e-File database.",
           expose: true, auto_wait: true, auto_cancel: false,
           category: "Database Validation Error",
           code: "STATE-901",
           severity: "Reject",
           source: "irs",
           service_type: :state_file
  }
  let(:raw_response) do
    "<Acknowledgement>\n
        <SubmissionId>12345678901234567890</SubmissionId>\n
        <EFIN>441466</EFIN>\n
        <TaxYr>2023</TaxYr>\n
        <ExtndGovernmentCd>AZST</ExtndGovernmentCd>\n
        <SubmissionTyp>Form140</SubmissionTyp>\n
        <ExtndSubmissionCategoryCd>IND</ExtndSubmissionCategoryCd>\n
        <ElectronicPostmarkTs>2024-02-27T19:52:33.861+00:00</ElectronicPostmarkTs>\n
        <AcceptanceStatusTxt>Denied by IRS</AcceptanceStatusTxt>\n
        <ContainedAlertsInd>false</ContainedAlertsInd>\n
        <StatusDt>2024-02-27</StatusDt>\n
        <IRSSubmissionId>12345678901234567890</IRSSubmissionId>\n
        <TIN>400000001</TIN>\n
        <SubmissionValidationCompInd>true</SubmissionValidationCompInd>\n
        <ValidationErrorList errorCnt=\"1\">\n
        <ValidationErrorGrp errorId=\"1\">\n
          <DocumentId>NA</DocumentId>\n
        <ErrorCategoryCd>Database Validation Error</ErrorCategoryCd>\n
          <ErrorMessageTxt>The IRS Submission ID referenced in the State Submission Manifest must be present in the e-File database.</ErrorMessageTxt>\n
        <RuleNum>STATE-901</RuleNum>\n
          <SeverityCd>Reject</SeverityCd>\n
        </ValidationErrorGrp>\n
      </ValidationErrorList>\n
    </Acknowledgement>"
  end

  before do
    efile_submission.transition_to!(:rejected, raw_response: raw_response)
    StateFile::AfterTransitionTasksForRejectedReturnJob.perform_now(efile_submission, efile_submission.last_transition)
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    allow(SsnHashingService).to receive(:hash).with(ssn).and_return hashed_ssn
    allow(VerificationCodeService).to receive(:generate).with(anything).and_return [verification_code, hashed_verification_code]
    allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info).with(email_address, verification_code).and_return(hashed_verification_code)
  end

  scenario "edit your state return from the return status page with an auto-wait error" do
    visit "/ny/login-options"
    expect(page).to have_text "Sign in to FileYourStateTaxes"
    click_on "Sign in with email"

    expect(page).to have_text "Sign in with your email address"
    fill_in I18n.t("state_file.intake_logins.new.email_address.label"), with: email_address
    perform_enqueued_jobs do
      click_on I18n.t("state_file.questions.email_address.edit.action")
    end

    mail = ActionMailer::Base.deliveries.last
    expect(mail.html_part.body.to_s).to include("Your six-digit verification code for FileYourStateTaxes is: <strong> #{verification_code}.</strong> This code will expire after 30 minutes.")

    expect(page).to have_text "Enter the code to continue"
    fill_in "Enter the 6-digit code", with: verification_code
    click_on "Verify code"

    expect(page).to have_text "Code verified! Authentication needed to continue."
    fill_in "Enter your Social Security number or ITIN. For example, 123-45-6789.", with: ssn
    click_on "Continue"

    expect(page).to have_text "Unfortunately, your 2023 New York state tax return was rejected"
    click_on "Edit your state return"

    # goes back to the name-dob page
    expect(page).to have_text I18n.t("state_file.questions.name_dob.edit.title1")
    expect(find_field('state_file_name_dob_form_primary_first_name').value).to eq 'Jerry'

    fill_in "state_file_name_dob_form[primary_first_name]", with: "Titus"
    fill_in "state_file_name_dob_form[primary_last_name]", with: "Testerson"
    select_cfa_date "state_file_name_dob_form_primary_birth_date", Date.new(1978, 6, 21)
    click_on I18n.t("general.continue")

    expect(URI.parse(current_url).path).to eq "/en/ny/questions/ny-review"
  end
end