export default {
    createPlayer: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction(nickname: String) {
        prepare(acct: AuthAccount) {
          // Step1
          acct.save(<- CodeOfFlowAlpha15.createPlayer(nickname: nickname), to: CodeOfFlowAlpha15.PlayerStoragePath)
          // Step2
          acct.link<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath, target: CodeOfFlowAlpha15.PlayerStoragePath)
          }
        execute {
          log("success")
        }
      }
    `,
    matchingStart: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction() {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.matching_start()
        }
        execute {
          log("success")
        }
      }
    `,
    gameStart: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction(drawed_cards: [UInt16]) {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.game_start(drawed_cards: drawed_cards)
        }
        execute {
          log("success")
        }
      }
    `,
    turnChange: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction(attacking_cards: [UInt8], enemy_skill_target: {UInt8: UInt8}, trigger_cards: {UInt8: UInt16}, used_intercept_position: {UInt8: [UInt8]}) {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.turn_change(attacking_cards: attacking_cards, enemy_skill_target: enemy_skill_target, trigger_cards: trigger_cards, used_intercept_position: used_intercept_position)
        }
        execute {
          log("success")
        }
      }
    `,
    putCardOnField: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction(unit_card: {UInt8: UInt16}, enemy_skill_target: UInt8?, trigger_cards: {UInt8: UInt16}, used_intercept_positions: [UInt8]) {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.put_card_on_the_field(unit_card: unit_card, enemy_skill_target: enemy_skill_target, trigger_cards: trigger_cards, used_intercept_positions: used_intercept_positions)
        }
        execute {
          log("success")
        }
      }
    `,
    startYourTurn: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction(blocked_unit: {UInt8: UInt8}, used_intercept_position: {UInt8: UInt8}) {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.start_your_turn_and_draw_two_cards(blocked_unit: blocked_unit, used_intercept_position: used_intercept_position)
        }
        execute {
          log("success")
        }
      }
    `,
    claimWin: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction() {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.claimWin()
        }
        execute {
          log("success")
        }
      }
    `,
    surrendar: `
      import CodeOfFlowAlpha15 from 0xCOF

      transaction() {
        prepare(acct: AuthAccount) {
          let gamePlayer = acct.borrow<&CodeOfFlowAlpha15.Player>(from: CodeOfFlowAlpha15.PlayerStoragePath)
            ?? panic("This Player has not registered")
          gamePlayer.surrendar()
        }
        execute {
          log("success")
        }
      }
    `,
}