//
//  CSCardTransitionInteractor.swift
//  CSCardTransition
//
//  Created by Jean Haberer on 02/12/2020.
//
//  Copyright (c) 2021 Creastel CTL <hello@creastel.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

private enum CSCardTransitionConstants {
    static let transitionCompletionThreshold: CGFloat = 1
    static let progressGestureMultiplicator: CGFloat = 1/100
}
public class CSCardTransitionInteractor: UIPercentDrivenInteractiveTransition {
    
    // MARK: - Public Variables
    public var ignoreTouchInViews: [UIView] = []
    // MARK: - Library internal variables
    var interactionInProgress = false
    var shouldCompleteTransition = false
    var cardTransitionInteractorDidUpdate: ((_ progress: CGFloat) -> Void)?
    var cardTransitionInteractorDidCancel: (() -> Void)?
    var cardTransitionInteractorDidFinish: (() -> Void)?
    
    // MARK: - Private Variables
    private var impactFeedbackgenerator: UIImpactFeedbackGenerator?
    private var currentTranslationDirection: CGPoint = .zero
    private weak var viewController: UIViewController!

    // MARK: - Life Cycle
    
    /**
         Initializes a new Card Transition Interactor.
         Should be attached to the presented View Controller to enable the card transition pop gestures.

         - Parameters:
            - viewController: The *UIViewController* parent of the Interactor.

         - Returns: A new Card Transition Interactor.
         */
    public init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        setupGestures(in: viewController.view)
        setupImpactGenerator()
    }
    
    // MARK: - Overrides
    
    public override func update(_ progress: CGFloat) {
        if progress >= CSCardTransitionConstants.transitionCompletionThreshold && !shouldCompleteTransition {
            shouldCompleteTransition = true
            impact()
        } else if progress < CSCardTransitionConstants.transitionCompletionThreshold && shouldCompleteTransition {
            shouldCompleteTransition = false
            impact()
        }
        cardTransitionInteractorDidUpdate?(min(1.0, progress))
        super.update(progress)
    }
    
    public override func cancel() {
        currentTranslationDirection = .zero
        cardTransitionInteractorDidCancel?()
        super.cancel()
    }
    
    public func endTransition() {
        currentTranslationDirection = .zero
        cardTransitionInteractorDidFinish?()
    }
    
    public override func finish() {
        super.finish()
    }
    
    // MARK: - Private functions
    
    var transitionGestures: [UIGestureRecognizer] = []
    
    private func setupGestures(in view: UIView) {
        let swipeEdgeLeftGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        swipeEdgeLeftGesture.edges = .left
        swipeEdgeLeftGesture.delegate = self
        view.addGestureRecognizer(swipeEdgeLeftGesture)
        transitionGestures.append(swipeEdgeLeftGesture)
        let swipeEdgeRightGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        swipeEdgeRightGesture.edges = .right
        swipeEdgeRightGesture.delegate = self
        view.addGestureRecognizer(swipeEdgeRightGesture)
        transitionGestures.append(swipeEdgeRightGesture)
        let verticalSwipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        verticalSwipeGesture.minimumNumberOfTouches = 0
        verticalSwipeGesture.delegate = self
        view.addGestureRecognizer(verticalSwipeGesture)
        transitionGestures.append(verticalSwipeGesture)
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 13.4, *) {
            verticalSwipeGesture.allowedScrollTypesMask = .continuous
        }
        #endif
    }
    
    @objc private func handleEdgeGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        handleGesture(gestureRecognizer)
    }

    @objc private func handleSwipeGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Check if gesture did not started on a disabling view
        if gestureRecognizer.state == .began {
            for disablingView in ignoreTouchInViews {
                if disablingView.bounds.contains(gestureRecognizer.location(in: disablingView)) {
                    gestureRecognizer.state = .failed
                    return
                }
            }
        }
        handleGesture(gestureRecognizer)
    }
    
    private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view?.superview else { return }
        let translation = gestureRecognizer.translation(in: view)
        let xPos = translation.x
        let yPos = translation.y
        if currentTranslationDirection == . zero {
            currentTranslationDirection = CGPoint(
                x: translation.x / norm(translation),
                y: translation.y / norm(translation)
            )
        }
        var progress = (xPos * currentTranslationDirection.x + yPos * currentTranslationDirection.y)
        progress *= CSCardTransitionConstants.progressGestureMultiplicator
        progress = max(progress, 0.0)
        
        if gestureRecognizer.state != .ended && shouldCompleteTransition {
            gestureRecognizer.state = .ended
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            prepareImpactGeneratorForImpact()
            interactionInProgress = true
            viewController.navigationController?.popViewController(animated: true)
        case .changed:
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                endTransition()
            } else {
                cancel()
            }
        default:
            break
        }
    }
    
    private func norm(_ point: CGPoint) -> CGFloat {
        let norm = sqrt(pow(point.x, 2) + pow(point.y, 2))
        return norm != 0 ? norm : 0.00001
    }
    
    private func setupImpactGenerator() {
        DispatchQueue.main.async {
            self.impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
        }
    }
    
    private func prepareImpactGeneratorForImpact() {
        DispatchQueue.main.async {
            self.impactFeedbackgenerator?.prepare()
        }
    }
    
    private func impact() {
        DispatchQueue.main.async {
            self.impactFeedbackgenerator?.impactOccurred()
        }
    }
}

extension CSCardTransitionInteractor: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return transitionGestures.contains(otherGestureRecognizer)
    }
    
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
}
