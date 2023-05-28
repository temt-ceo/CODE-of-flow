import * as fcl from "@onflow/fcl"
import * as types from "@onflow/types"

fcl.config({
  "accessNode.api": "https://rest-testnet.onflow.org",
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn",
})

window.authenticate = fcl.authenticate;
window.subscribe = fcl.currentUser.subscribe;
// transactions
window.createPlayer = async (playerName) => {
  const transactionId = await fcl.mutate({
    cadence: `
      import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

      transaction(nickname: String) {
        prepare(acct: AuthAccount) {
          // Step1
          acct.save(<- CodeOfFlowAlpha6.createPlayer(nickname: nickname), to: CodeOfFlowAlpha6.PlayerStoragePath)
          // Step2
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
