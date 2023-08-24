# == Schema Information
#
# Table name: efile_errors
#
#  id          :bigint           not null, primary key
#  auto_cancel :boolean          default(FALSE)
#  auto_wait   :boolean          default(FALSE)
#  category    :string
#  code        :string
#  expose      :boolean          default(TRUE)
#  message     :text
#  severity    :string
#  source      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class EfileError < ApplicationRecord
  has_rich_text :description_en
  has_rich_text :description_es
  has_rich_text :resolution_en
  has_rich_text :resolution_es

  def self.error_codes_to_retry_once
    # These error codes indicate that the IRS had trouble parsing our data. When we see this, it
    # is usually correlated with IRS downtime. The implication seems to be that the IRS didn't process
    # our submission correctly during the downtime period, and that re-submitting is a good idea.
    %w[X0000-010 X0000-032]
  end
end
