module AutomatedMessage
  class PuertoRicoOpenMessage < AutomatedMessage
    def self.name
      'messages.puerto_rico_open_message'.freeze
    end

    def service_type
      :ctc
    end

    def from
      Rails.configuration.email_from[:noreply][:ctc]
    end

    def sms_body(*args)
      <<~BODY
          GetCTC is now open for residents of Puerto Rico to e-file a simplified return to claim the Child Tax Credit. Go to getctc.org/puertorico?s=live-pr to file today.

          GetCTC está abierto para los residentes de Puerto Rico para radicar una planilla simplificada para reclamar el Crédito Tributario por Hijos. Vaya a getctc.org/puertorico?s=live-pr para radicar su planilla hoy.
      BODY
    end

    def email_subject(*args)
      "GetCTC is open in Puerto Rico! / ¡GetCTC está abierto en Puerto Rico!"
    end

    def email_body(*args)
      <<~BODY
        Thank you for signing up to receive updates about GetCTC! GetCTC is now open for residents of Puerto Rico to e-file a simplified tax return to claim the Child Tax Credit. GetCTC is still open for residents of the 50 states and D.C. to claim their Child Tax Credit and third stimulus payment.

        Go to getctc.org/puertorico?s=live-pr to file today

        We're here to help,

        Your tax team at GetCTC

        --------------------------------------
        
        ¡Gracias por registrarse para recibir actualizaciones sobre GetCTC! GetCTC ahora está abierto para residentes de Puerto Rico para radicar una planilla federal simplificada para reclamar el Crédito Tributario por Hijos. GetCTC todavía está abierto para las personas que viven en los 50 estados o el Distrito de Columbia, para reclamar el Crédito Tributario por Hijos y el tercer pago de estímulo.

        Vaya a getctc.org/puertorico?s=live-pr para radicar su planilla hoy.

        Estamos aquí para ayudar,
        
        Su equipo de impuestos en GetCTC
      BODY
    end
  end
end
