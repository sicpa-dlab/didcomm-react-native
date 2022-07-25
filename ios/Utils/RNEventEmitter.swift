@objc(RNEventEmitter)
open class RNEventEmitter: RCTEventEmitter {
    public static var emitter: RCTEventEmitter!
    
    private var hasListeners: Bool

    override init() {
        hasListeners = false
        super.init()
        RNEventEmitter.emitter = self
    }

    open override func supportedEvents() -> [String] {
        ["resolve-did", "find-key", "find-keys"]
    }

    open override func startObserving() {
        hasListeners = true
    }

    open override func stopObserving() {
        hasListeners = false
    }
}
