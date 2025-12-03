import SwiftUI
import WatchKit

public struct ScorecardWatchRow: View {
  public let holeIndex: Int
  @Binding public var strokes: Int
  public let onAdd: () async -> Void
  public let onRemove: () async -> Void

  public init(holeIndex: Int, strokes: Binding<Int>, onAdd: @escaping () async -> Void, onRemove: @escaping () async -> Void) {
    self.holeIndex = holeIndex
    self._strokes = strokes
    self.onAdd = onAdd
    self.onRemove = onRemove
  }

  public var body: some View {
    HStack {
      Text("\(holeIndex)")
        .font(.headline)
        .frame(width: 28)
      Spacer()
      Button(action: { Task { await onRemove() } }) {
        Image(systemName: "minus.circle")
          .imageScale(.large)
      }
      Text("\(strokes)")
        .font(.title3)
        .frame(minWidth: 34)
      Button(action: { Task { await onAdd() } }) {
        Image(systemName: "plus.circle")
          .imageScale(.large)
      }
    }
    .padding(.vertical, 6)
  }
}
