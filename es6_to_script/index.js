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
      import FlowToken from 0x1654653399040a61
      import FungibleToken from 0xf233dcee88fe0abe
      import CodeOfFlow from 0x24466f7fc36e3388

      transaction(nickname: String) {
        prepare(signer: AuthAccount) {
          let FlowTokenReceiver = signer.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)

          signer.save(<- CodeOfFlow.createPlayer(nickname: nickname, flow_vault_receiver: FlowTokenReceiver), to: CodeOfFlow.PlayerStoragePath)
          signer.link<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath, target: CodeOfFlow.PlayerStoragePath)
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
      import FlowToken from 0x1654653399040a61
      import FungibleToken from 0xf233dcee88fe0abe
      import CodeOfFlow from 0x24466f7fc36e3388

      transaction() {
        prepare(signer: AuthAccount) {
          let payment <- signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)!.withdraw(amount: 1.0) as! @FlowToken.Vault

          let player = signer.borrow<&CodeOfFlow.Player>(from: CodeOfFlow.PlayerStoragePath)
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
    import CodeOfFlow from 0x24466f7fc36e3388
    pub fun main(address: Address): &CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}? {
        let account = getAccount(address)
        return account.getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
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
    import CodeOfFlow from 0x24466f7fc36e3388
    pub fun main(address: Address): AnyStruct {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
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
    import CodeOfFlow from 0x24466f7fc36e3388
    pub fun main(address: Address, player_id: UInt): [[UInt16]] {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
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
    import CodeOfFlow from 0x24466f7fc36e3388
    pub fun main(address: Address, player_id: UInt): [UInt16] {
        let account = getAccount(address)
        let cap = account.getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
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
    import CodeOfFlow from 0x24466f7fc36e3388
    pub fun main(): {UInt16: CodeOfFlow.CardStruct} {
        return CodeOfFlow.getCardInfo()
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
    import FlowToken from 0x1654653399040a61
    import FungibleToken from 0xf233dcee88fe0abe
    import CodeOfFlow from 0x24466f7fc36e3388

    pub fun main(address: Address, player_id: UInt?): [CodeOfFlow.CyberScoreStruct] {
        let account = getAccount(address)
        let vaultRef = account.getCapability(/public/flowTokenBalance).borrow<&FlowToken.Vault{FungibleToken.Balance}>()
            ?? panic("Could not borrow Balance reference to the Vault")

        var retArr: [CodeOfFlow.CyberScoreStruct] = []
        if player_id != nil {
          let cap = getAccount(address).getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
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
        let guestData = CodeOfFlow.CyberScoreStruct(player_name: "Guest")
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
