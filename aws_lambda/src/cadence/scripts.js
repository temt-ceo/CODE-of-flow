export default {
    isRegistered: `
    import CodeOfFlowV2 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowV2.Player{CodeOfFlowV2.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowV2.Player{CodeOfFlowV2.IPlayerPublic}>(CodeOfFlowV2.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowV2 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowV2.Player{CodeOfFlowV2.IPlayerPublic}>(CodeOfFlowV2.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowV2 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowV2.Player{CodeOfFlowV2.IPlayerPublic}>(CodeOfFlowV2.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowV2 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowV2.CardStruct} {
        return CodeOfFlowV2.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowV2 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowV2.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowV2 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowV2.Player{CodeOfFlowV2.IPlayerPublic}>(CodeOfFlowV2.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
