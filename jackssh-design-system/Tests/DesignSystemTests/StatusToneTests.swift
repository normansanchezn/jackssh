import Testing
@testable import DesignSystem

@Suite("StatusTone")
struct StatusToneTests {
    @Test func everyToneHasASymbol() {
        for tone in StatusTone.allCases {
            #expect(!tone.symbolName.isEmpty)
        }
    }

    @Test func tonesAreDistinct() {
        let symbols = Set(StatusTone.allCases.map(\.symbolName))
        #expect(symbols.count == StatusTone.allCases.count)
    }
}
