import SwiftUI
import MapKit
import GolfKit

struct LandingView: View {
  @EnvironmentObject var appState: AppState
  @Environment(\.modelContext) var context
  @StateObject private var vm = LandingViewModel()

  var body: some View {
    VStack(spacing: 0) {
      MapView(playerCoordinate: vm.playerCoordinate, course: vm.currentCourse)
        .frame(height: 420)
      HStack {
        VStack(alignment: .leading) {
          Text("Hole \(vm.holeIndex) • Par \(vm.par)")
            .font(.headline)
          Text("\(Int(vm.distanceToGreen)) m to middle")
            .font(.subheadline)
        }
        Spacer()
        Button("Start Round") { }
      }
      .padding()
    }
    .onAppear { vm.bootstrap(context: context) }
  }
}

final class LandingViewModel: ObservableObject {
  @Published var playerCoordinate: CLLocationCoordinate2D?
  @Published var currentCourse: GolfCourse?
  @Published var holeIndex = 1
  @Published var par = 4
  @Published var distanceToGreen: Double = 0

  private let locationProvider: LocationProviding

  init(locationProvider: LocationProviding = MockLocationProvider()) {
    self.locationProvider = locationProvider
    self.playerCoordinate = locationProvider.lastCoordinate
  }

  func bootstrap(context: ModelContext) {
    if let course = try? context.fetch(SDCourse.self).first {
      self.currentCourse = convert(course)
      computeHole()
    } else {
      let hole = Hole(index: 1, par: 4, teeCoordinate: Coordinate(lat: 1.3005, lon: 103.8005), greenCoordinate: Coordinate(lat: 1.3006, lon: 103.8006), yardage: Yardage(middle: 120))
      self.currentCourse = GolfCourse(name: "Preview Course", location: Coordinate(lat:1.3,lon:103.8), holes: [hole])
      computeHole()
    }
  }

  private func computeHole() {
    guard let course = currentCourse, course.holes.count >= holeIndex else { return }
    let hole = course.holes[holeIndex-1]
    self.par = hole.par
    self.distanceToGreen = playerCoordinate.map { DistanceCalculator.distanceMeters(from: $0, to: hole.greenCoordinate.clCoordinate) } ?? 0
  }

  private func convert(_ sd: SDCourse) -> GolfCourse {
    let holes = sd.holes.map { h in
      Hole(index: h.index, par: h.par,
           teeCoordinate: Coordinate(lat: h.teeLatitude, lon: h.teeLongitude),
           greenCoordinate: Coordinate(lat: h.greenLatitude, lon: h.greenLongitude),
           yardage: Yardage(middle: h.midYard),
           hazards: h.hazards.map { SDHazard in Hazard(kind: .water, coordinate: Coordinate(lat: SDHazard.latitude, lon: SDHazard.longitude)) })
    }
    return GolfCourse(id: sd.id, name: sd.name, location: Coordinate(lat: sd.latitude, lon: sd.longitude), holes: holes)
  }
}
