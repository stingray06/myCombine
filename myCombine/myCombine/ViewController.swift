//
//  ViewController.swift
//  myCombine
//
//  Created by Iurii Kotikhin on 17.04.2022.
//

import UIKit
import Combine
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let publisher1 = NotificationCenter.default.publisher(for: Notification.testNotification)
        publisher1.sink { notification in
            print("Hello from Combine")
            print(notification.name.rawValue)
        }.store(in: &cancellables)
        
        let observable = NotificationCenter.default.rx.notification(Notification.testNotification)
        observable.subscribe(onNext: {
            notification in
            print("Hello from RxSwift")
            print(notification.name.rawValue)
        }).disposed(by: disposeBag)
        
        
        example(of: "Subscriber") {
            let myNotifiaction = Notification.Name("MyNotification")
            
            let publisher = NotificationCenter.default.publisher(for: myNotifiaction, object: nil)
            let center = NotificationCenter.default
            
            let subscription = publisher.sink {
                _ in print("Notification recivied from a publisher!")
            }
                center.post(name: myNotifiaction, object: nil)
                
                subscription.cancel()
            }
        
        example(of: "Just") {
            let just = Just("Hello world")
            
            let rxJust = RxSwift.Observable.just("Hello worl RX")
            _ = just
                .sink(
                    receiveCompletion: {completion in
                    print("recieved completion", completion)
                },
                      receiveValue: {
                    print("recieved value", $0)
                    
                })
            rxJust.subscribe(onNext: {
                print("Recieved valuer", $0)
            }) {
                print("recieved completion")
            }
        }
        
        example(of: "assign(to:on:)") {
            class SomeObject {
                var value: String = "" {
                    didSet {
                        print(value)
                    }
                }
            }
            let object = SomeObject()
            
            let publisher = ["Hello", "world!"].publisher
            
            _ = publisher
                .assign(to: \.value, on: object)
        }
        
        example(of: "Custom Subscriber") {
            let publisher = (1...6).publisher
            
            final class IntSubscriber: Subscriber {
                func receive(_ input: Int) -> Subscribers.Demand {
                    print("recieved value", input)
                    return .unlimited
                }
                
                func receive(completion: Subscribers.Completion<Never>) {
                    print("Received completion", completion)                }
                
                typealias Input = Int
                typealias Failure = Never
                
                func receive(subscription: Subscription) {
                    subscription.request(.max(3))
                }
                
                
            }
            let subscriber = IntSubscriber()
            publisher.subscribe(subscriber)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            NotificationCenter.default.post(Notification(name:Notification.testNotification))
        }
    }
}


extension Notification {
    static var testNotification: Notification.Name {
        Notification.Name("testNotification")
    }
}

    public func example(of description: String, action: () -> Void) {
        print("\n------- Example of:", description, "-------")
        action()
    }
