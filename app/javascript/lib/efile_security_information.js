import initFingerprint2 from "../vendor/IRS_fingerprint2_2_1_2.js";
import initCryptoJS from "../vendor/sha1";

export function getEfileSecurityInformation() {
    let Fingerprint2 = initFingerprint2();
    let CryptoJS = initCryptoJS();
    Fingerprint2.get(function(components) {
        var stringtohash = components.map(function (pair) { return pair.value }).join('###')
        let encrypted_device_id =  CryptoJS.SHA1(stringtohash);
        alert(encrypted_device_id)
    });
}


