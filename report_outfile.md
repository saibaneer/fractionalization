## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| contracts/AssetFactory.sol | [object Promise] |
| contracts/EntryPoint.sol | [object Promise] |
| contracts/FactoryInternalLogic.sol | [object Promise] |
| contracts/Getters.sol | [object Promise] |
| contracts/InternalLogic.sol | [object Promise] |
| contracts/Permissions.sol | [object Promise] |
| contracts/Setters.sol | [object Promise] |
| contracts/Storage.sol | [object Promise] |
| contracts/Vault.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **AssetFactory** | Implementation | FactoryInternalLogic |||
| └ | createNewAsset | Public ❗️ | 🛑  |NO❗️ |
| └ | updateAssetUrl | Public ❗️ | 🛑  |NO❗️ |
| └ | getAssetUrl | Public ❗️ |   |NO❗️ |
| └ | getAsset | Public ❗️ |   |NO❗️ |
| └ | deleteAsset | Public ❗️ | 🛑  |NO❗️ |
||||||
| **EntryPoint** | Implementation | Setters, Getters, InternalLogic |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | enterPosition | Public ❗️ | 🛑  |NO❗️ |
| └ | exitPosition | Public ❗️ | 🛑  |NO❗️ |
||||||
| **FactoryInternalLogic** | Implementation | Storage |||
| └ | _createNewAsset | Internal 🔒 | 🛑  | onlyAdmin |
| └ | _updateAssetUrl | Internal 🔒 | 🛑  | onlyAdmin |
| └ | _deleteAsset | Internal 🔒 | 🛑  | onlyAdmin |
||||||
| **Getters** | Implementation | Storage |||
| └ | contractAssetHasExited | Public ❗️ |   |NO❗️ |
| └ | getVaultAddress | Public ❗️ |   |NO❗️ |
| └ | isTokenAllowed | Public ❗️ |   |NO❗️ |
| └ | getAssetUrl | Public ❗️ |   |NO❗️ |
| └ | getAssetExchangeRate | Public ❗️ |   |NO❗️ |
| └ | getDiscountFactor | Public ❗️ |   |NO❗️ |
||||||
| **InternalLogic** | Implementation | Storage |||
| └ | _enterPosition | Public ❗️ | 🛑  |NO❗️ |
| └ | _exitPosition | Public ❗️ | 🛑  | onlyHolder |
||||||
| **Permissions** | Implementation | AccessControl |||
| └ | hasSetterRole | Public ❗️ |   |NO❗️ |
| └ | hasAdminRole | Public ❗️ |   |NO❗️ |
| └ | hasMultisigControllerRole | Public ❗️ |   |NO❗️ |
| └ | hasHolderRole | Public ❗️ |   |NO❗️ |
||||||
| **Setters** | Implementation | Storage |||
| └ | setAllowedToken | Internal 🔒 | 🛑  | differentValue onlySetter |
| └ | setVaultAddress | Internal 🔒 | 🛑  | notZeroAddress onlySetter |
| └ | setAssetExchangeRate | Internal 🔒 | 🛑  | notZeroAddress valueChanged onlySetter |
| └ | setDiscountFactor | Internal 🔒 | 🛑  | validDiscountFactor onlySetter |
||||||
| **Storage** | Implementation | Permissions |||
||||||
| **Vault** | Implementation | Storage |||
| └ | withdrawTo | Public ❗️ | 🛑  | onlyMultisigController |
| └ | getBalance | Public ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
