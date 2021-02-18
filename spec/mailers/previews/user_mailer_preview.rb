# Preview all emails at http://localhost:3000/rails/mailers/outbound_email_mailer
class UserMailerPreview < ActionMailer::Preview
  def assignment_email
    UserMailer.assignment_email(
      assigned_user: User.last,
      assigning_user: User.first,
      tax_return: TaxReturn.last,
      assigned_at: TaxReturn.last.updated_at
    )
  end

end