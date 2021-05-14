module TaxReturnAssignableUsersHelper
  def assignable_user_options(assignable_users)
    options = [[t("hub.bulk_actions.change_assignee_and_status.edit.keep_assignee"), BulkTaxReturnUpdate::KEEP], [t("hub.bulk_actions.change_assignee_and_status.edit.remove_assignee"), BulkTaxReturnUpdate::REMOVE]]
    options.concat(assignable_users&.map { |u| [u.name, u.id] })
  end
end
