# Keeping Local Fraud Indicators in Sync

Fraud Indicators are partially obfuscated from the codebase. When we're asked to add a new fraud rule,
please update the local encrypted file so that we can test against it.

```
rails encrypted:edit app/models/fraud/indicators.json.enc --key config/fraud_indicators.key
```