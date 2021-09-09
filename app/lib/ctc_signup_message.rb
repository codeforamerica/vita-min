class CtcSignupMessage
  def self.send(count)
    ctc_signups = CtcSignup.where(beta_email_sent_at: nil).take(count)
    ctc_signups.each do |ctc_signup|
      if ctc_signup.email_address.present?
        CtcSignupMailer.beta_navigation(email_address: ctc_signup.email_address, name: ctc_signup.name).deliver_now
      end

      body = <<~BODY
        Hello %<name>s,
  
        Thank you for signing up for GetCTC to claim your Child Tax Credit and any missing stimulus payments.
 
        If you would like assistance today, we have a team of tax experts who can help you navigate our application over the phone.
  
        Call (860) 590-8910 for assistance.
  
        If you prefer to file independently, we will send a link to GetCTC, our simplified self-serve filing portal, when it is available soon.

        --------------------------

        Gracias por registrarse en GetCTC para reclamar su Crédito Tribuario por Hijos y cualquier pago de estimulo faltante.

        Si desea ayuda hoy, tenemos un equipo de expertos en impuestos que pueden ayudarlo con nuestra aplicación.

        Llame al (860) 590-8910 para obtener ayuda.

        Si prefiere declarar de forma independiente, le enviaremos un enlace a GetCTC, nuestro portal de autoservicio simplificado para declarar, tan pronto como el portal esté disponible.
      BODY

      if ctc_signup.phone_number.present?
        TwilioService.send_text_message(
          to: ctc_signup.phone_number,
          body: (body % { name: ctc_signup.name }),
        )
      end

      ctc_signup.touch(:beta_email_sent_at)
    end
  end

  def self.send_launch_announcement(count)
    ctc_signups = CtcSignup.where(launch_announcement_sent_at: nil).take(count)
    ctc_signups.each do |ctc_signup|
      _send_one_launch_announcement(ctc_signup)
    end
  end

  def self._send_one_launch_announcement(ctc_signup)
    if ctc_signup.email_address.present?
      CtcSignupMailer.launch_announcement(email_address: ctc_signup.email_address, name: ctc_signup.name).deliver_later
    end

    text_email_template_file = File.read(File.join(Rails.root, "app/views/ctc_signup_mailer/launch_announcement.text.erb"))
    text_email_template = ERB.new(text_email_template_file)
    @name = ctc_signup.name
    text_email = text_email_template.result(binding)

    en_sms, es_sms = text_email.split('--------------------------')

    if ctc_signup.phone_number.present?
      TwilioService.send_text_message(
        to: ctc_signup.phone_number,
        body: en_sms,
      )
      TwilioService.send_text_message(
        to: ctc_signup.phone_number,
        body: es_sms,
      )
    end

    ctc_signup.touch(:launch_announcement_sent_at)
  end
end
