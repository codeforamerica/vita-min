import initFingerprint2 from "../vendor/IRS_fingerprint2_2_1_2";
import initCryptoJS from "../vendor/sha1";

export function getEfileSecurityInformation() {
    let Fingerprint2 = initFingerprint2();
    let CryptoJS = initCryptoJS();
    Fingerprint2.get(function(components) {
        let concatenated = components.map(function (pair) { return pair.value }).join('###')
        let concatenatedAndHashed = CryptoJS.SHA1(concatenated).toUpperCase();
        document.getElementById('ctc_consent_form_device_id').value = concatenatedAndHashed;
    });

    document.getElementById('ctc_consent_form_user_agent').value = navigator.userAgent;
    document.getElementById('ctc_consent_form_browser_language').value = navigator.language;
    document.getElementById('ctc_consent_form_platform').value = navigator.platform;
    let now = new Date();
    document.getElementById('ctc_consent_form_client_system_time').value = now;
    document.getElementById('ctc_consent_form_timezone_offset').value = now.getTimezoneOffset();
}


