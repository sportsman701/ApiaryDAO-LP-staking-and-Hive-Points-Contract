pragma solidity ^0.8.0;

interface SharesInterface {
    
  function setToken(address contractAddress) external returns(bool);
    
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint256);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);
  
  function setAcceptnce(bool state) external;
  
  function increaseAllowance(address spender, uint256 addedValue) external;

  function decreaseAllowance(address spender, uint256 subtractedValue) external;

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
  function mint(address to, uint256 amount) external returns(bool);
  
  function burn(address user, uint256 amount) external returns(bool);
  
}

interface HiveInterface {
    
  function isAddress(address user) external view returns(bool);    
    
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint256);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);
  
  function stake(uint256 amount) external returns(bool);
  
  function stakingStats(address user) external view returns (uint256 staked, uint256 rewards, uint256 stakingBlock);
  
  function unstake(uint256 amount) external returns(bool);
  
  function claim(address user) external;
  
  function increaseAllowance(address spender, uint256 addedValue) external;

  function decreaseAllowance(address spender, uint256 subtractedValue) external;

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
}

contract HiveSharesToken is SharesInterface {
    
    HiveInterface public HPtoken;
    address private HPaddress;
    
    
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;
  
  mapping (address => bool) private _acceptence; //either a user accepts shares or not 

  uint256 private _totalSupply = 0;
  uint8 private _decimals = 18;
  string private _symbol = "HS";
  string private _name = "HiveShares";
  
  bool tokenSet = false;

  function setToken(address contractAddress) external override returns(bool){
      require(!tokenSet);
      HPtoken = HiveInterface(contractAddress);
      HPaddress = contractAddress;
      tokenSet = true;
      return true;
  }
  function decimals() external view override returns (uint256) {
        return _decimals;
  }
  function symbol() external view override returns (string memory) {
    return _symbol;
  }
  function name() external view override returns (string memory) {
    return _name;
  }
  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }
  function claim(address user) internal{
      HPtoken.claim(user);
  }
  
  function transfer(address recipient, uint256 amount) external override returns (bool) {
      require(_acceptence[recipient] == true);
      
      claim(msg.sender);
      claim(recipient);
      
    _balances[msg.sender] -= amount;
    _balances[recipient] += amount;
    
    return true;
  }
  
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
      require(_allowances[sender][msg.sender] >= amount);
      require(_acceptence[recipient] == true);
      
      claim(msg.sender);
      claim(recipient);
      
      _balances[sender] -= amount;
      _balances[recipient] += amount;
      
            _allowances[sender][msg.sender] -= amount;
    return true;
  }
  
  function setAcceptnce(bool state) external override{
      _acceptence[msg.sender] = state;
  }
  
  function mint(address to, uint256 amount) external override returns(bool) {
      require(HPtoken.isAddress(msg.sender));
      _balances[to] += amount;
      return true;
  }
  
  function burn(address user, uint256 amount) external override returns(bool) {
      require(HPtoken.isAddress(msg.sender));
      _balances[user] -= amount;
      return true;
  }
  
  function increaseAllowance(address spender, uint256 addedValue) external override {
      _allowances[msg.sender][spender] += addedValue;
  }


  function decreaseAllowance(address spender, uint256 subtractedValue) external override {
    if(subtractedValue > _allowances[msg.sender][spender]){_allowances[msg.sender][spender] = 0;}
      else {_allowances[msg.sender][spender] -= subtractedValue;}
  }
}
