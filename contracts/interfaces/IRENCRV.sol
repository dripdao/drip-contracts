interface IRENCRV {
  function exchange(int128, int128, uint256, uint256) external;

  function get_dy(int128, int128, uint256) external view returns (uint256);
}