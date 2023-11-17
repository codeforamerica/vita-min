module SubmissionBuilder
  module Ty2022
    module States
      module Az
        module Documents
          class State1099G < SubmissionBuilder::Document
            include SubmissionBuilder::FormattingMethods

            def document
              form1099g = @kwargs[:form1099g]

              build_xml_doc("State1099G", documentId: "State1099G-#{form1099g.id}") do |xml|
                xml.PayerName payerNameControl: form1099g.default_payer_name.gsub(/\s+/, '').upcase[0..3] do
                  xml.BusinessNameLine1Txt form1099g.default_payer_name
                end
                recipient = if form1099g.recipient_primary?
                  form1099g.intake.primary
                elsif form1099g.recipient_spouse?
                  form1099g.intake.spouse
                end
                xml.RecipientSSN recipient.ssn
                xml.RecipientName recipient.full_name
              end
            end
          end
        end
      end
    end
  end
end
