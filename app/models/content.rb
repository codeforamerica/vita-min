# == Schema Information
#
# Table name: contents
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  category     :string
#  is_faq       :boolean
#  name         :string
#  pathname     :string
#  subtitle_en  :text
#  subtitle_es  :text
#  title_en     :text
#  title_es     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Content < ApplicationRecord
  has_rich_text :subtitle_en
  has_rich_text :subtitle_es

  has_rich_text :body_en
  has_rich_text :body_es

  def full_pathname
    "/" + [category, pathname].join("/")
  end
end
