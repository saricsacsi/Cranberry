pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
    );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
    constructor() public {
        owner = msg.sender;
    }

  /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
    modifier whenPaused() {
        require(paused);
        _;
    }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
    }

        c = a * b;
        assert(c / a == b);
        return c;
    }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

 /**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param _from address The address which you want to send tokens from
   * @param _value uint256 The amount of token to be burned
   */
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable{
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == owner);
        _;
    }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
    function mint(
        address _to,
        uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}


// ***********************************************************************************
// *************************** END OF THE BASIC **************************************
// ***********************************************************************************

contract CranberryToken is MintableToken, BurnableToken {
  // Coin Properties
    string public name = "CRANBERRY";
    string public symbol = "CRAN";
    uint256 public decimals = 18;

  // Special propeties
    bool public tradingStarted = false;

  /**
  * @dev modifier that throws if trading has not started yet
   */
    modifier hasStartedTrading() {
        require(tradingStarted);
        _;
    }

  /**
  * @dev Allows the owner to enable the trading. This can not be undone
  */
    function startTrading() public onlyOwner {
        tradingStarted = true;
    }

  /**
  * @dev Allows anyone to transfer the Cranberry tokens once trading has started
  * @param _to the recipient address of the tokens.
  * @param _value number of tokens to be transfered.
   */
    function transfer(address _to, uint _value) hasStartedTrading public returns (bool) {
        return super.transfer(_to, _value);
    }

  /**
  * @dev Allows anyone to transfer the Cranberry tokens once trading has started
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint the amout of tokens to be transfered
   */
    function transferFrom(address _from, address _to, uint _value) hasStartedTrading public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function emergencyERC20Drain( ERC20 oddToken, uint amount ) public {
        oddToken.transfer(owner, amount);
    }
}

contract CranberryTokenSale is Ownable, Pausable {

    using SafeMath for uint256;

  // The token being sold
    CranberryToken public token;
    uint256 public decimals;  
    uint256 public oneCoin;

  // start and end block where investments are allowed (both inclusive)
    uint256 public presaleStart;
    uint256 public presaleEnd;
    uint256 public publicsaleStart;
    uint256 public publicsaleEnd;
  

  // address where funds are collected

    address public cranberry_wallet;

    function setCranberryWallet(address _newCranberryWallet) public onlyOwner {
        cranberry_wallet = _newCranberryWallet;
    }

     
  // address where funds are collected

    address public developer_wallet;

    function setDeveloperWallet(address _newDeveloperWallet) public onlyOwner {
        developer_wallet = _newDeveloperWallet;
    }

    uint256 public rate;
    uint256 public minContribution;  // minimum contribution to participate in tokensale
    uint256 public maxContribution;  // default limit to tokens that the users can buy

  // ***************************
  // amount of raised money in wei
    uint256 public weiRaised;

  // amount of raised tokens
    uint256 public tokenRaised;

  // maximum amount of tokens being created
    uint256 public maxTokens;

  // maximum amount of tokens for presale
    uint256 public tokensForPreSale; 

  // amount of ether for developers fallowing the aggrement
    uint256 public amountForDev;  

    function setamountForDev(uint256 _newAmountForDev) public onlyOwner {
        amountForDev = _newAmountForDev;
    }

  // number of participants in presale
    uint256 public numberOfPurchasers = 0;

  //  for whitelist 
    address public Admin;
  

   

 
    bool    public freeForAll = false;

    function changeFreeForAll() public onlyOwner {
       if (freeForAll = true) 
            freeForAll = false;
       if (freeForAll = false) 
            freeForAll = true;     
    }

    mapping (address => bool) public authorised; 

    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenPlaced(address indexed beneficiary, uint256 amount); 
    event SaleClosed();

    constructor() public {
        presaleStart = 1535796000;
    // Human time (CET): 2018. szeptember 1., szombat 12:00:00 GMT+02:00
        presaleEnd = 1538301600;
    // Human time (CET): 2018. szeptember 30., vasárnap 12:00:00 GMT+02:00
        publicsaleStart = 1538388000;
    // Human time (CET): 2018. október 1., hétfő 12:00:00 GMT+02:00
        publicsaleEnd = 1540983600;
    // Human time (CET): 2018. október 31., szerda 12:00:00 GMT+01:00
    


// *************************************

        cranberry_wallet = 0xf651e2409120f1FbB0e47812d759e883b5B68A60;
        developer_wallet = 0xf651e2409120f1FbB0e47812d759e883b5B68A60;
//**************************************    

        token = new CranberryToken();
        decimals = token.decimals();
        oneCoin = 10 ** decimals;
        maxTokens = 1000 * (10**6) * oneCoin;  // max number of tokens what we will create    
        tokensForPreSale = 750 * (10**6) * oneCoin; // max number of tokens what we want to sell in presale
        amountForDev = 300 * oneCoin;       
      //  minContribution = 0.001 ether;
      //  maxContribution = 1000 ether;
    }
/**
  * @dev Calculates the rate in presale and publicsale
    */
    
    
    function getRate(uint256 _amount) internal view returns (uint256) {
        uint256 contribution = _amount.div(oneCoin);

        //if (now <= presaleEnd) {
    //  actualRate = getRate(amount);
    //} else 
    //  actualRate = rate;
    //}
        if (contribution < 50)
            return 48000;     
        if (contribution < 100)
            return 50000;
        if (contribution < 250)
            return 52000;
        if (contribution < 500)
            return 54000;
        if (contribution < 1000)
            return 56000;
        if (contribution < 2500)
            return 58000;
        else
            return 60000;
    }   

  // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        if (block.timestamp > publicsaleEnd)
        return true;
        if (tokenRaised >= maxTokens)
        return true; // if we reach the tokensForSale
        return false;
    }

  
    modifier onlyAdmin() {
        require(msg.sender == Admin);
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(msg.sender == Admin || msg.sender == owner);
        _;
    }

  /**
  * @dev throws if person sending is not authorised or sends nothing
  */
    modifier onlyAuthorised() {
        require (authorised[msg.sender] || freeForAll);
        require ((now >= presaleStart && presaleEnd >= now) || (now >= publicsaleStart && publicsaleEnd >= now));
        require (!hasEnded());
        require (cranberry_wallet != 0x0);
        require (developer_wallet != 0x0);
        require (msg.value > 1 finney);
        require(tokensForPreSale > tokenRaised); // check we are not over the number of tokensForSale
        _;
    }
  /**
  * @dev authorise an account to participate
  */
    function authoriseAccount(address whom) onlyAdmin public {
        authorised[whom] = true;
    }

  /**
  * @dev authorise a lot of accounts in one go
  */
    function authoriseManyAccounts(address[] many) onlyAdmin public {
        for (uint256 i = 0; i < many.length; i++) {
            authorised[many[i]] = true;
        }
    }

  /**
  * @dev ban an account from participation (default)
  */
    function blockAccount(address whom) onlyAdmin public {
        authorised[whom] = false;
    }

  /**
  * @dev set a new Admin representative
  */
    function setAdmin(address newAdmin) onlyOwner public {
        Admin = newAdmin;
    }
