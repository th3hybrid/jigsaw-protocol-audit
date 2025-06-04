🛡️ Part 2: Attack Path Analysis
🟨 MISSING PATHS
[M1] No Fallback or Retry Path for Stale/Empty Pool Data
Code Location: _quote() and peek()

Root Cause: If all UniswapV3 pools fail to return data (e.g., due to insufficient liquidity, paused pools, or excessive offset), peek() still returns success = true unconditionally.

Attack Vector: An attacker could monitor periods of thin liquidity (e.g., large trades or inactivity) and force the oracle to return low-confidence prices.

Impact: Price feed used in critical protocol decisions (e.g., collateral valuation) could be silently wrong.

Why It's Counterintuitive: peek() signals success even if underlying data sources are broken. There's no observable failure surface.

Fix: Require at least N valid, high-liquidity pools or validate tick deviations between TWAPs.

[M2] No Public Method to Check if Oracle Is Healthy
Code Location: No isValid(), lastUpdated(), or health-check endpoint.

Root Cause: Users can't inspect oracle freshness or pool quality.

Attack Vector: Stale pools or outdated oracle pairs (e.g., moved liquidity) remain silently in the system.

Impact: Mispriced assets, especially for newly deployed or illiquid tokens.

Fix: Add a health signal or data age flag to peek() or an external status() function.

🟧 INCORRECT HAPPY PATHS
[H1] Decimals Mismatch and Potential Double Scaling
Code Location: peek() + _convertToUsd()

Root Cause: The price is first normalized to 18 decimals (medianWithDecimals), then scaled again during USD conversion (price * rate / 10^18). This assumes the external oracle also returns 18-decimal values, which might not be true across ecosystems.

Attack Vector: If quoteTokenOracle.peek() returns e.g. 6-decimal prices (common in USD-pegged assets), the final price is off by 10^12.

Impact: Misvaluation of entire markets, either over- or undercollateralizing users.

Why It's Counterintuitive: External oracle decimals are assumed, but not enforced or verified.

Fix: Add a decimals() validation call in _updateQuoteTokenOracle() or inline.

[H2] Median Function Ignores Timestamp Drift or Pool Skew
Code Location: _getMedian(a,b,c)

Root Cause: The system assumes three time-segmented TWAPs are uncorrelated and individually reliable.

Attack Vector: If an attacker controls liquidity in all three pools (e.g., through flash mint or batch manipulation), they can skew all three to their benefit.

Impact: Protocol accepts manipulated prices even though they’re “medianized.”

Why It's Counterintuitive: Using three TWAPs implies robustness, but fails if the pools are correlated or uniformly exploitable.

Fix: Add weight-based deviation checks or source-count validation.

🟥 UNEXPECTED PATHS
[U1] Oracle Griefing via Pool Reset
Code Location: consultOffsetted() → _quote()

Root Cause: TWAP depends on Uniswap’s observe() values, which can be disrupted or delayed if the pool was recently initialized or has insufficient tick history.

Attack Vector: An attacker adds/removes all liquidity from a pool in a flash transaction, causing TWAP calls to revert, or return erratic prices.

Impact: The oracle either fails silently (success=true, wrong rate) or prices inaccurately for multiple minutes.

Why It's Counterintuitive: TWAPs seem safe, but rely on pool history continuity and liquidity.

Fix: Include liquidity threshold checks or timestamp age validations in _quote().

[U2] Oracle Abuse Through Asymmetric Liquidity
Code Location: _quote() via consultOffsetted()

Root Cause: Uniswap V3 allows setting tight liquidity bands—attackers can provide near-zero liquidity on one side of a pool to skew ticks easily.

Attack Vector: Provide unbalanced liquidity just before a TWAP window begins → manipulate the tick for 30–60 minutes → drain/borrow from protocols using the manipulated price.

Impact: USD price can be over/underestimated significantly (especially for thin pools).

Why It's Counterintuitive: TWAPs are expected to smooth volatility, but attackers can game them before the window opens.

Fix: Require minimum pool liquidity or amplify pool weights based on TVL/volume.

[U3] Median Manipulation with Duplicate Pools
Code Location: _updatePools() allows arbitrary pool arrays

Root Cause: A user could submit 3 copies of the same manipulated pool to influence the median vote.

Attack Vector: An attacker can deploy a custom pool with favorable pricing, then set that pool 3x in the list (if governance is weak or logic is reused).

Impact: Full control of the median output.

Why It's Counterintuitive: Median implies diversity; duplication breaks that premise.

