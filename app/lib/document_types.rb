module DocumentTypes
  IDENTITY_TYPES = [
    DocumentTypes::Identity,
    DocumentTypes::DriversLicense,
    DocumentTypes::EmployerId,
    DocumentTypes::EmploymentIdentificationDocument,
    DocumentTypes::MilitaryId,
    DocumentTypes::Passport,
    DocumentTypes::PermanentResidentCard,
    DocumentTypes::SchoolId,
    DocumentTypes::StateId,
    DocumentTypes::TribalId,
    DocumentTypes::Visa,
  ].freeze
  OTHER_TYPES = [
    DocumentTypes::Selfie,
    DocumentTypes::SsnItin,
    DocumentTypes::Employment,
    DocumentTypes::FinalTaxDocument,
    DocumentTypes::Form1040,
    DocumentTypes::Form1095A,
    DocumentTypes::Form1098,
    DocumentTypes::Form1098E,
    DocumentTypes::Form1098T,
    DocumentTypes::Form1099A,
    DocumentTypes::Form1099B,
    DocumentTypes::Form1099C,
    DocumentTypes::Form1099Div,
    DocumentTypes::Form1099G,
    DocumentTypes::Form1099Int,
    DocumentTypes::Form1099R,
    DocumentTypes::Form1099S,
    DocumentTypes::Form1099Sa,
    DocumentTypes::Form15080,
    DocumentTypes::Rrb1099,
    DocumentTypes::Ssa1099,
    DocumentTypes::Form5498Sa,
    DocumentTypes::UnsignedForm8879,
    DocumentTypes::CompletedForm8879,
    DocumentTypes::IraStatement,
    DocumentTypes::PriorYearTaxReturn,
    DocumentTypes::CareProviderStatement,
    DocumentTypes::PropertyTaxStatement,
    DocumentTypes::StudentAccountStatement,
    DocumentTypes::W2G,
    DocumentTypes::Other,
    DocumentTypes::RequestedLater,
    DocumentTypes::EmailAttachment,
    DocumentTypes::TextMessageAttachment,
    DocumentTypes::Original13614C,
    DocumentTypes::Form13614C,
    DocumentTypes::Form14446,
    DocumentTypes::OptionalConsentForm,
    DocumentTypes::FormW7,
    DocumentTypes::FormW7Coa
  ].freeze

  ALL_TYPES = IDENTITY_TYPES + OTHER_TYPES

  HELP_TYPES = [
    :doesnt_apply,
    :cant_locate,
    :cant_obtain
  ].freeze
end
