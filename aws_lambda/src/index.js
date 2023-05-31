const fs = require('fs');
const fcl = require("@onflow/fcl");
const t = require("@onflow/types");
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");
const { SHA3 } = require("sha3");

const FlowTransactions = {
  matchingStart: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.matching_start(player_id: player_id)
      }
      execute {
        log("success")
      }
    }
  `,
  gameStart: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32, drawed_cards: [UInt16]) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.game_start(player_id: player_id, drawed_cards: drawed_cards)
      }
      execute {
        log("success")
      }
    }
  `,
  putCardOnField: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32, unit_card: {UInt8: UInt16}, enemy_skill_target: UInt8?, trigger_cards: {UInt8: UInt16}, used_intercept_positions: [UInt8]) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.put_card_on_the_field(player_id: player_id, unit_card: unit_card, enemy_skill_target: enemy_skill_target, trigger_cards: trigger_cards, used_intercept_positions: used_intercept_positions)
      }
      execute {
        log("success")
      }
    }
  `,
  turnChange: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32, attacking_cards: [UInt8], enemy_skill_target: {UInt8: UInt8}, trigger_cards: {UInt8: UInt16}, used_intercept_position: {UInt8: [UInt8]}) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.turn_change(player_id: player_id, attacking_cards: attacking_cards, enemy_skill_target: enemy_skill_target, trigger_cards: trigger_cards, used_intercept_position: used_intercept_position)
      }
      execute {
        log("success")
      }
    }
  `,
  startYourTurn: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32, blocked_unit: {UInt8: UInt8}, used_intercept_position: {UInt8: UInt8}) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.start_your_turn_and_draw_two_cards(player_id: player_id, blocked_unit: blocked_unit, used_intercept_position: used_intercept_position)
      }
      execute {
        log("success")
      }
    }
  `,
  surrendar: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.surrendar(player_id: player_id)
      }
      execute {
        log("success")
      }
    }
  `,
  claimWin: `
    import CodeOfFlowAlpha6 from 0x9e447fb949c3f1b6

    transaction(player_id: UInt32) {
      prepare(signer: AuthAccount) {
        let admin = signer.borrow<&CodeOfFlowAlpha6.Admin>(from: CodeOfFlowAlpha6.AdminStoragePath)
          ?? panic("Could not borrow reference to the Administrator Resource.")
        admin.claimWin(player_id: player_id)
      }
      execute {
        log("success")
      }
    }
  `,
}

