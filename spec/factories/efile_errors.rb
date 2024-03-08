# == Schema Information
#
# Table name: efile_errors
#
#  id           :bigint           not null, primary key
#  auto_cancel  :boolean          default(FALSE)
#  auto_wait    :boolean          default(FALSE)
#  category     :string
#  code         :string
#  expose       :boolean          default(FALSE)
#  message      :text
#  service_type :integer          default("unfilled"), not null
#  severity     :string
#  source       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :efile_error do

  end
end
