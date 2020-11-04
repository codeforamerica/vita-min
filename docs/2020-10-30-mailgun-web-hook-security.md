# Mailgun web hook security

## Summary

Use basic auth, similar to ZendeskWebhookController, for Mailgun, with a separate random password per environment. Ignore Mailgun's web hook signing key.

Generate a random password with `cat /dev/urandom | head -c 32 | openssl base64`, or however you feel good about generating random passwords.

Only allow trusted CFA staff to access the Mailgun console.

We have a way to set up credential rotation, but let's skip that for now.

## Details

### Webhook authentication

We need to keep our database up-to-date as an email changes its delivery status from queued to delivered (or bounced). We use Mailgun to send email, and they can [notify our web app via a web hook](https://documentation.mailgun.com/en/latest/user_manual.html#tracking-messages) when a message's status changes.

We need a way to validate that it's Mailgun communicating these status updates to us rather than someone impersonating Mailgun. Mailgun offers a feature called web hook signing. Unfortunately, the key that they use for signing is shared across all domains within a Mailgun account. We separate credentials between demo & production by using different Mailgun sending domains. If we used the Mailgun web hook signing key, we could store that one key in both the demo and production environments, but if we do so, we are violating the rule of separating credentials between production and non-production.

Let's use HTTP Basic Auth for proving Mailgun is talking to us. The ZendeskWebhookController's `authenticate_zendesk_request` method is a great example to build from. It separates credentials between environments, and it is easy to unit-test.

I have tested that Mailgun's web hooks system can perform HTTP Basic authentication. First, I created a request bin using [requestbin.com](http://requestbin.com/).

I visited [https://app.mailgun.com/app/sending/domains/mg-demo.getyourrefund-testing.org/webhooks](https://app.mailgun.com/app/sending/domains/mg-demo.getyourrefund-testing.org/webhooks) and entered the request bin's URL, along with "example1:example2@" after https:// and before the domain name, following the typical [basic auth URL encoding](https://en.wikipedia.org/wiki/Basic_access_authentication#URL-encoding). Mailgun sent a request with a `Authorization: Basic ZXhhbXBsZTE6ZXhhbXBsZTI=` header, which decodes to "example1:example2". Therefore, we know Mailgun will use basic auth if we put it in the URL.

I also validated that the header correctly decodes. `Base64.decode64('ZXhhbXBsZTE6ZXhhbXBsZTI=')` in Ruby returns `"example1:example2"`, which shows it works.

I asked Mailgun support to confirm that they're confident they'll support basic auth for the foreseeable future. They wrote back, "Thank you for reaching out to Mailgun support. We do not have any plans to change our authentication methods so you should be good to go."

### Accessing the Mailgun web console

It's important that only trusted CFA staff be permitted to access the Mailgun web console (and that they have 2FA enabled). The Mailgun web console shows the full text of each message, which could include confidential information clients are trying to send us. The web console also allows one to see the web hook URL for each environment, which includes the basic auth token used for authenticating Mailgun.

When someone's access to the web console is removed, we can consider rotating the Mailgun web hook credentials.

### Rotating credentials

If we want to set up credential rotation, we can do so if we store **two** Mailgun auth passwords in our Rails secrets per environment. Let's call them `password_old` and `password_new`. If we want to do a key rotation and change the password Mailgun uses, the procedure would be as follows, _once per environment._

- Ensure the current password is available at both `Rails.application.credentials.mailgun.password_old` and `Rails.application.credentials.mailgun.password_new`. In the code that validates Mailgun's Basic auth password, accept either the value in `Rails.application.credentials.mailgun.password_old` or the value in `Rails.application.credentials.mailgun.password_new`. Do a deploy.
- Generate a new password. Adjust the value of `Rails.application.credentials.mailgun.password_new` to be the new password. Do a deploy.
- Adjust Mailgun's configuration in the web dashboard to use that new password as the basic auth password in webhooks.
- Adjust `Rails.application.credentials.mailgun.password_old` to contain the new password, i.e., `password_new` and `password_old` would both be the new value. Do a deploy.
