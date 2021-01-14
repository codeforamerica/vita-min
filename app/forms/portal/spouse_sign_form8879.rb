module Portal
  class SpouseSignForm8879 < Form
    attr_accessor :spouse_accepts_terms, :spouse_confirms_identity, :ip, :transaction_failed
    validate :terms_accepted
    validate :identity_confirmed

    def initialize(tax_return, params = {})
      @tax_return = tax_return
      super(params)
    end

    def sign
      return false unless valid?

      return true if ActiveRecord::Base.transaction do
        @tax_return.spouse_signed_at = DateTime.now
        @tax_return.spouse_signed_ip = ip
        @tax_return.spouse_signature = @tax_return.client.spouse_legal_name
        if @tax_return.primary_has_signed?
          @tax_return.status = :file_ready_to_file
          create_signed_8879
          @tax_return.client.set_attention_needed
        end
        @tax_return.save!
      end

      errors.add(:transaction_failed) && false
    end

    private

    def create_signed_8879
      unsigned8879 = @tax_return.documents.find_by(document_type: DocumentTypes::Form8879.key)
      timezone = @tax_return.client.intake.timezone || "America/New York"
      @document_writer = WriteToPdfDocumentService.new(unsigned8879, DocumentTypes::Form8879)
      @document_writer.write(:primary_signature, @tax_return.primary_signature)
      @document_writer.write(:primary_signed_on, @tax_return.primary_signed_at.in_time_zone(timezone).strftime("%m/%d/%Y"))
      if @tax_return.spouse_has_signed?
        @document_writer.write(:spouse_signature, @tax_return.spouse_signature)
        @document_writer.write(:spouse_signed_on, @tax_return.spouse_signed_at.in_time_zone(timezone).strftime("%m/%d/%Y"))
      end
      tempfile = @document_writer.tempfile_output
      @tax_return.documents.create!(
          client: @tax_return.client,
          document_type: DocumentTypes::CompletedForm8879.key,
          display_name: "Taxpayer Signed #{@tax_return.year} 8879",
          upload: {
              io: tempfile,
              filename: "Signed-f8879.pdf",
              content_type: "application/pdf",
              identify: false
          }
      )
    end

    def self.permitted_params
      [:spouse_accepts_terms, :spouse_confirms_identity]
    end

    private

    def terms_accepted
      errors.add(:spouse_accepts_terms, :blank) unless spouse_accepts_terms == "yes"
    end

    def identity_confirmed
      errors.add(:spouse_confirms_identity, :blank) unless spouse_confirms_identity == "yes"
    end
  end

  class NotReadyToSignError < StandardError; end
  class AlreadySignedError < StandardError; end
end