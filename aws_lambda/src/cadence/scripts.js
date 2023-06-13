export default {
    isRegistered: `
    import CodeOfFlowAlpha14 from 0xCOF
    pub fun main(address: Address): &CodeOfFlowAlpha14.Player{CodeOfFlowAlpha14.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlowAlpha14.Player{CodeOfFlowAlpha14.IPlayerPublic}>(CodeOfFlowAlpha14.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlowAlpha14 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha14.Player{CodeOfFlowAlpha14.IPlayerPublic}>(CodeOfFlowAlpha14.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlowAlpha14 from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha14.Player{CodeOfFlowAlpha14.IPlayerPublic}>(CodeOfFlowAlpha14.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlowAlpha14 from 0xCOF
    pub fun main(): {UInt16: CodeOfFlowAlpha14.CardStruct} {
        return CodeOfFlowAlpha14.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlowAlpha14 from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlowAlpha14.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlowAlpha14 from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlowAlpha14.Player{CodeOfFlowAlpha14.IPlayerPublic}>(CodeOfFlowAlpha14.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
