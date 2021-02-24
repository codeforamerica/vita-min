class SystemNote::SignedDocument < SystemNote
  def self.generate!(tax_return:, signed_by_type:, waiting: false)
    accepted_types = [:spouse, :primary]
    raise ArgumentError, "Invalid signed by type" unless accepted_types.include? signed_by_type.to_sym

    signed_by_type = signed_by_type.to_sym

    title_map = {
        spouse: "spouse of taxpayer",
        primary: "primary taxpayer"
    }

    body = "#{title_map[signed_by_type].capitalize} signed #{tax_return.year} form 8879."
    if waiting
      waiting_for_type = (accepted_types - [signed_by_type]).first
      body << " Waiting on #{title_map[waiting_for_type]} to sign."
    end

    create!(
      body: body,
      client: tax_return.client,
    )
  end
end