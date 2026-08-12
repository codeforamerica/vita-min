FactoryBot.define do
  factory :bulk_client_flag_update do
    tax_return_selection
    enabled { true }
  end
end