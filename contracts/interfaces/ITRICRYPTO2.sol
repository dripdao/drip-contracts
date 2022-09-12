interface ITRICRYPTO2 {
  function calc_withdraw_one_coin(uint256, uint256) external view returns (uint256);

  function add_liquidity(uint256[3] calldata, uint256) external;

  function remove_liquidity(uint256, uint256[2] calldata) external;

  function remove_liquidity_one_coin(uint256, int128, uint256) external;
}