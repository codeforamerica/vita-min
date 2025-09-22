require 'rails_helper'

RSpec.describe StateFile::AutomatedMessage::Rejected do
  let(:i18n_required_args) do
    {
      return_status_link: 'google.com',
      primary_first_name: 'Test',
      state_name: 'Arizona',
    }
  end

  let(:i18n_key) { 'messages.state_file.rejected' }

  describe "#sms_body" do
    it "should call sms_with_deadline when at or after end_of_login date" do
      Timecop.freeze(Rails.configuration.end_of_login.beginning_of_day) do
        expect(subject.sms_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.sms_with_deadline", **i18n_required_args))
      end
    end

    it "should call sms_with_deadline after end_of_login date" do
      Timecop.freeze(Rails.configuration.end_of_login + 1.day) do
        expect(subject.sms_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.sms_with_deadline", **i18n_required_args))
      end
    end

    it "should call sms before end_of_login date" do
      Timecop.freeze(Rails.configuration.end_of_login - 1.day) do
        expect(subject.sms_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.sms", **i18n_required_args))
      end
    end
  end

  describe "#email_body" do
    it "should call body_with_deadline when at or after end_of_login date" do
      Timecop.freeze(Rails.configuration.end_of_login.beginning_of_day) do
        expect(subject.email_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.email.body_with_deadline", **i18n_required_args))
      end
    end

    it "should call body_with_deadline after end_of_login date" do
      Timecop.freeze(Rails.configuration.end_of_login + 1.day) do
        expect(subject.email_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.email.body_with_deadline", **i18n_required_args))
      end
    end

    it "should call body before end_of_login date" do
      Timecop.freeze(Rails.configuration.end_of_login - 1.day) do
        expect(subject.email_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.email.body", **i18n_required_args))
      end
    end
  end

  describe "#email_subject" do
    it "should always use the same subject regardless of date" do
      Timecop.freeze(Rails.configuration.end_of_login - 1.day) do
        expect(subject.email_subject(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.email.subject", **i18n_required_args))
      end
    end

    it "should always use the same subject regardless of date (after end_of_login)" do
      Timecop.freeze(Rails.configuration.end_of_login + 1.day) do
        expect(subject.email_subject(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.email.subject", **i18n_required_args))
      end
    end
  end
end

