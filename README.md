### Script to check the evm version issue with oogabooga team

The script tries to make a swap using a simple Swapper contract deployed on Bartio. The swapper contract is deployed in solidity version 0.8.19

The main issue is that the script fails in foundry when using EVM version shanghai. But works fine with evm version cancun.

### Note - FFI is enabled to run a CURL command using the bash shell and get OogaBooga API quote dynamically. [works only on linux and macOS].

### Testing the script
The following command runs the script in evm version shanghai and fails.
```
forge script script/OBSwap.s.sol --rpc-url bartio --broadcast --ffi
forge script script/OBSwap.s.sol --rpc-url bartio --broadcast --ffi --evm-version shanghai

The following command runs the script in evm version cancun and works fine.
forge script script/OBSwap.s.sol --rpc-url bartio --broadcast --ffi --evm-version cancun
```
