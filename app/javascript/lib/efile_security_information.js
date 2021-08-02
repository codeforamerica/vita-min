import "../vendor/IRS_fingerprint2_2_1_2.js";
import "../vendor/sha1.js";

export function initEfileSecurityInformation() {
    let something = Fingerprint2.get(function(components) {
        var stringtohash = components.map(function (pair) { return pair.value }).join('###')
        return CryptoJS.SHA1(stringtohash);
    })
    console.log(something)
}


