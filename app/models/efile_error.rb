# == Schema Information
#
# Table name: efile_errors
#
#  id         :bigint           not null, primary key
#  category   :string
#  code       :string
#  expose     :boolean          default(TRUE)
#  message    :text
#  severity   :string
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EfileError < ApplicationRecord
  has_rich_text :description_en
  has_rich_text :description_es
  has_rich_text :resolution_en
  has_rich_text :resolution_es
end
