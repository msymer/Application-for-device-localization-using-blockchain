const Tracker = artifacts.require("Tracker");
const TrackerBackgroundProcesses = artifacts.require("TrackerBackgroundProcesses");

async function doDeploy(deployer) {
  await deployer.deploy(Tracker);
  await deployer.deploy(TrackerBackgroundProcesses, Tracker.address);
}

module.exports = (deployer) => {
  deployer.then(async () => {
      await doDeploy(deployer);
  });
};
