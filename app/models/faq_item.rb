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
#  index_faq_items_on_faq_category_id  (faq_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (faq_category_id => faq_categories.id)
#
class FaqItem < ApplicationRecord
  belongs_to :faq_category
  acts_as_list scope: :faq_category

  has_rich_text :answer_en
  has_rich_text :answer_es

  def question(locale)
    case locale
    when :en
      question_en
    when :es
      question_es
    end
  end

  def answer(locale)
    case locale
    when :en
      answer_en
    when :es
      answer_es
    end
  end
end
