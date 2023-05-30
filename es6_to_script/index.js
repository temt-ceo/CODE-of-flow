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
      import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

      transaction(nickname: String) {
        prepare(acct: AuthAccount) {
          acct.save(<- CodeOfFlowAlpha6.createPlayer(nickname: nickname), to: CodeOfFlowAlpha6.PlayerStoragePath)
          acct.link<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath, target: CodeOfFlowAlpha6.PlayerStoragePath)
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
window.isRegistered = async (address) => {
  const result = await this.$fcl.query({
    cadence: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): &CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address)
    ]
  })
  const player_id = result.player_id;
  return player_id;
}
window.getPlayerName = function(player) {
  return player.nickname;
};
window.getPlayerId = function(player) {
  return player.player_id;
};
window.getPlayerUUId = function(player) {
  return player.uuid;
};
