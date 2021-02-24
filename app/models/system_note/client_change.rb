class SystemNote::ClientChange < SystemNote
  def self.generate!(intake:, initiated_by: )
    return unless intake.saved_changes.present?

    changes_list = ""
    intake.saved_changes.each do |k, v|
      next if k == "updated_at"
      next if k.include?("encrypted")

      changes_list += "\n\u2022 #{k.tr('_', ' ')} from #{v[0]} to #{v[1]}"
    end

    if changes_list.present?
      SystemNote.create(
        body: "#{initiated_by.name} changed: #{changes_list}",
        client: intake.client,
        user: initiated_by
      )
    end
  end
end