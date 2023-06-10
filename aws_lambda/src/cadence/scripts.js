export default {
    isRegistered: `
    import CodeOfFlowAlpha12 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowAlpha12.Player{CodeOfFlowAlpha12.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha12.Player{CodeOfFlowAlpha12.IPlayerPublic}>(CodeOfFlowAlpha12.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowAlpha12 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha12.Player{CodeOfFlowAlpha12.IPlayerPublic}>(CodeOfFlowAlpha12.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowAlpha12 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha12.Player{CodeOfFlowAlpha12.IPlayerPublic}>(CodeOfFlowAlpha12.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowAlpha12 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowAlpha12.CardStruct} {
        return CodeOfFlowAlpha12.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowAlpha12 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowAlpha12.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowAlpha12 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha12.Player{CodeOfFlowAlpha12.IPlayerPublic}>(CodeOfFlowAlpha12.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
