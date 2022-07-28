module AdhocMessages
  class IncreaseReferralsExperiment
    def subject
      {
        en: "Refer your friends to GetCTC!",
        es: "¡Refiera a sus amigos a GetCTC!"
      }
    end

    def body
      {
        en: "Thank you for filing your tax return with GetCTC! Every family should get the money they deserve. Tell your family and friends to claim their benefits too at getctc.org/refer",
        es: "¡Gracias por presentar su declaración de impuestos con GetCTC! Cada familia debe recibir el dinero que se merece. Dígales a sus familiares y amigos que también reclamen sus beneficios en getctc.org/refer"
      }
    end

    def create_tax_return_selection(batch: nil)
      TaxReturnSelection.create!(tax_returns: tax_returns(batch: batch))
    end

    def tax_returns(batch: nil)
      state_filter =
        if batch == 1
          %w[AL AK AZ CO CT DE GA HI ID IN KS LA MI NH NJ NM NY ND OH SC SD TN TX UT VA WV]
        elsif batch == 2
          %w[AR CA DC FL IL IA KY ME MD MA MN MS MO MT NE NV NC OK OR PA RI VT WA WI WY]
        else
          []
        end
      TaxReturn.joins(client: :intake).in_state(:file_accepted).where(
        "most_recent_tax_return_transition.created_at > ?", 5.days.ago
      ).where(intake: {type: 'Intake::CtcIntake', state: state_filter})
    end
  end
end
