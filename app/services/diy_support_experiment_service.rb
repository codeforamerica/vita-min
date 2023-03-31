class DiySupportExperimentService
  def self.taxslayer_link(treatment, received_1099)
    puts 'hi im a treatment'
    puts treatment.inspect
    return "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934" unless treatment

    if received_1099
      if treatment == 'high'
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23062996"
      else
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=34067601"
      end
    else
      if treatment == 'high'
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23069434"
      else
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=21061019"
      end
    end
  end
end
