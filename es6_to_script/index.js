import * as fcl from "@onflow/fcl"
import * as types from "@onflow/types"

fcl.config({
  "accessNode.api": "https://rest-testnet.onflow.org",
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn",
})

window.authenticate = fcl.authenticate;
window.unauthenticate = fcl.unauthenticate;
window.subscribe = fcl.currentUser.subscribe;
window.getAddr = function(user) {
  return user.addr;
};

// transactions
window.createPlayer = async (playerName) => {
  const transactionId = await fcl.mutate({
    cadence: `
      import CodeOfFlowAlpha15 from 0x9e447fb949c3f1b6

      transaction(nickname: String) {
        prepare(acct: AuthAccount) {
          acct.save(<- CodeOfFlowAlpha15.createPlayer(nickname: nickname), to: CodeOfFlowAlpha15.PlayerStoragePath)
          acct.link<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath, target: CodeOfFlowAlpha15.PlayerStoragePath)
          }
        execute {
          log("success")
        }
      }
    `,
    args: (arg, t) => [
      arg(playerName ? playerName : 'Test Player', t.String),
    ],
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 999
  })
  console.log(`TransactionId: ${transactionId}`);
};

// scripts
window.isRegistered = async function (address) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha15 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): &CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}? {
        let account = getAccount(address)
        return account.getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address)
    ]
  })
  return result;
};
window.getCurrentStatus = async function (address) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha15 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): AnyStruct {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address)
    ]
  });
  console.log(result);
  return result;
};
window.getMariganCards = async function (address, playerId) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha15 from 0x9e447fb949c3f1b6
    pub fun main(address: Address, player_id: UInt): [[UInt16]] {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards(player_id: player_id)
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address),
      arg(playerId, t.UInt)
    ]
  });
  console.log(result);
  return result
};
window.getCardInfo = async function () {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowAlpha15 from 0x9e447fb949c3f1b6
    pub fun main(): {UInt16: CodeOfFlowAlpha15.CardStruct} {
        return CodeOfFlowAlpha15.getCardInfo()
    }
    `,
    args: (arg, t) => [
    ]
  });
  console.log(result);
  return result
};
window.getBalance = async function (address) {
  const result = await fcl.query({
    cadence: `
    import FlowToken from 0x7e60df042a9c0868
    import FungibleToken from 0x9a0766d93b6608b7
    import CodeOfFlowAlpha15 from 0x9e447fb949c3f1b6

    pub fun main(address: Address): UFix64 {
        let account = getAccount(address)
        let vaultRef = account.getCapability(/public/flowTokenBalance).borrow<&FlowToken.Vault{FungibleToken.Balance}>()
            ?? panic("Could not borrow Balance reference to the Vault")
        let cap = account.getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
            ?? panic("Doesn't have capability!")
        let data = cap.get_current_status()
        return vaultRef.balance
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address),
    ]
  });
  console.log(result);
  return result
};
window.getPlayerName = function(player) {
  return player.nickname;
};
window.getPlayerId = function(player) {
  return player.player_id;
};
window.getPlayerUUId = function(player) {
  return player.uuid;
};
window.jsonToString = function(obj) {
  return JSON.stringify(obj);
};