exports.handler = async function (event) {
  console.log("Event", JSON.stringify(event, 3))
  const input = event.arguments?.input || {};

  let player_id;
  let message;
  var KEY_ID_IT = 1
  if (fs.existsSync('/tmp/sequence.txt')) {
    KEY_ID_IT = parseInt(fs.readFileSync('/tmp/sequence.txt', {encoding: 'utf8'}));
  }
  try {
    player_id = input.playerId ? parseInt(input.playerId) : 0
    message = input.message ? JSON.parse(input.message) : {}

    const client = new SecretsManagerClient({region: "ap-northeast-1"});
    const response = await client.send(new GetSecretValueCommand({
      SecretId: "SmartContractPK",
      VersionStage: "AWSCURRENT",
    }));

    const EC = require('elliptic').ec;

    const ec = new EC('p256');
    fcl.config()
      .put("accessNode.api", "https://rest-testnet.onflow.org")

    // CHANGE THESE THINGS FOR YOU
    const PRIVATE_KEY = JSON.parse(response.SecretString)?.SmartContractPK;
    const ADDRESS = "0x9e447fb949c3f1b6";
    const KEY_ID = 0;
    const CONTRACT_NAME = "CodeOfFlowAlpha6";

    const sign = (message) => {
      const key = ec.keyFromPrivate(Buffer.from(PRIVATE_KEY, "hex"))
      const sig = key.sign(hash(message)) // hashMsgHex -> hash
      const n = 32
      const r = sig.r.toArrayLike(Buffer, "be", n)
      const s = sig.s.toArrayLike(Buffer, "be", n)
      return Buffer.concat([r, s]).toString("hex")
    }
    const hash = (message) => {
      const sha = new SHA3(256);
      sha.update(Buffer.from(message, "hex"));
      return sha.digest();
    }

    async function authorizationFunction(account) {
      return {
        ...account,
        tempId: `${ADDRESS}-${KEY_ID}`,
        addr: fcl.sansPrefix(ADDRESS),
        keyId: Number(KEY_ID),
        signingFunction: async (signable) => {
          return {
            addr: fcl.withPrefix(ADDRESS),
            keyId: Number(KEY_ID),
            signature: sign(signable.message)
          }
        }
      }
    }
    async function authorizationFunctionProposer(account) {
      KEY_ID_IT = !KEY_ID_IT || KEY_ID_IT > 5 ? 1 : KEY_ID_IT + 1
      fs.writeFileSync('/tmp/sequence.txt', KEY_ID_IT.toString());
      return {
        ...account,
        tempId: `${ADDRESS}-${KEY_ID_IT}`,
        addr: fcl.sansPrefix(ADDRESS),
        keyId: Number(KEY_ID_IT),
        signingFunction: async (signable) => {
          return {
            addr: fcl.withPrefix(ADDRESS),
            keyId: Number(KEY_ID_IT),
            signature: sign(signable.message)
          }
        }
      }
    }
    if (input.type === "player_matching") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.matchingStart,
        args: (arg, t) => [
          arg(player_id, t.UInt32)
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    } else if (input.type === "game_start") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.gameStart,
        args: (arg, t) => [
          arg(player_id, t.UInt32),
          arg(message, t.Array(t.UInt16))
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    } else if (input.type === "put_card_on_the_field") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.putCardOnField,
        args: (arg, t) => [
          arg(player_id, t.UInt32),
          arg(message.arg1, t.Dictionary({ key: t.UInt8, value: t.UInt16 })), // unit_card
          arg(message.arg2, t.UInt8), // enemy_skill_target
          arg(message.arg3, t.Dictionary({ key: t.UInt8, value: t.UInt16 })), // trigger_cards
          arg(message.arg4, t.Array(t.UInt8)) // used_intercept_positions
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    } else if (input.type === "turn_change") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.turnChange,
        args: (arg, t) => [
          arg(player_id, t.UInt32),
          arg(message.arg1, t.Array(t.UInt8)), // attacking_cards
          arg(message.arg2, t.Dictionary({ key: t.UInt8, value: t.UInt8 })), // enemy_skill_target
          arg(message.arg3, t.Dictionary({ key: t.UInt8, value: t.UInt16 })), // trigger_cards
          arg(message.arg4, t.Dictionary({ key: t.UInt8, value: t.Array(t.UInt8) })) // used_intercept_position
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    } else if (input.type === "start_your_turn") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.startYourTurn,
        args: (arg, t) => [
          arg(player_id, t.UInt32),
          arg(message.arg1, t.Dictionary({ key: t.UInt8, value: t.UInt8 })), // blocked_unit
          arg(message.arg2, t.Dictionary({ key: t.UInt8, value: t.UInt8 })), // used_intercept_position
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    } else if (input.type === "surrendar") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.surrendar,
        args: (arg, t) => [
          arg(player_id, t.UInt32),
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    } else if (input.type === "claim_win") {
      const transactionId = await fcl.mutate({
        cadence: FlowTransactions.claimWin,
        args: (arg, t) => [
          arg(player_id, t.UInt32),
        ],
        proposer: authorizationFunctionProposer,
        payer: authorizationFunction,
        authorizations: [authorizationFunction],
        limit: 999
      })
      console.log(`TransactionId: ${transactionId}`)
      message = `Transaction is On Going. TransactionId: ${transactionId}`
      fcl.tx(transactionId).subscribe(res => {
        console.log(res);
      })
    }

    return {
      id: new Date().getTime(),
      type: input.type || "",
      message: KEY_ID_IT + " : " + message,
      playerId: player_id,
      createdAt: new Date(),
      updatedAt: new Date()
    };
  } catch (error) {
    return {
      id: new Date().getTime(),
      type: input.type || "",
      message: error.toString(),
      playerId: player_id,
      createdAt: new Date(),
      updatedAt: new Date()
    };
  }
};
