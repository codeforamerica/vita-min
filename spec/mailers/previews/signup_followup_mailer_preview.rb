# Preview all emails at http://localhost:3000/rails/mailers/signup_followup_mailer
class SignupFollowupMailerPreview < ActionMailer::Preview
  def followup
    SignupFollowupMailer.followup("squash@example.com")
  end
end
