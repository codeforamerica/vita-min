# == Schema Information
#
# Table name: addresses
#
#  id              :bigint           not null, primary key
#  city            :string
#  record_type     :string
#  state           :string
#  street_address  :string
#  street_address2 :string
#  zip_code        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  record_id       :bigint
#
class Address < ApplicationRecord
  belongs_to :record, polymorphic: true
end
