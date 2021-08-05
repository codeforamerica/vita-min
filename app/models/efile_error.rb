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
  def self.pdf_generation_error
    create_or_find_by!(source: :internal, code: 'PDF-1040', message: 'Failed to generate PDF Form 1040.')
  end
end
