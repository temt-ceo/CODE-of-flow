import * as fcl from "@onflow/fcl"
import * as types from "@onflow/types"

fcl.config({
  "accessNode.api": "https://rest-testnet.onflow.org",
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn"
});

window.authenticate = fcl.authenticate;
window.unauthenticate = fcl.unauthenticate;
window.subscribe = fcl.currentUser.subscribe;
window.getAddr = function(user) {
  return user.addr;
};

// transactions
window.createPlayer = async function (playerName) {
  var transactionId = await fcl.mutate({
    cadence: `
      import FlowToken from 0x7e60df042a9c0868
      import FungibleToken from 0x9a0766d93b6608b7
      import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6

      transaction(nickname: String) {
        prepare(signer: AuthAccount) {
          let FlowTokenReceiver = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

          signer.save(<- CodeOfFlowBeta3.createPlayer(nickname: nickname, flow_vault_receiver: FlowTokenReceiver), to: CodeOfFlowBeta3.PlayerStoragePath)
          signer.link<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath, target: CodeOfFlowBeta3.PlayerStoragePath)
          }
        execute {
          log("success")
        }
      }
    `,
    args: function args(arg, t) {
      return [arg(playerName ? playerName : 'Test Player', t.String)];
    },
    proposer: fcl.authz,
    payer: fcl.authz,
    authorizations: [fcl.authz],
    limit: 999
  });
  console.log("TransactionId: " + transactionId);
};
window.buyCyberEN = async () => {
  const transactionId = await fcl.mutate({
    cadence: `
      import FlowToken from 0x7e60df042a9c0868
      import FungibleToken from 0x9a0766d93b6608b7
      import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6

      transaction() {
        prepare(signer: AuthAccount) {
          let payment <- signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!.withdraw(amount: 1.0) as! @FlowToken.Vault

          let player = signer.borrow<&CodeOfFlowBeta3.Player>(from: CodeOfFlowBeta3.PlayerStoragePath)
              ?? panic("Could not borrow reference to the Owner's Player Resource.")
          player.buy_en(payment: <- payment)
        }
        execute {
          log("success")
        }
      }
    `,
    args: (arg, t) => [
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
    import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): &CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}? {
        let account = getAccount(address)
        return account.getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
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
    import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6
    pub fun main(address: Address): AnyStruct {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
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
    import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6
    pub fun main(address: Address, player_id: UInt): [[UInt16]] {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards(player_id: player_id)
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address),
      arg(playerId, t.UInt)
    ]
  });
  // console.log(result);
  return result
};
window.getPlayerDeck = async function (address, playerId) {
  const result = await fcl.query({
    cadence: `
    import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6
    pub fun main(address: Address, player_id: UInt): [UInt16] {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_dlayer_deck(player_id: player_id)
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
    import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6
    pub fun main(): {UInt16: CodeOfFlowBeta3.CardStruct} {
        return CodeOfFlowBeta3.getCardInfo()
    }
    `,
    args: (arg, t) => [
    ]
  });
  console.log(result);
  return result
};

window.getBalance = async function (address, playerId) {
  const result = await fcl.query({
    cadence: `
    import FlowToken from 0x7e60df042a9c0868
    import FungibleToken from 0x9a0766d93b6608b7
    import CodeOfFlowBeta3 from 0x9e447fb949c3f1b6

    pub fun main(address: Address, player_id: UInt?): [CodeOfFlowBeta3.CyberScoreStruct] {
        let account = getAccount(address)
        let vaultRef = account.getCapability(/public/flowTokenBalance).borrow<&FlowToken.Vault{FungibleToken.Balance}>()
            ?? panic("Could not borrow Balance reference to the Vault")

        var retArr: [CodeOfFlowBeta3.CyberScoreStruct] = []
        if player_id != nil {
          let cap = getAccount(address).getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
              ?? panic("Doesn't have capability!")

          let player_arr = cap.get_players_score()

          let playerCyberData = player_arr[0]
          playerCyberData.balance = vaultRef.balance
          retArr.append(playerCyberData)
          if player_arr.length >= 2 {
            retArr.append(player_arr[1])
          }
          return retArr
        }
        let guestData = CodeOfFlowBeta3.CyberScoreStruct(player_name: "Guest")
        guestData.balance = vaultRef.balance
        retArr.append(guestData)
        return retArr
    }
    `,
    args: (arg, t) => [
      arg(address, t.Address),
      arg(playerId, t.Optional(t.UInt)),
    ]
  });
  // console.log(result);
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
