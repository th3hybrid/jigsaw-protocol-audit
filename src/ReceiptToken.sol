// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IReceiptToken } from "./interfaces/core/IReceiptToken.sol";

/**
 * @title ReceiptToken
 * @dev Token minted when users invest into strategies based on Curve LP Token.
 *
 * @dev This contract inherits functionalities from `Context`, `ReentrancyGuard` and `Ownable`.
 *
 * @author Hovooo (@hovooo).
 *
 * @custom:security-contact support@jigsaw.finance
 */
contract ReceiptToken is IReceiptToken, Context, Initializable, ReentrancyGuard, Ownable {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    bool private initialized;

    address public minter;

    // --- Constructor ---

    /**
     * @dev To prevent the implementation contract from being used, the _disableInitializers function is invoked
     * in the constructor to automatically lock it when it is deployed.
     */
    constructor(address _receiptTokenFactory) Ownable(_receiptTokenFactory) {
        _disableInitializers();
    }

    // --- Initialization ---

    /**
     * @notice This function initializes the contract (instead of a constructor) to be cloned.
     *
     * @notice Requirements:
     * - The contract must not be already initialized.
     * - The `__minter` must not be the zero address.
     *
     * @notice Effects:
     * - Sets `_initialized` to true.
     * - Updates `_name`, `_symbol`, `minter` state variables.
     * - Stores `__owner` as owner.
     *
     * @param __name Receipt token name.
     * @param __symbol Receipt token symbol.
     * @param __minter Receipt token minter.
     * @param __owner Receipt token owner.
     */
    function initialize(
        string memory __name,
        string memory __symbol,
        address __minter,
        address __owner
    ) external override {
        require(!initialized, "3072");
        require(__minter != address(0), "3065");

        // Set contract initialized.
        initialized = true;

        // Set token metadata.
        _name = __name;
        _symbol = __symbol;
        minter = __minter;

        if (__owner != owner()) transferOwnership(__owner);
    }

    /**
     * @notice Mints receipt tokens.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     *
     * @notice Effects:
     * - Mints the specified amount of tokens to the given address.
     *
     * @param _user Address of the user receiving minted tokens.
     * @param _amount The amount to be minted.
     */
    function mint(address _user, uint256 _amount) external override nonReentrant onlyMinterOrOwner {
        _mint(_user, _amount);
    }

    /**
     * @notice Burns tokens from an address.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     *
     * @notice Effects:
     * - Burns the specified amount of tokens from the specified address.
     *
     * @param _user The user to burn it from.
     * @param _amount The amount of tokens to be burnt.
     */
    function burnFrom(address _user, uint256 _amount) external override nonReentrant onlyMinterOrOwner {
        _burn(_user, _amount);
    }

    /**
     * @notice Sets minter.
     *
     * @notice Requirements:
     * - Must be called by the Minter or Owner of the Contract.
     * - The `_minter` must be different from `minter`.
     *
     * @notice Effects:
     * - Updates minter state variable.
     *
     * @notice Emits:
     * - `MinterUpdated` event indicating minter update operation.
     *
     * @param _minter The user to burn it from.
     */
    function setMinter(address _minter) external override nonReentrant onlyMinterOrOwner {
        require(_minter != minter, "3062");
        emit MinterUpdated(minter, _minter);
        minter = _minter;
    }

    /**
     * @dev Renounce ownership override to avoid losing contract's ownership.
     */
    function renounceOwnership() public pure override {
        revert("1000");
    }

    // -- Default ERC20 implementation --

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address _owner = _msgSender();
        _transfer(_owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address _owner, address spender) public view virtual returns (uint256) {
        return _allowances[_owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address _owner = _msgSender();
        _approve(_owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `_owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address _owner, address spender, uint256 value) internal {
        _approve(_owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address _owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (_owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[_owner][spender] = value;
        if (emitEvent) {
            emit Approval(_owner, spender, value);
        }
    }

    /**
     * @dev Updates `_owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address _owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(_owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(_owner, spender, currentAllowance - value, false);
            }
        }
    }

    // -- Modifiers --

    modifier onlyMinterOrOwner() {
        require(msg.sender == minter || msg.sender == owner(), "1000");
        _;
    }
}
