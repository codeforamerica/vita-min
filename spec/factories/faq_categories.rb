# == Schema Information
#
# Table name: faq_categories
#
#  id             :bigint           not null, primary key
#  description_en :text
#  description_es :text
#  name_en        :string
#  name_es        :string
#  position       :integer
#  product_type   :integer          default("gyr"), not null
#  slug           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
FactoryBot.define do
  factory :faq_category do
    name_en { "MyString" }
    name_es { "MyString" }
    product_type { :gyr }
    slug { name_en.parameterize(separator: '_') }
  end
end
