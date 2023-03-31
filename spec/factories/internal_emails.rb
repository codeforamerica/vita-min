# == Schema Information
#
# Table name: internal_emails
#
#  id          :bigint           not null, primary key
#  mail_args   :jsonb
#  mail_class  :string
#  mail_method :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  idx_internal_emails_mail_info  (mail_class,mail_method,mail_args)
#
FactoryBot.define do
  factory :internal_email do
    mail_class { "UserMailer" }
    mail_method { "assignment_email" }
    mail_args do
      ActiveJob::Arguments.serialize(
        assigned_user: create(:user),
        assigning_user: create(:user),
        assigned_at: 1.day.ago,
        tax_return: create(:gyr_tax_return)
      )
    end
  end
end
