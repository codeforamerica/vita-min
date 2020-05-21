module Diy
  class EmailAddressController < DiyController
    def tracking_data
      {}
    end

    def self.form_name
      "diy_email_address_form"
    end

    #TODO: remove this when next page is added
    def next_path(params = nil)
      root_path
    end

  end
end
