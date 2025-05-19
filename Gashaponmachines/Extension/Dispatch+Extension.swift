import Foundation

func dispatch_sync_safely_main_queue(_ block: () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

func dispatch_async_safely_main_queue(_ block: @escaping () -> Void) {
    DispatchQueue.main.async {
        block()
    }
}

func delayOn(_ delay: Double, closure:@escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func delay(_ seconds: Double, completion:@escaping () -> Void) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)

    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}
