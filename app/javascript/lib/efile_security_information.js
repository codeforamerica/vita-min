import initFingerprint2 from "../vendor/IRS_fingerprint2_2_1_2";
import initCryptoJS from "../vendor/sha1";

export function getEfileSecurityInformation(idPrefix) {
    let Fingerprint2 = initFingerprint2();
    let CryptoJS = initCryptoJS();
    Fingerprint2.get(function(components) {
        let concatenated = components.map(function (pair) { return pair.value }).join('###')
        let concatenatedAndHashed = CryptoJS.SHA1(concatenated).toString().toUpperCase();
        document.getElementById(idPrefix + '_device_id').value = concatenatedAndHashed;
    });

    document.getElementById(idPrefix + '_user_agent').value = navigator.userAgent;
    document.getElementById(idPrefix + '_browser_language').value = navigator.language;
    document.getElementById(idPrefix + '_platform').value = navigator.platform;
    let now = new Date();
    document.getElementById(idPrefix + '_client_system_time').value = now;
    document.getElementById(idPrefix + '_timezone_offset').value = now.getTimezoneOffset();
}


