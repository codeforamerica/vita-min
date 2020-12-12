class ClientRouter
  def self.route(client)
    partner_with_most_users = VitaPartner.left_joins(:users).group(:id).order('COUNT(users.id) DESC').first
    client.update(vita_partner: partner_with_most_users)
    client.intake.update(vita_partner: partner_with_most_users)
  end
end
