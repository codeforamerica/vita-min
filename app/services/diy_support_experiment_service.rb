class DiySupportExperimentService
  def self.taxslayer_link(support_level_treatment, received_1099)
    return "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934" if support_level_treatment.blank?

    if received_1099
      if support_level_treatment == 'high'
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23062996"
      else
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=34067601"
      end
    else
      if support_level_treatment == 'high'
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23069434"
      else
        "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=21061019"
      end
    end
  end
end
