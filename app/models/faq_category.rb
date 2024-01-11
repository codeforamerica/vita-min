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
class FaqCategory < ApplicationRecord
  has_many :faq_items, -> { order(position: :asc) }
  acts_as_list scope: [:product_type]
  has_paper_trail on: [:create, :destroy, :update]
  default_scope { order(position: :asc) }

  has_rich_text :description_en
  has_rich_text :description_es

  enum product_type: { gyr: 0, state_file_ny: 1, state_file_az: 2 }, _prefix: :product_type

  def name(locale)
    case locale
    when :en
      name_en
    when :es
      name_es.present? ? name_es : name_en
    end
  end

  def description(locale)
    case locale
    when :en
      description_en
    when :es
      description_es.present? ? description_es : description_en
    end
  end

  def self.state_to_product_type(state)
    case state
    when 'az'
      'state_file_az'
    when 'ny'
      'state_file_ny'
    end
  end
end
