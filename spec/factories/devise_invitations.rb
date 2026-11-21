FactoryBot.define do
  factory :devise_invitation, class: "DeviseInvitable::Invitation" do
    association :invitable, factory: :user
    association :invited_by, factory: :admin_user
    invite_key { { email: invitable.email } }
    invitation_created_at { 1.day.ago - 1.minute }
    invitation_sent_at { 1.day.ago }
    resource_created_at { invitation_created_at }
    sequence(:invitation_token) do |n|
      Devise.token_generator.digest(User, :invitation_token, "InvitationToken#{n}")
    end
  end
end
