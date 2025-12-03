import Foundation
import Combine
import WatchConnectivity

public actor RoundSyncService {
  private var session: WCSessionProtocol
  private var queue: [Data] = []

  public init(session: WCSessionProtocol = WCSessionAdapter.shared) {
    self.session = session
    session.delegate = WCSessionAdapter.shared
    session.activate()
  }

  public func send(payload: Data) async throws {
    if session.isReachable {
      try await session.send(payload)
    } else {
      queue.append(payload)
    }
  }

  public func flushQueueIfNeeded() async {
    guard !queue.isEmpty, session.isReachable else { return }
    for data in queue {
      try? await session.send(data)
    }
    queue.removeAll()
  }
}

// Protocol + adapter to allow simulator no-op and testing
public protocol WCSessionProtocol: AnyObject {
  var isReachable: Bool { get }
  var delegate: WCSessionDelegate? { get set }
  func activate()
  func send(_ data: Data) async throws
}

extension WCSession: WCSessionProtocol {
  public func send(_ data: Data) async throws {
    try await withCheckedThrowingContinuation { cont in
      do {
        try updateApplicationContext(["payload": data])
        cont.resume()
      } catch {
        cont.resume(throwing: error)
      }
    }
  }
}

final class WCSessionAdapter: NSObject, WCSessionDelegate, WCSessionProtocol {
  static let shared = WCSessionAdapter()
  var delegate: WCSessionDelegate?
  var isReachable: Bool { WCSession.isSupported() && WCSession.default.isReachable }

  func activate() {
    guard WCSession.isSupported() else { return }
    WCSession.default.delegate = self
    WCSession.default.activate()
  }

  func send(_ data: Data) async throws {
    guard WCSession.isSupported() else { return }
    if WCSession.default.isReachable {
      WCSession.default.sendMessageData(data, replyHandler: nil) { error in
        // swallow for now
      }
    } else {
      throw NSError(domain: "WCSession", code: -1, userInfo: nil)
    }
  }

  // WCSessionDelegate stubs
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {}
  #if os(iOS)
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {}
  #endif
}
