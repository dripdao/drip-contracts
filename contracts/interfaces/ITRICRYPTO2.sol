interface ITRICRYPTO2 {
  function calc_withdraw_one_coin(uint256, uint256) external view returns (uint256);

  function add_liquidity(uint256[3] calldata, uint256) external;
}