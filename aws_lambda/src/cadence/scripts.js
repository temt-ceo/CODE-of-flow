export default {
    isRegistered: `
    import CodeOfFlowAlpha9 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowAlpha9.Player{CodeOfFlowAlpha9.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha9.Player{CodeOfFlowAlpha9.IPlayerPublic}>(CodeOfFlowAlpha9.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowAlpha9 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha9.Player{CodeOfFlowAlpha9.IPlayerPublic}>(CodeOfFlowAlpha9.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowAlpha9 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha9.Player{CodeOfFlowAlpha9.IPlayerPublic}>(CodeOfFlowAlpha9.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowAlpha9 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowAlpha9.CardStruct} {
        return CodeOfFlowAlpha9.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowAlpha9 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowAlpha9.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowAlpha9 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha9.Player{CodeOfFlowAlpha9.IPlayerPublic}>(CodeOfFlowAlpha9.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
