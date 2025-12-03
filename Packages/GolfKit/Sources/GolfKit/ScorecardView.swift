import SwiftUI
import SwiftData

public struct ScorecardView: View {
  @ObservedObject public var round: SDRound
  @StateObject private var store: DefaultScorecardStore

  public init(round: SDRound, context: ModelContext) {
    self.round = round
    self._store = StateObject(wrappedValue: DefaultScorecardStore(context: context))
  }

  public var body: some View {
    List {
      ForEach(round.holeStates, id: \.holeIndex) { hole in
        HStack {
          Text("Hole \(hole.holeIndex)")
            .font(.subheadline)
          Spacer()
          HStack(spacing: 8) {
            Button(action: { Task { await store.removeLastStroke(round: round, holeIndex: hole.holeIndex) } }) {
              Image(systemName: "minus.circle")
            }
            Text("\(hole.strokes.count)")
              .font(.headline)
              .frame(minWidth: 32)
            Button(action: { Task { await store.addStroke(round: round, holeIndex: hole.holeIndex) } }) {
              Image(systemName: "plus.circle")
            }
          }
        }
        .padding(.vertical, 6)
      }
    }
    .navigationTitle("Scorecard")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Undo") { Task { await store.undoLastChange(round: round) } }
      }
    }
  }
}
