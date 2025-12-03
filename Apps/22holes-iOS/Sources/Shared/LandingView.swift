import SwiftUI
import MapKit
import GolfKit

struct LandingView: View {
  @StateObject var vm = LandingViewModel()
  @State private var overlays: [MKOverlay] = []
  @State private var annotations: [MKAnnotation] = []

  var body: some View {
    VStack {
      header
      GolfMapView(overlays: $overlays, annotations: $annotations)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: vm.detectedHole) { _ in
          overlays = vm.yardageOverlays
          annotations = vm.yardageAnnotations
          vm.fetchPlaysLikeIfNeeded(heading: nil)
        }
    }
    .onAppear {
      // bootstrap shot service into vm (example: real bootstrap should inject via DI)
      let weather = WeatherKitProvider()
      let shotSvc = ShotRecommendationService(weatherProvider: weather)
      vm.wireShotService(shotSvc)

      vm.startLocationUpdates()
      overlays = vm.yardageOverlays
      annotations = vm.yardageAnnotations
    }
    .onDisappear { vm.stopLocationUpdates() }
  }

  var header: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text("Hole \(vm.holeIndex)  Par \(vm.par)")
          .font(.headline)
        Spacer()
        if let d = vm.detectedHole {
          HStack(spacing: 6) {
            Text("AUTO")
              .font(.caption2)
              .bold()
              .padding(.vertical, 4)
              .padding(.horizontal, 6)
              .background(Color.accentColor.opacity(0.12))
              .clipShape(Capsule())
              .accessibilityLabel("Auto-detected hole")
            Text("\(Int(d.distanceMeters)) m")
              .font(.caption2)
              .foregroundColor(.secondary)
          }
          .transition(.scale.combined(with: .opacity))
          .animation(.spring(), value: vm.detectedHole?.timestamp)
        }
      }
      if let wind = vm.windSummary {
        Text(wind)
          .font(.caption2)
          .foregroundColor(.secondary)
          .accessibilityLabel("Plays like distances")
      }
      Text(vm.detectedHole == nil ? "\(Int(vm.distanceToGreen)) m to middle" : "Auto-detected  \(vm.detectedHole!.timestamp, style: .relative)")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.accentColor.opacity(vm.recentlySwitched ? 0.9 : 0), lineWidth: 2)
        .animation(.easeOut(duration: 0.5), value: vm.recentlySwitched)
    )
    .padding([.horizontal, .top])
  }
}
