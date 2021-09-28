import initFingerprint2 from "../vendor/IRS_fingerprint2_2_1_2";
import initCryptoJS from "../vendor/sha1";

export function getEfileSecurityInformation(formName) {
    let Fingerprint2 = initFingerprint2();
    let CryptoJS = initCryptoJS();
    Fingerprint2.get(function(components) {
        let concatenated = components.map(function (pair) { return pair.value }).join('###')
        let concatenatedAndHashed = CryptoJS.SHA1(concatenated).toString().toUpperCase();
        let timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        let now = new Date();
        let timezoneOffset = now.getTimezoneOffset();
        let timezoneOffsetString = timezoneOffset < 0 ? (timezoneOffset.toString()) : ("+" + timezoneOffset);
        let securityAttributes = {
            device_id: concatenatedAndHashed,
            user_agent: navigator.userAgent,
            browser_language: navigator.language,
            platform: navigator.platform,
            client_system_time: now,
            timezone_offset: timezoneOffsetString,
            timezone: timezone,
        };

        for (const attr in securityAttributes) {
            let hiddenField = document.createElement('input');
            hiddenField.setAttribute('type', 'hidden')
            hiddenField.setAttribute('name', formName + '[' + attr + ']')
            hiddenField.value = securityAttributes[attr];

            document.querySelector('main form').appendChild(hiddenField);
        }
    });
}


