import SwiftUI

struct LandingView: View {
  @StateObject var vm = LandingViewModel()

  var body: some View {
    VStack {
      header
      Spacer()
      // map and other UI...
    }
    .onAppear { vm.startLocationUpdates() }
    .onDisappear { vm.stopLocationUpdates() }
  }

  var header: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text("Hole \(vm.holeIndex) • Par \(vm.par)")
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
            Text("\(Int(d.distanceMeters)) m")
              .font(.caption2)
              .foregroundColor(.secondary)
          }
          .transition(.scale.combined(with: .opacity))
          .animation(.spring(), value: vm.detectedHole?.timestamp)
        }
      }
      Text(vm.detectedHole == nil ? "\(Int(vm.distanceToGreen)) m to middle" : "Auto-detected • \(vm.detectedHole!.timestamp, style: .relative)")
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
