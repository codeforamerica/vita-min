## Maintenance mode

### Scheduling maintenance

You can add a flash message to all pages on the site indicating the site will undergo scheduled maintenance.

Configure this with:

```
aptible config:set --app vita-min-staging MAINTENANCE_MODE_SCHEDULED="8:00 PM PT"
```

See `ApplicationController` for implementation details.

Turn the message off with:

```
aptible config:set --app vita-min-staging MAINTENANCE_MODE_SCHEDULED=""
```

### Maintenance URL if the website crashes

Aptible will automatically show a crash screen under some circumstances where the
site is unavailable. This is configured with the `MAINTENANCE_PAGE_URL` config
option in Aptible. Consider setting it to `https://getyourrefund.org/maintenace/`.

### Disabling the website for maintenance

If you want to make all pages on the site redirect to a maintenance URL, you can
set the `MAINTENANCE_MODE` variable to a non-blank value. This could result in
our Twilio/Mailgun/etc. web hooks being marked as succeeded even though we did
not write them to our database, so use with care.

