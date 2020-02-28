class ContactUsForm < Form
  include ZendeskServiceHelper

  attr_accessor :body
  attr_accessor :email

  validates :email, presence: true

  def save
    # TODO: Test - does this work??
    # TODO: Validate body is present
    requester_id = find_or_create_end_user(nil, email, nil)

    ZendeskAPI::Ticket.create(
      EitcZendeskInstance.client,
      subject: "New question via 'Contact Us' form",
      requester_id: requester_id,
      group_id: EitcZendeskInstance::WEBSITE_QUESTIONS,
      comment: { body: body },
      fields: []
    )
  end
end
