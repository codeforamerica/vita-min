# == Schema Information
#
# Table name: df_data_import_errors
#
#  id                     :bigint           not null, primary key
#  message                :string
#  state_file_intake_type :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  state_file_intake_id   :bigint
#
# Indexes
#
#  index_df_data_import_errors_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#
class DfDataImportError < ApplicationRecord
  belongs_to :state_file_intake, polymorphic: true
end
