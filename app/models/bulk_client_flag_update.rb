class BulkClientFlagUpdate < ApplicationRecord
  has_one :user_notification, as: :notifiable, dependent: :destroy
  belongs_to :tax_return_selection
end