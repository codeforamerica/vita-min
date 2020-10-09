const helpers = require('helpers')

test("Sets the user's current time zone", function (){
    const expectedTimezoneValue = Intl.DateTimeFormat().resolvedOptions().timeZone;
    document.body.innerHTML =
        '<select id="user_timezone">' +
        '  <option value="Tlön/Uqbar" selected>Uqbar Time</option>' +
        '  <option value="America/Indiana/Pawnee">Pawnee Time</option>' +
        '  <option value="'+expectedTimezoneValue+'">Tester Time</option>' +
        '</select>';

    helpers.setDefaultTimezone();

    expect(document.getElementById('user_timezone').value).toBe(expectedTimezoneValue);
});