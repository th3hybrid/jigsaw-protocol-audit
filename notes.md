## Contracts

src/Holding.sol - basically a contract that will hold ether/ERC20 tokens for its designated manager,can approve,transfer and can use generic calls to send ether or to strategies(i guess) - it is initializable

src/HoldingManager.sol - used to manage holding by cloning/creating for each user(one per user),deposit into a holding with ERC20 tokens/WETH(adding collateral) by wrapping and withdraw from holding with ERC20 tokens/WETH(remove collateral) by unwrapping.can also borrow multiple tokens and repay loans but they are routed to stablesManager


- src/JigsawUSD.sol - normal ERC20 with mint limit and can only be minted/burned from by stablesManager
src/LiquidationManager.sol
src/Manager.sol
src/ReceiptToken.sol
src/ReceiptTokenFactory.sol
src/SharesRegistry.sol
src/StablesManager.sol - 
src/StrategyManager.sol
src/SwapManager.sol

## Dependencies/Libraries and interfaces

- src/libraries/OperationsLib.sol - this is a library used for fee calculations,and it also rounds up to prevent precision loss

- src/interfaces/IWETH.sol - basically an erc20 interface for WETH, where native ETH can be deposited and withdrawn

- src/interfaces/oracle/IOracle.sol - oracle interface for an underlying token and it should return underlying token,name, symbol and also peek rates IF available without changing state

- src/interfaces/core/IManager.sol - basis interface for liquidation,holding,strategy and stable coin managers,uses `IOracle`,it sets all necessary things a manager should set,like address of all managers,timelocks fees,set whitelists and blacklists of tokens and contract and which are withdrawable,it also handles `jUSD` oracles and underlying token

- src/interfaces/core/IHolding.sol - looks like a store for tokens and can can approve spending or transfer when called, can also make generic calls(maybe dangerous) ,sets an emergency invoker,stores general manager and can access it

- src/interfaces/core/IHoldingManager.sol - it manages `IHolding` to user mappings, user can create one holding,deposit/withdraw from the holding using whitelisted ERC20 tokens and WETH by wrapping and unwrapping.it stores manager which holds all necessary configs for protocol, can be paused and unpaused,can borrow/repay and can choose if to use msg.sender balance or holding of the msg.sender,declares BorrowData and RepayData structs

- src/interfaces/core/IJigsawUSD.sol - interface for jigsaw stablecoin contract, inherits `IERC20` and has mintLimit and can be changed,it is enforced while minting, there is also a burn and burnFrom

- src/interfaces/core/ILiquidationManager.sol - interface for contract that handles liquidations, self liquidations and liquidation of bad debt and all

- src/interfaces/core/IReceiptToken.sol - interface for a receipt token,basically inheriting `IERC20` can set owner and minter and only them can call mint,burnFrom

- src/interfaces/core/IReceiptTokenFactory.sol - an interface for creating receipt tokens by basically cloning the set reference implementation (whatever that is)

- src/interfaces/core/ISharesRegistry.sol - interface for the shares registry, declares a RegistryConfig struct that can be updated and all,regsiter and unregister collateral, oracle.it stores manager which holds all necessary configs for protocol,

- src/interfaces/core/IStablesManager.sol - interface that declares ShareRegistryInfo struct to track `SharesRegistry` state and also `BorrowTempData`which handles borrow stuff temporarily,stores mapping of token to `ShareRegistryInfo` which returns active state and deployed address,returns jUSD and manager which stores all protocol ,is responsible for minting and all,can add and remove collateral, also borrow/repay, pause/unpause

- src/interfaces/core/IStaker.sol - interface for a staking contract that can deposited into,withdraw from,claim rewards and all staking related functions

- src/interfaces/core/IStrategy.sol - This interface defines the standard functions and events for a strategy contract.The strategy allows for the deposit, withdrawal, and reward claiming functionalities.It also provides views for essential information about the strategy's token and rewards.it declares a `WithdrawParams` struct to be used,it handles deposits,withdrawals and reward claiming from strategies

- src/interfaces/core/IStrategyManagerMin.sol - minimalist strategy manager interface that returns strategy info

- src/interfaces/core/IStrategyManager.sol -inherits `IStrategyManagerMin`, declares StrategyInfo to manage strategies and also MoveInvestmentData for moving shares between strategies and ClaimInvestmentData to claim investments,basically handles investments into strategies

- src/interfaces/core/ISwapManager.sol - declares a couple of structs to handle swaps with UniswapV3,also handles the swap with uniV3
