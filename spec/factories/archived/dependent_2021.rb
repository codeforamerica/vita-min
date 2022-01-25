FactoryBot.define do
  factory :archived_2021_dependent, class: Archived::Dependent2021 do
    first_name { "Kara" }
    last_name { "Kiwi" }
    birth_date { Date.new(2011, 3, 5) }
    relationship { "daughter" }
  end
end
