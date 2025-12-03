import SwiftUI

@MainActor
public struct ClubRecommendationCard: View {
  @StateObject private var vm: ViewModel

  public init(recommender: ClubRecommender, distanceMeters: Double, windMps: Double = 0, lie: String? = nil) {
    _vm = StateObject(wrappedValue: ViewModel(recommender: recommender, distanceMeters: distanceMeters, windMps: windMps, lie: lie))
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Club suggestions")
          .font(.headline)
        Spacer()
        Button(action: { vm.showWhy.toggle() }) {
          Image(systemName: "questionmark.circle")
        }
        .buttonStyle(.borderless)
      }

      if vm.candidates.isEmpty {
        Text("No history yet  record a few shots for personalized suggestions.")
          .font(.caption)
          .foregroundColor(.secondary)
      } else {
        ForEach(vm.candidates.indices, id: \.self) { idx in
          let c = vm.candidates[idx]
          HStack {
            Text("\(idx + 1). \(c.club)")
              .font(.subheadline)
            Spacer()
            Text(String(format: "%.2f", c.score))
              .font(.caption2)
              .foregroundColor(.secondary)
          }
        }
        if vm.showWhy, let why = vm.whyExample {
          Divider()
          Text("Why: nearest example  \(why.club) at \(Int(why.distance))m")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
    .padding()
    .background(.regularMaterial)
    .cornerRadius(12)
    .task { await vm.refresh() }
  }
}

extension ClubRecommendationCard {
  @MainActor
  final class ViewModel: ObservableObject {
    @Published private(set) var candidates: [(club: String, score: Double)] = []
    @Published var showWhy: Bool = false
    @Published private(set) var whyExample: (club: String, distance: Double)? = nil

    private let recommender: ClubRecommender
    private let distanceMeters: Double
    private let windMps: Double
    private let lie: String?

    init(recommender: ClubRecommender, distanceMeters: Double, windMps: Double = 0, lie: String? = nil) {
      self.recommender = recommender
      self.distanceMeters = distanceMeters
      self.windMps = windMps
      self.lie = lie
    }

    func refresh() async {
      let results = await recommender.recommend(forDistance: distanceMeters, windMps: windMps, lie: lie, limit: 3)
      await MainActor.run {
        self.candidates = results
      }
      // compute a nearest example for the top candidate
      if let top = results.first {
        if let example = await recommender.representativeExample(forClub: top.club, forDistance: distanceMeters, windMps: windMps, lie: lie) {
          await MainActor.run { self.whyExample = (club: example.club, distance: example.distanceMeters) }
        } else {
          await MainActor.run { self.whyExample = (club: top.club, distance: distanceMeters) }
        }
      }
    }
  }
}

#if DEBUG
import SwiftUI
struct ClubRecommendationCard_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      let rec = ClubRecommender(history: [
        ShotRecord(club: "7I", distanceMeters: 140),
        ShotRecord(club: "6I", distanceMeters: 150),
        ShotRecord(club: "8I", distanceMeters: 130),
        ShotRecord(club: "Driver", distanceMeters: 230)
      ])
      ClubRecommendationCard(recommender: rec, distanceMeters: 145)
        .padding()
    }
  }
}
#endif
