# == Schema Information
#
# Table name: faq_items
#
#  id              :bigint           not null, primary key
#  answer_en       :text
#  answer_es       :text
#  position        :integer
#  question_en     :text
#  question_es     :text
#  slug            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  faq_category_id :bigint           not null
#
# Indexes
#
#  index_faq_items_on_faq_category_id     (faq_category_id)
#  index_faq_items_on_searchable_data_en  (searchable_data_en) USING gin
#  index_faq_items_on_searchable_data_es  (searchable_data_es) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (faq_category_id => faq_categories.id)
#
require 'rails_helper'

RSpec.describe FaqItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
