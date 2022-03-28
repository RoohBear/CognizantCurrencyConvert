//
//  AnyPresenter.swift
//  CognizantCurrencyDemo
//
//  Created by Ben Balcomb on 3/28/22.
//

import Foundation
import Combine

protocol PresenterProtocol {
    associatedtype Action
    associatedtype State
    var statePublisher: AnyPublisher<State?, Never> { get }
    func processAction(_ action: Action)
}

class AnyPresenter<A, S>: PresenterProtocol {
    typealias Action = A
    typealias State = S

    var statePublisher: AnyPublisher<S?, Never> {
        fatalError("statePublisher not overridden in subclass")
    }

    func processAction(_ action: A) {
        fatalError("processAction not overridden in subclass")
    }
}
