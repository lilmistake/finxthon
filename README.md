# Blockchain-Based Supply Chain Tracker with Q2
## Description

This project is a blockchain-based application designed for tracking products in a supply chain. Leveraging the power of Ethereum blockchain and IPFS, it provides transparency and traceability from raw materials to the final product. Users can trace the origin, production, and distribution of products, ensuring authenticity and quality.

## Installation

### Prerequisites

- Node.js (Download from [nodejs.org](https://nodejs.org/))
- IPFS (Kubo) (Instructions at [ipfs.io](https://ipfs.io))
- Ganache CLI / Ganache GUI (CLI: `npm install -g ganache`, GUI: [trufflesuite.com/ganache](https://www.trufflesuite.com/ganache))
- Flutter (For mobile app development, instructions at [flutter.dev](https://flutter.dev))
- A text editor or IDE of your choice (e.g., VS Code, IntelliJ)

### Setting Up the Environment

1. **Install Node.js**:
   - Follow the installation guide on the official Node.js website.

2. **Install IPFS (Kubo)**:
   - Refer to the official IPFS documentation for installation instructions.

3. **Install Ganache**:
   - Choose either the CLI or GUI version based on your preference.

4. **Set Up Flutter**:
   - Follow the Flutter installation guide for your operating system.

### Running IPFS

1. Start the IPFS daemon:
```
ipfs daemon
```

### Running Ganache

1. **For CLI**:
```
ganache-cli --host 0.0.0.0
```
2. **For GUI**:
- Launch Ganache and configure a new workspace.

## Deployment

### Deploying Smart Contracts

1. Deploy your smart contracts to Ganache:
- Navigate to your project's root directory.
- Run the deployment script:
  ```
  truffle migrate --reset
  ```

## Usage

### Starting the Application

1. **Start the Flutter Application**:
- Navigate to the Flutter project directory.
- Run the app:
  ```
  flutter run
  ```

### Interacting with the Application

- The app allows users to create product batches, track raw materials, and view product histories.
- To create a new batch, navigate to the 'Create Batch' section and enter the product details.
- To view the history of a product, enter its batch ID in the 'Track Product' section.

## Troubleshooting

- **IPFS Daemon Not Starting**: Ensure that there are no conflicts on the IPFS ports and that your firewall settings allow IPFS traffic.
- **Ganache Connection Issues**: Verify that Ganache is running and that your application's configuration points to the correct RPC URL.
