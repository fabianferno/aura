const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("AuraModule", (m) => {
  const aura = m.contract("Aura", []);

  return { aura };
});
