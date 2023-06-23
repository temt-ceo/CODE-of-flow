export default {
    isRegistered: `
    import CodeOfFlowBeta7 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowBeta7.Player{CodeOfFlowBeta7.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowBeta7.Player{CodeOfFlowBeta7.IPlayerPublic}>(CodeOfFlowBeta7.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowBeta7 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta7.Player{CodeOfFlowBeta7.IPlayerPublic}>(CodeOfFlowBeta7.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowBeta7 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta7.Player{CodeOfFlowBeta7.IPlayerPublic}>(CodeOfFlowBeta7.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowBeta7 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowBeta7.CardStruct} {
        return CodeOfFlowBeta7.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowBeta7 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowBeta7.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowBeta7 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta7.Player{CodeOfFlowBeta7.IPlayerPublic}>(CodeOfFlowBeta7.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
