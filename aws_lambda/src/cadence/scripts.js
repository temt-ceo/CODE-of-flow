export default {
    isRegistered: `
    import CodeOfFlowBeta3 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowBeta3 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowBeta3 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowBeta3 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowBeta3.CardStruct} {
        return CodeOfFlowBeta3.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowBeta3 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowBeta3.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowBeta3 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta3.Player{CodeOfFlowBeta3.IPlayerPublic}>(CodeOfFlowBeta3.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
