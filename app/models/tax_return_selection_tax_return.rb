# == Schema Information
#
# Table name: tax_return_selection_tax_returns
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  tax_return_id           :bigint           not null
#  tax_return_selection_id :bigint           not null
#
# Indexes
#
#  index_trstr_on_tax_return_id            (tax_return_id)
#  index_trstr_on_tax_return_selection_id  (tax_return_selection_id)
#
# Foreign Keys
#
#  fk_rails_...  (tax_return_id => tax_returns.id)
#  fk_rails_...  (tax_return_selection_id => tax_return_selections.id)
#
class TaxReturnSelectionTaxReturn < ApplicationRecord
  belongs_to :tax_return
  belongs_to :tax_return_selection
end