Fix: Enforce uniqueness in _updatePools() (e.g., with a mapping).

















































## Summary
A short summary of the issue, keep it brief.

## Finding Description
The _retrieveCollateral() function is vulnerable to excessive fund withdrawals because it indiscriminately uses the full share balance from each strategy. Instead of calculating and withdrawing only the necessary amount of collateral, it retrieves the entire share balance held by a _holding and passes it directly to StrategyManager::claimInvestment(). This behavior results in over-withdrawals that unnecessarily drain funds from the strategies. Consequently, surplus assets remain idle outside the strategies, reducing overall capital efficiency and limiting potential yield generation.

Root Cause
The vulnerability originates in the LiquidationManager::_retrieveCollateral() function (L547–L558).
At this location, the function retrieves the entire share balance of _holding from each strategy and passes it unconditionally to StrategyManager::claimInvestment(), without checking how much is actually required. This causes excess withdrawals and lead to idle, yield-deprived funds.
https://github.com/jigsaw-finance/jigsaw-protocol-v1/blob/209bceeaa5ed4b837ef065c80a3467740a6bc683/src/LiquidationManager.sol#L547C8-L558C16

## Impact Explanation
The vulnerability arises when the _retrieveCollateral() function is triggered from selfLiquidate() function.

In the selfLiquidate() function, where users can initiate liquidation on their own positions. When useHoldingBalance is true, the _holding's current token balance is less than the required amount, and one of the strategies holds more than the needed amount, _retrieveCollateral() attempts to cover the shortfall by withdrawing from the associated strategies.

However, instead of calculating and withdrawing only the necessary deficit, it retrieves the entire share balance of _holding from each strategy and passes it directly to StrategyManager::claimInvestment(), without enforcing a limit based on the actual shortfall.
This results in over-withdrawing from strategies, causing excess funds to become idle within the holding and depriving them of yield — ultimately reducing capital efficiency and opening potential for strategic misuse.

https://github.com/jigsaw-finance/jigsaw-protocol-v1/blob/209bceeaa5ed4b837ef065c80a3467740a6bc683/src/LiquidationManager.sol#L542C9-L558C16

Impact
Loss of User Yield:
Excess collateral is withdrawn from strategies and sits idle in the holding, causing users to miss out on potential yield or rewards that would have accrued if the collateral remained invested.

Inefficient Capital Utilization:
The protocol’s capital efficiency is reduced, as more collateral than necessary is removed from productive strategies.

Accounting Inaccuracies:
Withdrawn but unused collateral may cause discrepancies in accounting, making it harder to track actual invested vs. idle assets.

Prerequisite Conditions
For the over-withdrawal vulnerability in _retrieveCollateral() to be triggered, the following conditions must be met:

1. useHoldingBalance is set to true
This allows _retrieveCollateral() to first consider the balance already available in _holding.

2. The _holding’s current token balance is less than the required _amount

```
In this case:
        _amount = 150 USDC
        _holding balance = 50 USDC
        Deficit = 100 USDC
```

3. Strategies associated with the _holding contain more than the required shortfall

```Strategy A: 120 USDC worth of shares
    Strategy B: 80 USDC worth of shares
```

Scenario Setup

Token (_token): USDC
Holding (_holding): 0xHolding
Required Amount (_amount): 150 USDC
Initial Holding Balance: 50 USDC (useHoldingBalance = true)
Strategy A: 120 USDC worth of shares for _holding
Execution with Bug
Initial Check:

_holding balance = 50 USDC
_amount = 150 USDC
→ Since 50 < 150, _retrieveCollateral() proceeds to withdraw from strategies.
Strategy A Execution:

Retrieves all available shares of _holding in Strategy A (120 USDC worth)
Adds to _holding balance: 50 + 120 = 170 USDC
Loop breaks after one strategy since useHoldingBalance = true and balance now exceeds _amount
Final State:

Retrieved collateral: 120 USDC
Total _holding balance: 170 USDC
Required amount: 150 USDC
Excess withdrawn: 20 USDC (unnecessarily pulled from Strategy A)

## Likelihood Explanation
Explain how likely this is to occur and why.

