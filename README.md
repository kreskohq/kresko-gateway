## Kresko Gateway

Gateway contract that checks if the gas asset has a wrapper token that is accepted as collateral. If so, wraps msg.value and deposits on behalf of msg.sender as collateral.

### Run Tests:

```
forge test -vvv --fork-url <optimistic goerli rpc url>
```
