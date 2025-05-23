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
  has_many :faq_items, -> { order(position: :asc) }, dependent: :destroy
  acts_as_list scope: [:product_type]
  has_paper_trail on: [:create, :destroy, :update]
  default_scope { order(position: :asc) }

  has_rich_text :description_en
  has_rich_text :description_es

  enum product_type: { gyr: 0, state_file_ny: 1, state_file_az: 2, state_file_nc: 3, state_file_md: 4, state_file_nj: 5, state_file_id: 6 }, _prefix: :product_type

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
    "state_file_#{state}" if StateFile::StateInformationService::STATES_INFO.key?(state)
  end
end
