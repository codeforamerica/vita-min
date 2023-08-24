# Keeping Local Fraud Indicators in Sync

Fraud Indicators are partially obfuscated from the codebase. When we're asked to add a new fraud rule,
please update the local encrypted file so that we can test against it.

Some helpful guidance for how to add a new fraud indicator is in this notion file:

https://www.notion.so/cfa/How-to-add-a-new-fraud-indicator-bba970117d7642e0a28343896c81e2c1

If you need to look at the file itself, run this:

```
EDITOR="vi" rails encrypted:edit app/models/fraud/indicators.json.enc --key config/fraud_indicators.key
```

