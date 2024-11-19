module PdfFiller
  class Nj2450Pdf
    include PdfHelper
    include StateFile::NjPdfHelper
    include TimeHelper

    W2_PDF_KEYS = [
      {
        employer_name: 'Name1',
        employer_ein: 'Fed Emp ID',
        wages: 'Wages1',
        column_a: 'A1',
        column_c: 'C1',
      },
      {
        employer_name: 'Name2',
        employer_ein: 'Fed Emp ID2',
        wages: 'Wages12',
        column_a: 'A2',
        column_c: 'C2',
      },
      {
        employer_name: 'Name3',
        employer_ein: 'Fed Emp ID3',
        wages: 'Text-9RgwFiPMah', # Modified because it was also named Wages12
        column_a: 'A3',
        column_c: 'C3',
      },
      {
        employer_name: 'Name4',
        employer_ein: 'Fed Emp ID4',
        wages: 'Wages14',
        column_a: 'A4',
        column_c: 'C4',
      },
      {
        employer_name: 'Name5',
        employer_ein: 'Fed Emp ID5',
        wages: 'Wages15',
        column_a: 'A5',
        column_c: 'C5',
      }
    ].freeze

    def source_pdf_name
      "nj2450-TY2024"
    end

    def initialize(submission, kwargs)
      @submission = submission
      @kwargs = kwargs

      builder = StateFile::StateInformationService.submission_builder_class(:nj)
      @parent_xml_doc = builder.new(submission).document
      @xml_document = get_xml_document
    end

    def hash_for_pdf
      answers = {
        # Header - get from nj 1040 submission
        'Names as shown on Form NJ1040': get_name(@parent_xml_doc),
        'Social Security Number': intake.primary.ssn,
        'Claimant Name': get_name(@parent_xml_doc, include_spouse: false, spouse_only: primary_or_spouse == :spouse),
        'Claimant SSN': ssn,
        Address: get_address(@parent_xml_doc),
        City: @parent_xml_doc.at("ReturnHeaderState Filer USAddress CityNm")&.text,
        State: @parent_xml_doc.at("ReturnHeaderState Filer USAddress StateAbbreviationCd")&.text,
        'ZIP Code': @parent_xml_doc.at("ReturnHeaderState Filer USAddress ZIPCd")&.text,

        # Sum of remaining W2s
        'If additional space is required enclose a rider and enter the total on this line': total_rider_column_a,
        '3If additional space is required enclose a rider and enter the total on this line': total_rider_column_c,

        # Totals
        'Total Deducted Add lines 1A through 1F Enter here': @xml_document.at('ColumnATotal')&.text,
        '3Total Deducted Add lines 1A through 1F Enter here': @xml_document.at('ColumnCTotal')&.text,
        '14620Subtract line 3 column A from line 2 column A Enter on line 58 of the NJ1040': @xml_document.at('ColumnAExcess')&.text,
        '2752Subtract line 3 column C from line 2 column C Enter on line 60 of the NJ1040': @xml_document.at('ColumnCExcess')&.text,
        Date: default_date_format(Time.now)
      }

      W2_PDF_KEYS.each.with_index do |pdf_w2, i|
        w2 = w2s[i]
        next unless w2
        w2_hash = {}
        pdf_w2.each_key do |key|
          pdf_w2_field_name = pdf_w2[key]
          w2_hash[pdf_w2_field_name] = w2[key]
        end
        answers.merge!(w2_hash)
      end

      answers
    end

    private

    def intake
      @submission.data_source
    end

    def ssn
      primary_or_spouse == :primary ? intake.primary.ssn : intake.spouse&.ssn
    end

    def primary_or_spouse
      @kwargs[:primary_or_spouse]
    end
    
    def get_xml_document
      nj_2450s = @parent_xml_doc.css('FormNJ2450')
      filer_indicator = primary_or_spouse == :primary ? 'T' : 'S'
      docs = nj_2450s.select { |nj_2450| nj_2450.at('FilerIndicator')&.text == filer_indicator }
      docs[0]
    end

    def w2s
      @xml_document.css('Body').map do |w2|
        {
          employer_name: w2.at('EmployerName')&.text,
          employer_ein: w2.at('FedEmployerId')&.text,
          wages: w2.at('Wages')&.text,
          column_a: w2.at('ColumnA')&.text,
          column_c: w2.at('ColumnC')&.text,
        }
      end
    end

    def total_rider_column_a
      return if w2s.length < 6
      w2s[5..].reduce(0) { |sum, w2| sum + w2[:column_a].to_d }.round
    end

    def total_rider_column_c
      return if w2s.length < 6
      w2s[5..].reduce(0) { |sum, w2| sum + w2[:column_c].to_d }.round
    end
  end
end
