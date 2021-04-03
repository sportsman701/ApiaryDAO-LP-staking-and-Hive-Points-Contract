pragma solidity ^0.8.0;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);
  
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}

interface SharesInterface {
    
      function test() external returns(bool);
    
      function setToken(address contractAddress) external returns(bool);
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint256);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);
  
  function setAcceptnce(bool state) external returns(bool);
  
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
  function mint(address to, uint256 amount) external;
  
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
  
  function burn(uint256 amount) external returns(bool); 
  
  function burnFor(address user, uint256 amount) external returns(bool);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract HivePointsToken is HiveInterface {
    
    IBEP20 public token;
    SharesInterface public sharesToken;
    
    
  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;
  
  mapping (address => uint256) private _block;

  uint256 private _totalSupply = 0;
  uint8 private _decimals = 18;
  string private _symbol = "HP";
  string private _name = "HivePoints";
  
  function isAddress(address user) external view override returns(bool){
      if(user == address(this)){return true;}
      else{return false;}
  }
  bool tokenSet = false;
  function setToken(address contractAddress) external {
      require(!tokenSet);
      token = IBEP20(contractAddress);
      tokenSet = true;
  }
  
  bool tokenSet1 = false;
  function setShares(address contractAddress) external {
      require(!tokenSet1);
      sharesToken = SharesInterface(contractAddress);
      tokenSet1 = true;
  }
  function decimals() external view override returns (uint256) {
        return 18;
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
  function stakingStats(address user) external view override returns (uint256 staked, uint256 rewards, uint256 stakingBlock){
      staked = sharesToken.balanceOf(user);
      rewards = sharesToken.balanceOf(user) / 1000 * (block.number - _block[user]) * 1;
      stakingBlock = _block[user];
  }
  function claimRewards(address user) internal {
      uint256 reward = sharesToken.balanceOf(user) / 1000 * (block.number - _block[user]) * 1;
      _balances[user] += reward;
      _block[user] = block.number;
  }
  
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _balances[msg.sender] -= amount;
    _balances[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }
  
  function stake(uint256 amount) external override returns(bool){
      require(token.allowance(msg.sender, address(this)) >= amount);
      require(token.balanceOf(msg.sender) >= amount);
      
      claimRewards(msg.sender);
      
      token.transferFrom(msg.sender, address(this), amount);
      sharesToken.mint(msg.sender, amount);
      return true;
  }
  
  function unstake(uint256 amount) external override returns(bool){
      require(block.number - _block[msg.sender] >= 86400);
      require(sharesToken.balanceOf(msg.sender) >= amount);
      claimRewards(msg.sender);
      sharesToken.burn(msg.sender, amount);
      token.transfer(msg.sender, amount);
      return true;
  }
  
  function claim(address user) external override{
      claimRewards(user);
  }
  
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
      require(_allowances[sender][msg.sender] >= amount);
      _balances[sender] -= amount;
      _balances[recipient] += amount;
      _allowances[sender][msg.sender] -= amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }


  function increaseAllowance(address spender, uint256 addedValue) external override {
      _allowances[msg.sender][spender] += addedValue;
  }


  function decreaseAllowance(address spender, uint256 subtractedValue) external override {
      if(subtractedValue > _allowances[msg.sender][spender]){_allowances[msg.sender][spender] = 0;}
      else {_allowances[msg.sender][spender] -= subtractedValue;}
  }
  
  function burn(uint256 amount) external override returns(bool){
      _balances[msg.sender] -= amount;
      return true;
  }
  
  function burnFor(address user, uint256 amount) external override returns(bool){
      require(_allowances[user][msg.sender] >= amount);
      _balances[user] -= amount;
      _allowances[user][msg.sender] -= amount;
      return true;
  }
}
