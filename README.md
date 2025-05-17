# 🧱 Subchain-X Smart Contract

Subchain-X is a lightweight, decentralized anchoring system for external data chains on the [Stacks blockchain](https://www.stacks.co). It allows off-chain systems (e.g., rollups, private ledgers, oracles) to commit block headers on-chain, enabling transparent verification of data integrity and sequence without storing the entire dataset on-chain.

---

## 🚀 Features

- ⛓️ **Decentralized Anchoring**: Record cryptographic summaries (e.g., Merkle roots) of off-chain blocks onto Stacks.
- 🔍 **On-Chain Verification**: Verify ancestry of any block by checking parent-child hash links.
- 👑 **Controlled Access**: Admin can assign who can submit block anchors.
- ⚙️ **Modular Design**: Extendable for L2 rollups, zk systems, or oracle feeds.

---

## 📄 Contract Functions

### `submit-block (block-hash hash, parent-hash hash, merkle-root hash, timestamp uint)`
Anchors a new off-chain block on the Stacks chain. Enforces correct chaining via `parent-hash`.

### `verify-link (child hash, parent hash)`
Returns `(bool)` whether `child` is properly linked to `parent`.

### `get-block (block-hash hash)`
Fetches metadata (parent hash, timestamp, Merkle root) of a block.

### `set-authority (new-authority principal)`
Allows the admin to update the address permitted to submit new blocks.

---

## 🛠️ How It Works

1. An authorized submitter (e.g., oracle or rollup node) sends block metadata using `submit-block`.
2. Each submitted block includes a hash pointer to its parent block.
3. Anyone can verify linkage between blocks using `verify-link`.
4. On-chain history forms a verifiable anchor tree for the off-chain data.

---

## 🧪 Example Use Cases

- ✅ Layer 2 rollups anchoring state transitions
- ✅ Private chains anchoring proof-of-history
- ✅ Oracle systems anchoring external API snapshots

---

## 🧰 Development

### Requirements
- [Clarinet](https://docs.stacks.co/write-smart-contracts/clarinet)
- Stacks CLI
- Node.js (for optional client)

### Run Tests
```bash
clarinet test
