export default {
    isRegistered: `
    import CodeOfFlowBeta5 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowBeta5.Player{CodeOfFlowBeta5.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowBeta5.Player{CodeOfFlowBeta5.IPlayerPublic}>(CodeOfFlowBeta5.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowBeta5 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta5.Player{CodeOfFlowBeta5.IPlayerPublic}>(CodeOfFlowBeta5.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowBeta5 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta5.Player{CodeOfFlowBeta5.IPlayerPublic}>(CodeOfFlowBeta5.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowBeta5 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowBeta5.CardStruct} {
        return CodeOfFlowBeta5.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowBeta5 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowBeta5.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowBeta5 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowBeta5.Player{CodeOfFlowBeta5.IPlayerPublic}>(CodeOfFlowBeta5.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
