class SystemNote::SmsOptOut < SystemNote
  def self.generate!(client:)
    create!(
      client: client,
      body: 'Client replied "STOP" to opt out of text messages'
    )
  end
end