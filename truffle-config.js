module.exports = {
  networks: {
    development: {
      host: "64.227.136.99",
      port: 8545,
      network_id: "5777" // Match any network id
    }
  },
  contracts_directory: "./contracts",
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  db: {
    enabled: false

  }
};
