/*
 * Copyright (c) 2019, Psiphon Inc.
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import Foundation
import ReactiveSwift
import Promises

public struct TimeoutError: Error {}

// TODO: replace with Pair type.
public struct Combined<Value> {
    public let previous: Value
    public let current: Value
    
    public init(previous: Value, current: Value) {
        self.previous = previous
        self.current = current
    }
}

extension Signal where Error == Never {

    public func observe<A>(store: Store<A, Value>) -> Disposable? {
        return self.observeValues { [unowned store] (value: Signal.Value) in
            store.send(value)
        }
    }

}

extension Signal where Value == Bool, Error == Never {

    public func falseIfNotTrue(within timeout: DispatchTimeInterval) -> Signal<Bool, Never> {
        precondition(timeout != .never, "Unexpected '.never' timeout")

        return self.filter { $0 == true }
            .take(first: 1)
            .timeout(after: timeout.toDouble()!, raising: TimeoutError(), on: QueueScheduler())
            .flatMapError { anyError -> SignalProducer<Bool, Error> in
                return .init(value: false)
            }
    }

}

extension SignalProducer {
    
    public static func neverComplete(value: Value) -> Self {
        SignalProducer { observer, _ in
            observer.send(value: value)
        }
    }
    
    /// A `SignalProducerConvertible` version of `combinePrevious(_:)`
    public func combinePrevious(initial: Value) -> SignalProducer<Combined<Value>, Error> {
        self.combinePrevious(initial)
            .map { (combined: (Value, Value)) -> Combined<Value> in
                Combined(previous: combined.0, current: combined.1)
        }
    }
    
}

extension SignalProducer where Value == Bool, Error == Never {

    public func falseIfNotTrue(within timeout: DispatchTimeInterval) -> SignalProducer<Bool, Never> {
        precondition(timeout != .never, "Unexpected '.never' timeout")

        return self.producer.filter { $0 == true }
            .take(first: 1)
            .timeout(after: timeout.toDouble()!, raising: TimeoutError(), on: QueueScheduler())
            .flatMapError { anyError -> SignalProducer<Bool, Error> in
                return .init(value: false)
        }
    }

}

extension SignalProducer where Error == Never {
    
    public func send<StoreValue>(store: Store<StoreValue, Value>) -> Disposable? {
        return startWithValues { action in
            store.send(action)
        }
    }
    
}

extension SignalProducer where Value: Collection, Error == Never {
    
    /// Sends all elements of emitted value as actions to `store` sequentially.
    public func send<StoreValue>(store: Store<StoreValue, Value.Element>) -> Disposable? {
        return startWithValues { actions in
            for action in actions {
                store.send(action)
            }
        }
    }
    
}

