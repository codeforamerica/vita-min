#!bin/rails runner

assigned_user = User.last
assigning_user = User.first
tax_return = TaxReturn.last

email = UserMailer.assignment_email(assigned_user: assigned_user,
                                    assigning_user: assigning_user,
                                    tax_return: tax_return,
                                    assigned_at: tax_return.updated_at).deliver
