class DefaultErrorMessages
  def self.generate!
    EfileError.find_or_create_by!(
      code: "BUNDLE-FAIL",
      message: "An error occurred while bundling the submission XML.",
      source: :internal,
      expose: false
    )
    EfileError.find_or_create_by!(
      code: "USPS-2147219401",
      message: "Address Not Found.",
      source: :usps,
      expose: true
    )
    EfileError.find_or_create_by!(
      code: "PDF-1040-FAIL",
      message: "Could not generate IRS Form 1040 PDF.",
      source: :internal,
      expose: false
    )
    EfileError.find_or_create_by!(
      code: "TRANSMISSION-SERVICE",
      message: "Error communicating with GYR Efiler service.",
      source: :internal,
      expose: false
    )
    EfileError.find_or_create_by!(
      code: "TRANSMISSION-RESPONSE",
      message: "Unexpected transmission response format from IRS.",
      source: :internal,
      expose: false
    )
    EfileError.find_or_create_by!(
      code: "BANK-DETAILS",
      message: "Some of the provided bank account details are incorrect or absent.",
      source: :intake,
      expose: true,
      auto_wait: true
    )
  end
end