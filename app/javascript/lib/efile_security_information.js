import initFingerprint2 from "../vendor/IRS_fingerprint2_2_1_2";
import initCryptoJS from "../vendor/sha1";

export function getEfileSecurityInformation() {
    let Fingerprint2 = initFingerprint2();
    let CryptoJS = initCryptoJS();
    Fingerprint2.get(function(components) {
        var stringtohash = components.map(function (pair) { return pair.value }).join('###')
        let encrypted_device_id =  CryptoJS.SHA1(stringtohash);
        document.getElementById('ctc_consent_form_device_id').value = encrypted_device_id || "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    });

    document.getElementById('ctc_consent_form_user_agent').value = navigator.userAgent;
    document.getElementById('ctc_consent_form_browser_language').value = navigator.language;
    document.getElementById('ctc_consent_form_platform').value = navigator.platform;
    var loadDate = new Date();
    document.getElementById('ctc_consent_form_client_system_time').value = loadDate;
    var timezone_offset = loadDate.getTimezoneOffset();
    document.getElementById('ctc_consent_form_timezone_offset').value = timezone_offset.includes("-") ? timezone_offset : "+" + timezone_offset;
}


