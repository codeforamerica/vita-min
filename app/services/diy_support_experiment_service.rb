class DiySupportExperimentService
  # The DIY support experiment was a one-time experiment done for TY2022.

  def self.fsa_domain
    if Rails.env.test?
      "https://www.example.com"
    else
      "https://www.taxslayer.com"
    end
  end

  def self.fsa_link(support_level_treatment, received_1099)
    return "#{fsa_domain}/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934" if support_level_treatment.blank?

    if received_1099
      if support_level_treatment == 'high'
        "#{fsa_domain}/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23062996"
      else
        "#{fsa_domain}/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=34067601"
      end
    else
      if support_level_treatment == 'high'
        "#{fsa_domain}/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23069434"
      else
        "#{fsa_domain}/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=21061019"
      end
    end
  end
end
