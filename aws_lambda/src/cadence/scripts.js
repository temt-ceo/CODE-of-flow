export default {
    isRegistered: `
    import CodeOfFlowAlpha15 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowAlpha15 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowAlpha15 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowAlpha15 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowAlpha15.CardStruct} {
        return CodeOfFlowAlpha15.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowAlpha15 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowAlpha15.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowAlpha15 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha15.Player{CodeOfFlowAlpha15.IPlayerPublic}>(CodeOfFlowAlpha15.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
