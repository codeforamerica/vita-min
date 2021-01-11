# == Schema Information
#
# Table name: greeter_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :greeter_role do
    factory :with_coalition do
      coalitions { [create(:coalition)] }
    end

    factory :with_organization do
      organizations { [create(:organization)] }
    end
  end
end
