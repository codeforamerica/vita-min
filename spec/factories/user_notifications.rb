# == Schema Information
#
# Table name: user_notifications
#
#  id              :bigint           not null, primary key
#  notifiable_type :string
#  read            :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notifiable_id   :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_user_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_user_notifications_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :user_notification do
    user
    notifiable { build(:tax_return_assignment) }
  end
end
