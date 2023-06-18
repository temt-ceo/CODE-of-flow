export default {
    isRegistered: `
    import CodeOfFlowBeta4 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowBeta4.Player{CodeOfFlowBeta4.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowBeta4.Player{CodeOfFlowBeta4.IPlayerPublic}>(CodeOfFlowBeta4.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowBeta4 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta4.Player{CodeOfFlowBeta4.IPlayerPublic}>(CodeOfFlowBeta4.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowBeta4 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta4.Player{CodeOfFlowBeta4.IPlayerPublic}>(CodeOfFlowBeta4.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowBeta4 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowBeta4.CardStruct} {
        return CodeOfFlowBeta4.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowBeta4 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowBeta4.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowBeta4 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta4.Player{CodeOfFlowBeta4.IPlayerPublic}>(CodeOfFlowBeta4.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
