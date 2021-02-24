class SystemNote::AssignmentChange < SystemNote
  def self.generate!(initiated_by: user, tax_return: tax_return)
    return unless tax_return.saved_change_to_assigned_user_id? # if the assigned user didn't change, don't persist

    action = if tax_return.assigned_user.present?
               "assigned #{tax_return.year} return to #{tax_return.assigned_user.name}."
             else
               "removed assignment from #{tax_return.year} return."
             end

    SystemNote.create!(
      user: initiated_by,
      client: tax_return.client,
      body: "#{initiated_by.name} #{action}"
    )
  end
end