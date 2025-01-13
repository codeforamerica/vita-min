require "rails_helper"
require 'axe-capybara'
require 'axe-rspec'

RSpec.feature "accessing a prior year PDF" , js: true, active_job: true do
  before do
    allow_any_instance_of(Routes::StateFileDomain).to receive(:matches?).and_return(true)
    Flipper.enable(:get_your_pdf)
  end

  it "has content" do
    visit "/"
    click_on I18n.t("state_file.state_file_pages.about_page.tax_return_link")
    fill_in I18n.t("state_file.questions.email_address.edit.email_address_label"), with: "someone@example.com"
    click_on I18n.t("state_file.questions.email_address.edit.action")
    expect(page).to have_text "We’ve sent your code to someone@example.com"
    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    code = mail.html_part.body.to_s.match(%r{<strong> (\d{6})\.</strong>})[1]
    fill_in "Enter the 6-digit code", with: code
    click_on I18n.t("state_file.archived_intakes.verification_code.edit.verify")
    expect(current_path).to eq(root_path)
  end
end
