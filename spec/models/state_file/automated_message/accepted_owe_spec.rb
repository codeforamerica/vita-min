require 'rails_helper'

RSpec.describe StateFile::AutomatedMessage::AcceptedOwe do
  let (:i18n_required_args) do
    {
      return_status_link: 'google.com',
      primary_first_name: 'Test',
      state_name: 'Arizona',
      state_pay_taxes_link: 'google.com',
    }
  end

  let (:i18n_key) { 'messages.state_file.accepted_owe'}

  describe "#sms_body" do
    it "should call during_deadline during the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline.beginning_of_day) do
        expect(subject.sms_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.during_deadline.sms", **i18n_required_args))
      end
    end

    it "should call after_deadline after the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline + 1.day) do
        expect(subject.sms_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.after_deadline.sms", **i18n_required_args))
      end
    end

    it "should call before_deadline before the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline - 1.day) do
        expect(subject.sms_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.before_deadline.sms", **i18n_required_args))
      end
    end
  end

  describe "#email_body" do
    it "should call during_deadline during the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline.beginning_of_day) do
        expect(subject.email_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.during_deadline.email.body", **i18n_required_args))
      end
    end

    it "should call after_deadline after the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline + 1.day) do
        expect(subject.email_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.after_deadline.email.body", **i18n_required_args))
      end
    end

    it "should call before_deadline before the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline - 1.day) do
        expect(subject.email_body(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.before_deadline.email.body", **i18n_required_args))
      end
    end
  end

  describe "#email_subject" do
    it "should call during_deadline during the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline.beginning_of_day) do
        expect(subject.email_subject(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.during_deadline.email.subject", **i18n_required_args))
      end
    end

    it "should call after_deadline after the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline + 1.day) do
        expect(subject.email_subject(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.after_deadline.email.subject", **i18n_required_args))
      end
    end

    it "should call before_deadline before the tax deadline" do
      Timecop.freeze(Rails.configuration.tax_deadline - 1.day) do
        expect(subject.email_subject(**i18n_required_args)).to eql(I18n.t("#{i18n_key}.after_deadline.email.subject", **i18n_required_args))
      end
    end
  end
end
