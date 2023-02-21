module AutomatedMessage
  class Ctc2022OpenMessage < AutomatedMessage
    def self.name
      'messages.ctc_2022_open_message'.freeze
    end

    def service_type
      :ctc
    end

    def from
      Rails.configuration.email_from[:noreply][:ctc]
    end

    def sms_body(**args)
      <<~BODY
          GetCTC is officially open for you to e-file a simplified return to claim your Child Tax Credit and third stimulus payment. Go to getctc.org/live to file today.

          GetCTC está oficialmente abierto para que presente electrónicamente una declaración simplificada para reclamar su Crédito Tributario por Hijos y el tercer pago de estímulo. Vaya a getctc.org/live para presentar su solicitud hoy.
        BODY
    end

    def email_subject(**args)
      "GetCTC is open for tax filing! / ¡GetCTC está abierto para la declaración de impuestos!"
    end

    def email_body(**args)
      <<~BODY
        Thank you for signing up to receive updates about GetCTC! GetCTC is officially open to e-file a simplified tax return to claim your Child Tax Credit and third stimulus payment. Currently simplified filing is only available to people who lived in the United States (any of the 50 states or the District of Columbia) for at least 6 months in 2021.
        
        Go to getctc.org/live to file today
        
        We're here to help,
        
        Your tax team at GetCTC

        --------------------------------------
        
        ¡Gracias por registrarse para recibir actualizaciones sobre GetCTC! GetCTC está oficialmente abierto para presentar electrónicamente una declaración de impuestos simplificada para reclamar su Crédito Tributario por Hijos y el tercer pago de estímulo. Actualmente, la presentación simplificada solo está disponible para las personas que vivieron en los Estados Unidos (cualquiera de los 50 estados o el Distrito de Columbia) durante al menos 6 meses en 2021.
        Vaya a getctc.org/live para presentar su solicitud hoy
        
        Estamos aquí para ayudar,
        Su equipo de impuestos en GetCTC
      BODY
    end
  end
end
