FactoryBot.define do
  factory :outgoing_email do
    client
    user
    body { "nothin" }
    subject { "Re: Re: Nothing" }
    sequence(:sent_at) { |n| DateTime.new(2020, 9, 2, 15, 1, 30) + n.minutes }
  end
end
