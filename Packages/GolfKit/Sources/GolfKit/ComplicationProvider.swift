import Foundation
#if os(watchOS)
import ClockKit
#endif

public actor ComplicationProvider {
  public init() {}

  public func compactText(for round: SDRound) -> String {
    let holesPlayed = round.holeStates.filter { !$0.strokes.isEmpty }.count
    let total = round.holeStates.flatMap { $0.strokes }.count
    return "H:\(holesPlayed) S:\(total)"
  }

  #if os(watchOS)
  public func currentEntry(for complication: CLKComplication, round: SDRound) -> CLKComplicationTimelineEntry? {
    // Minimal scaffold: create a simple text template for supported families.
    let text = compactText(for: round)

    // Use CLKComplicationTemplateModularSmallSimpleText as a safe default for unit tests; runtime should map per family.
    if let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: CLKSimpleTextProvider(text: text)) as? CLKComplicationTemplate {
      let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
      return entry
    }
    return nil
  }

  public func requestTimelineReload() {
    CLKComplicationServer.sharedInstance().activeComplications?.forEach {
      CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
    }
  }
  #endif
}
