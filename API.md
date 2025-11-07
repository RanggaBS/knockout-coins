# Knockout Coins

todo: tidy up this API doc 😅

## Events

### `CoinCollected`

Parameters:

- pickup
- coin
- value

### `CoinBatchSpawned`

Parameters:

- ped
- count

### `CoinDropFailed`

Parameters:

- ped

### `CoinSpawned`

Parameters:

- `coinPickup`: _`CoinPickup`_ - pickup coin object
- `ped`: _`integer`_ - ped that drops coin

### `CoinExpired`

Parameters:

- pickup
- age

### `CoinRemoved`

Parameters:

- pickup
- reason

### `PedKnockedOut`

Parameters:

- ped

### `BeforeCoinUpdate`

params:

none

### `AfterCoinUpdate`

params:

none

### `BeforeCoinUpdateAll`

params:

none

### `AfterCoinUpdateAll`

params:

none
