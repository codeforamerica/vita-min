module Hub
  class Update13614cFormPage5 < Form
    include FormAttributes

    set_attributes_for :intake, :additional_notes_comments
                        
    attr_accessor :client

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def save
      @client.intake.update(attributes_for(:intake))
      @client.touch(:last_13614c_update_at)
    end
  end
end

