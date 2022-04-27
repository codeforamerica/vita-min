class CanonicalEmail
  attr_accessor :handle, :domain
  def initialize(email_address)
    @handle, @domain = email_address.downcase.split("@")
  end

  def canonical_email
    canonical_handle =  case domain
                        when "gmail.com"
                          plus_canonical.gsub(".", "")
                        when "yahoo.com"
                          hyphen_canonical
                        when "hotmail.com", "outlook.com", "icloud.com", "me.com", "mac.com"
                          plus_canonical
                        else
                          @handle
                        end
    [canonical_handle, domain].join("@")
  end

  def self.get(email)
    return unless email.present?
    
    new(email).canonical_email
  end

  private

  def plus_canonical
    @handle.split("+")[0]
  end

  def hyphen_canonical
    @handle.split("-")[0]
  end
end