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
class InternalEmail < ApplicationRecord
  has_one :outgoing_message_status, as: :parent

  def deserialized_mail_args
    Hash[ActiveJob::Arguments.deserialize(mail_args)]
  end
end
