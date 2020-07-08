# == Schema Information
#
# Table name: anonymized_intake_csv_extracts
#
#  id           :bigint           not null, primary key
#  record_count :integer
#  run_at       :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class AnonymizedIntakeCsvExtract < ApplicationRecord
  has_one_attached :upload
end
