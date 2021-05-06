# == Schema Information
#
# Table name: tax_return_selections
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TaxReturnSelection < ApplicationRecord
  has_many :tax_return_selection_tax_returns
  has_many :tax_returns, through: :tax_return_selection_tax_returns

  def clients
    Client.joins(:tax_returns).where(tax_returns: { id: tax_returns.pluck(:id) }).distinct
  end
end
