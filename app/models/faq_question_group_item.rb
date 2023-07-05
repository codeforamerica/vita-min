# == Schema Information
#
# Table name: faq_question_group_items
#
#  id          :bigint           not null, primary key
#  group_name  :string
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  faq_item_id :bigint           not null
#
# Indexes
#
#  index_faq_question_group_items_on_faq_item_id  (faq_item_id)
#
# Foreign Keys
#
#  fk_rails_...  (faq_item_id => faq_items.id)
#
class FaqQuestionGroupItem < ApplicationRecord
  belongs_to :faq_item
end
