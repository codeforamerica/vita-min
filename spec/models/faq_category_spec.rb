# == Schema Information
#
# Table name: faq_categories
#
#  id           :bigint           not null, primary key
#  name_en      :string
#  name_es      :string
#  position     :integer
#  product_type :integer          default("gyr"), not null
#  slug         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe FaqCategory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
