const helpers = {
    setDefaultTimezone: function setDefaultTimezone() {
        const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        document.getElementById('user_timezone').value = timezone;
    }
};

module.exports = helpers;