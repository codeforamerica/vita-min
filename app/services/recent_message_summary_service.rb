class RecentMessageSummaryService
  def self.messages(client_ids)
    summaries = {}
    client_ids.each do |client_id|
      emails = OutgoingEmail.where(client_id: client_id).order(created_at: :desc).limit(1).load
      unless emails.empty?
        email = emails.first

        summaries[client_id] = {author: email.user.name, body: email.body, date: email.created_at}
      end
    end

    summaries
  end
end
