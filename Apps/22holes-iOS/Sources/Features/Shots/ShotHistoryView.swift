import SwiftUI

@MainActor
public struct ShotHistoryView: View {
    @StateObject private var vm: ViewModel

    public init(recorder: ShotRecorder) {
        _vm = StateObject(wrappedValue: ViewModel(recorder: recorder))
    }

    public var body: some View {
        List {
            Section {
                if vm.shots.isEmpty {
                    Text("No shots recorded yet.")
                } else {
                    ForEach(vm.shots, id: \ .id) { s in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(s.club).font(.headline)
                                Text("\(Int(s.distanceMeters)) m • \(s.timestamp, style: .time)").font(.caption)
                            }
                            Spacer()
                            if let hole = s.holeID { Text("Hole") }
                        }
                    }
                    .onDelete(perform: { idx in Task { await vm.delete(at: idx) } })
                }
            } header: {
                Text("Shot History")
            }

            Section {
                Button("Export CSV") { Task { await vm.exportCSV() } }
                Button("Undo last shot") { Task { await vm.undo() } }
            }
        }
        .navigationTitle("Shots")
        .task { await vm.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: .shotRecorderDidAdd)) { _ in Task { await vm.refresh() } }
    }
}

extension ShotHistoryView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var shots: [ShotRecordModel] = []
        private let recorder: ShotRecorder

        init(recorder: ShotRecorder) { self.recorder = recorder }

        func refresh() async {
            self.shots = await recorder.fetchAllShots()
        }

        func delete(at offsets: IndexSet) async {
            // naive: delete from SwiftData by id
            for idx in offsets {
                let s = shots[idx]
                if let ctx = recorder.context {
                    do {
                        let request = FetchDescriptor<Shot>(predicate: #Predicate<Shot> { $0.id == s.id })
                        let results = try ctx.fetch(request)
                        for r in results { ctx.delete(r) }
                        try ctx.save()
                    } catch {}
                }
            }
            await refresh()
        }

        func undo() async {
            try? await recorder.undoLastShot()
            await refresh()
        }

        func exportCSV() async {
            let rows = await recorder.fetchAllShots()
            let csv = CSVExporter.rowsToCSV(rows)
            // write to temp and present share sheet on main app (not available here)
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("shots_export.csv")
            try? csv.data(using: .utf8)?.write(to: url)
            // post notification for app to present share sheet with url
            NotificationCenter.default.post(name: .shotHistoryDidExportCSV, object: url)
        }
    }
}

public extension Notification.Name {
    static let shotHistoryDidExportCSV = Notification.Name("ShotHistoryDidExportCSV")
}

