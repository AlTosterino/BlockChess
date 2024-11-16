import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Chess", (m) => {
  const blockChess = m.contract("BlockChess", []);

  return { blockChess };
});