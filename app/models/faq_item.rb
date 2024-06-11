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
class FaqItem < ApplicationRecord
  include PgSearch::Model
  self.ignored_columns = %w(searchable_data_en searchable_data_es)
  belongs_to :faq_category
  acts_as_list scope: :faq_category
  # skip paper_trial on :touch events which will create update events for skipped attributes (in this case slug)
  # might want to include this universally in a config/initializers/paper_trail.rb one day
  has_paper_trail on: [:create, :destroy, :update]
  default_scope { order(position: :asc) }

  has_rich_text :answer_en
  has_rich_text :answer_es

  pg_search_scope :search_en, against: [:answer_en, :question_en], using: { tsearch: { prefix: true, tsvector_column: 'searchable_data_en', dictionary: 'simple' } }
  pg_search_scope :search_es, against: [:answer_es, :question_es], using: { tsearch: { prefix: true, tsvector_column: 'searchable_data_es', dictionary: 'simple' } }

  after_save :update_searchable_attrs

  def question(locale)
    case locale
    when :en
      question_en
    when :es
      question_es.present? ? question_es : question_en
    end
  end

  def answer(locale)
    case locale
    when :en
      answer_en
    when :es
      answer_es.present? ? answer_es : answer_en
    end
  end

  def update_searchable_attrs
    en = question_en + " " + answer_en.to_plain_text + " " + faq_category.name_en
    es = question_es + " " + answer_es.to_plain_text + " " + faq_category.name_es
    FaqItem.where(id: id).update_all(["searchable_data_en=to_tsvector('simple', ?), searchable_data_es=to_tsvector('simple', ?)", en, es])
  end
end
