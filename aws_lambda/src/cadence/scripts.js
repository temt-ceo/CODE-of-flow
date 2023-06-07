export default {
    isRegistered: `
    import CodeOfFlowAlpha10 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowAlpha10.Player{CodeOfFlowAlpha10.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha10.Player{CodeOfFlowAlpha10.IPlayerPublic}>(CodeOfFlowAlpha10.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowAlpha10 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha10.Player{CodeOfFlowAlpha10.IPlayerPublic}>(CodeOfFlowAlpha10.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowAlpha10 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha10.Player{CodeOfFlowAlpha10.IPlayerPublic}>(CodeOfFlowAlpha10.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowAlpha10 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowAlpha10.CardStruct} {
        return CodeOfFlowAlpha10.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowAlpha10 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowAlpha10.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowAlpha10 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha10.Player{CodeOfFlowAlpha10.IPlayerPublic}>(CodeOfFlowAlpha10.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
