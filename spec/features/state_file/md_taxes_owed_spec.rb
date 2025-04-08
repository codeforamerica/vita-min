require "rails_helper"

RSpec.feature "MD Taxes Owed", active_job: true, js: true do
  let(:current_tax_year) { MultiTenantService.new(:statefile).current_tax_year }
  let(:current_year) { current_tax_year + 1 }
  let(:submission_deadline) { StateFile::StateInformationService.payment_deadline_date("md", filing_year: current_year) }

  context "before the tax deadline", :flow_explorer_screenshot do
    before do
      allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
      Timecop.travel(submission_deadline + 2.days)
    end

    it "can select a payment date up to April 15th", required_schema: "md" do
      intake = create :state_file_md_owed_intake, current_step: "state_file/taxes_owed_form"
      login_as intake, scope: :state_file_md_intake

      visit "/en/questions/md-taxes-owed"

      expect(page).to have_text strip_html_tags(I18n.t("state_file.questions.md_taxes_owed.edit.title_html", owed_amount: 8908, state_name: "Maryland"))

      expect(page).to have_text I18n.t("state_file.questions.md_taxes_owed.md_bank_details.after_deadline_default_withdrawal_info", payment_deadline_date: I18n.l(submission_deadline.to_date, format: :medium, locale: :en), payment_deadline_year: current_tax_year + 1)
      expect(page).not_to have_css(".date-select")
      expect(page).not_to have_text I18n.t("state_file.questions.md_taxes_owed.md_bank_details.date_withdraw_text", payment_deadline_date: I18n.l(submission_deadline.to_date, format: :medium, locale: :en), payment_deadline_year: current_tax_year + 1)

      fill_in I18n.t("state_file.questions.md_taxes_owed.md_bank_details.withdraw_amount", owed_amount: 8908), with: "100"

      # Payment date is hard coded after april 15th(hard coded in controller for md)
      expect(page).not_to have_css("#state_file_md_taxes_owed_form_date_electronic_withdrawal_month")
      expect(page).not_to have_css("#state_file_md_taxes_owed_form_date_electronic_withdrawal_day")
      expect(page).not_to have_css("#state_file_md_taxes_owed_form_date_electronic_withdrawal_year")

      choose I18n.t("general.bank_account.checking")
      fill_in I18n.t("state_file.questions.md_taxes_owed.md_bank_details.routing_number"), with: "019456124"
      fill_in I18n.t("state_file.questions.md_taxes_owed.md_bank_details.confirm_routing_number"), with: "019456124"
      fill_in I18n.t("state_file.questions.md_taxes_owed.md_bank_details.account_number"), with: "123456789"
      fill_in I18n.t("state_file.questions.md_taxes_owed.md_bank_details.confirm_account_number"), with: "123456789"

      click_on I18n.t("general.continue")

      # wait for next step to load for db
      expect(page).to have_current_path("/en/questions/md-had-health-insurance")
      intake.reload
      payment_date = Date.new(current_year, 4, 15)
      expect(intake.date_electronic_withdrawal).to eq payment_date
      expect(intake.payment_or_deposit_type).to eq "direct_deposit"
    end
  end
end
