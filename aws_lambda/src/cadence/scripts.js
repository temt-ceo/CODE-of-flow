export default {
    isRegistered: `
    import CodeOfFlow from 0xCOF
    pub fun main(address: Address): &CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}? {
        return getAccount(address).getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
    }
    `,
    getCurrentStatus: `
    import CodeOfFlow from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_current_status()
    }
    `,
    getMariganCards: `
    import CodeOfFlow from 0xCOF
    pub fun main(address: Address): [[UInt16]] {
        let cap = getAccount(address).getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_marigan_cards()
    }
    `,
    getCardInfo: `
    import CodeOfFlow from 0xCOF
    pub fun main(): {UInt16: CodeOfFlow.CardStruct} {
        return CodeOfFlow.getCardInfo()
    }
    `,
    getMatchingLimits: `
    import CodeOfFlow from 0xCOF
    pub fun main(): [UFix64] {
        return CodeOfFlow.getMatchingLimits()
    }
    `,
    getPlayersScore: `
    import CodeOfFlow from 0xCOF
    pub fun main(address: Address): AnyStruct {
        let cap = getAccount(address).getCapability<&CodeOfFlow.Player{CodeOfFlow.IPlayerPublic}>(CodeOfFlow.PlayerPublicPath).borrow()
          ?? panic("Doesn't have capability!")
        return cap.get_players_score()
    }
    `,
}
