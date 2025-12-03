import SwiftUI
import WatchKit
import SwiftData

public struct WatchScorecardView: View {
  @ObservedObject public var round: SDRound
  @StateObject private var store: DefaultScorecardStore

  public init(round: SDRound, context: ModelContext) {
    self.round = round
    self._store = StateObject(wrappedValue: DefaultScorecardStore(context: context))
  }

  public var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        ForEach(Array(round.holeStates.enumerated()), id: \.element.holeIndex) { index, hs in
          // Binding to stroke count for the given hole
          let binding = Binding<Int>(get: { hs.strokes.count }, set: { _ in })
          ScorecardWatchRow(holeIndex: hs.holeIndex, strokes: binding) {
            await store.addStroke(round: round, holeIndex: hs.holeIndex)
            WKInterfaceDevice.current().play(.click)
          } onRemove: {
            await store.removeLastStroke(round: round, holeIndex: hs.holeIndex)
            WKInterfaceDevice.current().play(.directionDown)
          }
        }

        HStack {
          Text("Total")
            .font(.caption)
          Spacer()
          Text("\(round.holeStates.flatMap { $0.strokes }.count)")
            .bold()
        }
        .padding(.top, 6)
      }
      .padding()
    }
  }
}
