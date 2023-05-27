import * as fcl from "@onflow/fcl"

fcl.config({
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn",
})

window.authenticate = () => fcl.authenticate();
window.subscribe = fcl.currentUser.subscribe;