/**
  * @dev ONLY FOR TEST
  */
    //function setPreSaleDate(uint256 newDate) onlyOwner public {
    //    presaleStart = newDate;
    //}




    function placeTokens(address beneficiary, uint256 _tokens) onlyAdmin public {
        require(_tokens != 0);
        require(!hasEnded());
        require(tokenRaised.add(_tokens) <= maxTokens);

        if (token.balanceOf(beneficiary) == 0) {
            numberOfPurchasers++;
    }
        tokenRaised = tokenRaised.add(_tokens); // so we can go slightly over
        token.mint(beneficiary, _tokens);
        emit TokenPlaced(beneficiary, _tokens); 
    }

  // low level token purchase function
    function buyTokens(address beneficiary, uint256 amount) onlyAuthorised whenNotPaused internal {
        uint256 tokens;
        // actual rate
        uint256 actualRate;
        
    
    //check minimum and maximum amount
     //   require(msg.value >= minContribution);
     //   require(msg.value <= maxContribution);

    // Calculate token amount to be purchased 
        if (now <= presaleEnd) {
            actualRate = getRate(amount);
    } else 
      actualRate = 40000;      
    
        tokens = amount.mul(actualRate);  

    // check we are in the limit        
        require(tokenRaised.add(tokens) <= maxTokens);

    // update state
        weiRaised = weiRaised.add(amount);
        if (token.balanceOf(beneficiary) == 0) {
            numberOfPurchasers++;
    }

        tokenRaised = tokenRaised.add(tokens); 
 
    // mint the tokens to the buyer
        token.mint(beneficiary, tokens);
        emit TokenPurchase(beneficiary, amount, tokens);

    // send the ether to the hardwarewallet
        if (weiRaised <= amountForDev) {
            developer_wallet.transfer(this.balance);
    } else 
            cranberry_wallet.transfer(this.balance); // better in case any other ether ends up here
    }

  // transfer ownership of the token to the owner of the presale contract
    function finishSale() public onlyOwner {
        require(hasEnded());
    // assign the rest of the tokens to the reserve
        uint unassigned;
        if(maxTokens > tokenRaised) {
            unassigned = maxTokens.sub(tokenRaised);
            token.mint(cranberry_wallet,unassigned);
    }
        token.finishMinting();
        token.transferOwnership(owner);
        emit SaleClosed();
    }

  // fallback function can be used to buy tokens
    function () public payable {
        buyTokens(msg.sender, msg.value);
    }

    function emergencyERC20Drain( ERC20 oddToken, uint amount ) public {
        oddToken.transfer(owner, amount);
    }
}