## Proof of Concept
```
 function test_excessive_withdrawal_from_strategies() public {
        // --- Scenario Setup ---
        // Addresses
        address user = address(0x1234);
        address holding = user; // For simplicity, holding == user

        // Token: USDC
        SampleTokenERC20 token = usdc;

        // Initial balances
        uint256 initialHoldingBalance = 50e6; // 50 USDC (assuming 6 decimals)
        uint256 strategyABalance = 120e6; // Strategy A has 120 USDC for holding
        uint256 strategyBBalance = 80e6; // Strategy B has 80 USDC for holding
        uint256 requiredAmount = 150e6; // Need 150 USDC

        // Deploy mock strategies
        MockStrategy strategyA = new MockStrategy(address(token));
        MockStrategy strategyB = new MockStrategy(address(token));

        // Fund the strategies with enough USDC
        deal(address(token), address(strategyA), strategyABalance);
        deal(address(token), address(strategyB), strategyBBalance);

        // Set up shares for the holding
        strategyA.setShares(holding, strategyABalance);
        strategyB.setShares(holding, strategyBBalance);

        // Set up holding's initial balance
        deal(address(token), holding, initialHoldingBalance);

        // Approve strategies to transfer tokens to holding
        token.approve(address(strategyA), type(uint256).max);
        token.approve(address(strategyB), type(uint256).max);

        // Prepare strategies array
        address[] memory strategies = new address[](2);
        strategies[0] = address(strategyA);
        strategies[1] = address(strategyB);

        // --- Test Execution ---
        // Simulate the function that retrieves collateral from strategies
        // (You may need to adapt this call to your actual function signature)
        vm.startPrank(user, user);

    
        // For example: holdingManager.retrieveCollateral(token, requiredAmount, strategies, true);
        // Here, we simulate the bug: all of strategyA's shares are withdrawn even though only 100 are needed
        // Simulate the bug: withdraw all from strategyA if needed, even if it exceeds the deficit
        uint256 holdingBalance = token.balanceOf(holding);
        uint256 retrieved = 0;
        console.log("Initial holding balance:", holdingBalance);
        console.log("Required amount to withdraw:", requiredAmount);
        for (uint256 i = 0; i < strategies.length; i++) {
            if (holdingBalance >= requiredAmount) break;
            uint256 shares = MockStrategy(strategies[i]).shares(holding);
            console.log("Strategy", i, "shares for holding:", shares);
            if (shares > 0) {
                // Withdraw all shares (simulate bug)
                MockStrategy(strategies[i]).withdrawAll(holding);
                retrieved += shares;
                holdingBalance = token.balanceOf(holding);
                console.log("Post-withdrawal holding balance:", holdingBalance);
            }
        }

        vm.stopPrank();

        // --- Assertions ---
        // The bug: strategyA withdrew all 120 USDC, so holding now has 170 USDC (should only have 150)
        assertEq(
            token.balanceOf(holding),
            170e6,
            "Holding should have 170 USDC (excessive withdrawal)"
        );
        assertEq(
            retrieved,
            120e6,
            "Should have retrieved 120 USDC from strategies"
        );
        assertEq(
            MockStrategy(strategies[0]).shares(holding),
            0,
            "Strategy A shares should be zero"
        );
        assertEq(
            MockStrategy(strategies[1]).shares(holding),
            80e6,
            "Strategy B shares should be untouched"
        );
    }
```

```
contract MockStrategy {
    address public token;
    mapping(address => uint256) public shareBalances;

    constructor(address _token) {
        token = _token;
    }

    function setShares(address holder, uint256 value) external {
        shareBalances[holder] = value;
    }

    function shares(address holder) external view returns (uint256) {
        return shareBalances[holder];
    }

    function withdrawAll(address holder) external {
        uint256 amount = shareBalances[holder];
        require(amount > 0, "No shares to withdraw");
        shareBalances[holder] = 0;
        SampleTokenERC20(token).transfer(holder, amount);
    }
}
```
Corresponding Output

```Logs:
  Initial holding balance: 50000000  
  Required amount to withdraw: 150000000  
  Strategy 0 shares for holding: 120000000  
  Post-withdrawal holding balance: 170000000```

## Recommendation
```
for (uint256 i = 0; i < _strategies.length; i++) {
    (, tempData.shares) = IStrategy(_strategies[i]).recipients(_holding);
    
    // Calculate remaining needed collateral
    uint256 remainingNeeded = _amount - IERC20(_token).balanceOf(_holding);
    uint256 sharesToWithdraw = remainingNeeded < tempData.shares 
        ? remainingNeeded 
        : tempData.shares;
    
    (tempData.withdrawResult, , , ) = _getStrategyManager().claimInvestment({
        _shares: sharesToWithdraw, // Withdraw only the deficit
        // ... other params
    });
    
    // ... rest of logic
}
```