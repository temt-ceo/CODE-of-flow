export default {
    isRegistered: `
    import CodeOfFlowAlpha6 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowAlpha6 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowAlpha6 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowAlpha6 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowAlpha6.CardStruct} {
        return CodeOfFlowAlpha6.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowAlpha6 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowAlpha6.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowAlpha6 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha6.Player{CodeOfFlowAlpha6.IPlayerPublic}>(CodeOfFlowAlpha6.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
