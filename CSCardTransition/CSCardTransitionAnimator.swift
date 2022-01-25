//
//  CSCardTransitionAnimator.swift
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
    static var debugDurationMultiplicationFactor: TimeInterval { return 10 }
    static var presentPositioningDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.7 : 0.7 }
    static var presentResizingDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.8 : 0.8 }
    static var presentStatusStyleUpdateDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.3 : 0.3 }
    static var dismissPositioningDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.5 : 0.5 }
    static var dismissResizingDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.4 : 0.4 }
    static var dismissBlurDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.2 : 0.2 }
    static var dismissStatusStyleUpdateDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.3 : 0.3 }
    static var cancelTransitionResizingDuration: TimeInterval { return CSCardTransition.debug ? debugDurationMultiplicationFactor * 0.3 : 0.3 }
    static var backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3)
    static var preDismissingTransitionProgressPortion: CGFloat = 0.2
}

class CSCardTransitionAnimation: NSObject {
    private let operationType: UINavigationController.Operation
    private let interactor: CSCardTransitionInteractor
    private let cardViewPresenterCard: UIView
    
    init(operation: UINavigationController.Operation,
         interactor: CSCardTransitionInteractor,
         cardViewPresenterCard: UIView
    ) {
        self.operationType = operation
        self.interactor = interactor
        self.cardViewPresenterCard = cardViewPresenterCard
    }
}

extension CSCardTransitionAnimation: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch operationType {
        case .push:
            return max(CSCardTransitionConstants.presentResizingDuration, CSCardTransitionConstants.presentPositioningDuration)
        case .pop:
            return max(CSCardTransitionConstants.dismissResizingDuration, CSCardTransitionConstants.dismissPositioningDuration)
        default:
            return 0
        }
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operationType {
        case .push:
            presentAnimation(transitionContext)
        case .pop:
            dismissAnimation(transitionContext)
        default:
            break
        }
    }
}

extension CSCardTransitionAnimation {
    internal func presentAnimation( _ transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromCardViewPresenter = transitionContext.viewController(forKey: .from) as? CSCardViewPresenter,
            let toCardPresentedView = transitionContext.viewController(forKey: .to) as? CSCardPresentedView,
            let fromStatusBarStyle = transitionContext.viewController(forKey: .from)?.preferredStatusBarStyle,
            let toStatusBarStyle = transitionContext.viewController(forKey: .to)?.preferredStatusBarStyle,
            let toView = transitionContext.view(forKey: .to)
        else { return }
        
        let toFrame = toView.frame
        let fromCard = cardViewPresenterCard
        
        toCardPresentedView.cardPresentedViewWillStartPresenting(from: fromCard)
        
        let transitionContainer = UIView(frame: .zero)
        transitionContainer.addSubview(toView)
        container.addSubview(transitionContainer)
        
        let absoluteFromCardFrame = (fromCard.superview ?? fromCard).convert(fromCard.frame, to: container)
        let transformScaledRatio = (fromCard.layer.presentation()?.frame.width ?? 0) / fromCard.frame.width
        transitionContainer.frame = absoluteFromCardFrame
        toView.frame.size = absoluteFromCardFrame.size
        toView.frame.origin = .zero
        transitionContainer.layoutIfNeeded()
        transitionContainer.transform = CGAffineTransform(scaleX: transformScaledRatio, y: transformScaledRatio)
        fromCard.alpha = 0
        
        let yDiff = toFrame.origin.y - absoluteFromCardFrame.origin.y
        let xDiff = toFrame.origin.x - absoluteFromCardFrame.origin.x
        
        var statusBarStyleUpdated = false
        toCardPresentedView.cardPresentedViewShouldUpdateBar(to: fromStatusBarStyle)
        
        var animationStartTime: CFTimeInterval = CACurrentMediaTime()
        let animationDuration: CFTimeInterval = min(CSCardTransitionConstants.presentPositioningDuration, CSCardTransitionConstants.presentResizingDuration)
        let animationDidUpdate = Action {
            let animationProgress = min(1, (CACurrentMediaTime() - animationStartTime) / animationDuration)
            let curvedProgress = log10(1 + animationProgress * 9)
            DispatchQueue.main.async {
                fromCardViewPresenter.cardViewPresenterDidUpdateDismissingTransition(progress: CGFloat(curvedProgress))
                toCardPresentedView.cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat(curvedProgress))
                if curvedProgress > 0.8 && !statusBarStyleUpdated {
                    statusBarStyleUpdated = true
                    UIView.animate(
                        withDuration: CSCardTransitionConstants.presentStatusStyleUpdateDuration,
                        animations: {
                            toCardPresentedView.cardPresentedViewShouldUpdateBar(to: toStatusBarStyle)
                        }
                    )
                }
            }
        }
        let displayLink: CADisplayLink = CADisplayLink(target: animationDidUpdate, selector: #selector(animationDidUpdate.selector))
        
        let completionHandler: (Bool) -> Void = { _ in
            container.addSubview(toView)
            transitionContainer.removeFromSuperview()
            toView.layoutIfNeeded()
            fromCard.alpha = 1
            displayLink.invalidate()
            fromCardViewPresenter.cardViewPresenterWillEndDismissing()
            toCardPresentedView.cardPresentedViewWillEndPresenting()
            fromCardViewPresenter.cardViewPresenterShouldUpdateBar(to: fromStatusBarStyle)
            toCardPresentedView.cardPresentedViewShouldUpdateBar(to: toStatusBarStyle)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        var positionAnimatorHandler: ((Bool) -> ())?
        var sizeAnimatorHandler: ((Bool) -> ())?
        
        if CSCardTransitionConstants.presentPositioningDuration > CSCardTransitionConstants.presentResizingDuration {
            positionAnimatorHandler = completionHandler
        } else {
            sizeAnimatorHandler = completionHandler
        }
        
        fromCardViewPresenter.cardViewPresenterDidStartDismissing()
        toCardPresentedView.cardPresentedViewDidStartPresenting()
        
        animationStartTime = CACurrentMediaTime()
        displayLink.add(to: RunLoop.current, forMode: .common)
        
        UIView.animate(
            withDuration: CSCardTransitionConstants.presentPositioningDuration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: {
                transitionContainer.frame.origin.y += yDiff
                transitionContainer.frame.origin.x += xDiff
            },
            completion: positionAnimatorHandler
        )
        
        UIView.animate(
            withDuration: CSCardTransitionConstants.presentResizingDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: {
                transitionContainer.transform = .identity
                transitionContainer.frame.size = toFrame.size
                transitionContainer.layoutIfNeeded()
            },
            completion: sizeAnimatorHandler
        )
    }
    
    internal func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let fromCardPresentedView = transitionContext.viewController(forKey: .from) as? CSCardPresentedView,
            let toCardViewPresenter = transitionContext.viewController(forKey: .to) as? CSCardViewPresenter,
            let fromStatusBarStyle = transitionContext.viewController(forKey: .from)?.preferredStatusBarStyle,
            let toStatusBarStyle = transitionContext.viewController(forKey: .to)?.preferredStatusBarStyle,
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to)
        else {
            return
        }
        
        // Call the animation delegate
        toCardViewPresenter.cardViewPresenterWillStartPresenting()
        fromCardPresentedView.cardPresentedViewWillStartDismissing()
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        let toCardView = cardViewPresenterCard
        toCardView.alpha = 0
        
        // Get the coordinates of the view inside the container
        let originFrame = fromView.frame
        let destinationFrame = CGRect(
            origin: (toCardView.superview ?? toCardView).convert(toCardView.frame.origin, to: container),
            size: toCardView.frame.size
        )
        
        let yDiff = destinationFrame.origin.y - originFrame.origin.y
        let xDiff = destinationFrame.origin.x - originFrame.origin.x
        
        var preTransitionProgress: CGFloat = 0.0
        
        toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: fromStatusBarStyle)
        
        let startTransitionBlock = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter, weak transitionContext] in
            guard let fromView = fromView, let transitionContext = transitionContext else { return }
            guard let fromCardPresentedView = fromCardPresentedView, let toCardViewPresenter = toCardViewPresenter else { return }
            
            // Call the animation delegate
            toCardViewPresenter.cardViewPresenterDidStartPresenting()
            fromCardPresentedView.cardPresentedViewDidStartDismissing()
            
            let animationStartTime: CFTimeInterval = CACurrentMediaTime()
            let animationDuration: CFTimeInterval = min(CSCardTransitionConstants.dismissPositioningDuration, CSCardTransitionConstants.dismissResizingDuration)
            let animationDidUpdate = Action {
                let animationProgress = min(CGFloat((CACurrentMediaTime() - animationStartTime) / animationDuration), 1)
                let curvedProgress = log10(1 + animationProgress * 49) / log10(50)
                let globalProgress = (1 - preTransitionProgress) * (min(curvedProgress, 1))
                DispatchQueue.main.async {
                    fromCardPresentedView.cardPresentedViewDidUpdateDismissingTransition(progress: globalProgress + preTransitionProgress)
                    toCardViewPresenter.cardViewPresenterDidUpdatePresentingTransition(progress: globalProgress + preTransitionProgress)
                }
            }
            let displayLink: CADisplayLink = CADisplayLink(target: animationDidUpdate, selector: #selector(animationDidUpdate.selector))
            displayLink.add(to: RunLoop.current, forMode: .common)
            
            // Animation completion.
            let completionHandler: (Bool) -> Void = { _ in
                toCardView.alpha = 1
                fromView.layer.shadowOpacity = 0
                toCardViewPresenter.cardViewPresenterWillEndPresenting()
                fromCardPresentedView.cardPresentedViewWillEndDismissing()
                UIView.animate(withDuration: 0.1, animations: {
                    fromView.alpha = 0
                }, completion: { _ in
                    fromCardPresentedView.cardPresentedViewShouldUpdateBar(to: fromStatusBarStyle)
                    toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                    fromView.removeFromSuperview()
                    displayLink.invalidate()
                    transitionContext.completeTransition(true)
                })
            }
            
            // Put the completion handler on the longest lasting animator
            
            var positionAnimatorHandler: ((Bool) -> ())?
            var sizeAnimatorHandler: ((Bool) -> ())?
            
            if CSCardTransitionConstants.dismissPositioningDuration > CSCardTransitionConstants.dismissResizingDuration {
                positionAnimatorHandler = completionHandler
            } else {
                sizeAnimatorHandler = completionHandler
            }
            UIView.animate(
                withDuration: CSCardTransitionConstants.dismissStatusStyleUpdateDuration, delay: 0,
                options: .allowUserInteraction, animations: {
                    toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                }
            )
            
            UIView.animate(
                withDuration: CSCardTransitionConstants.dismissPositioningDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
                animations: {
                    fromView.transform = CGAffineTransform(translationX: 0, y: yDiff)
                },
                completion: positionAnimatorHandler
            )
            
            UIView.animate(
                withDuration: CSCardTransitionConstants.dismissResizingDuration,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut],
                animations: {
                    fromView.frame.size = destinationFrame.size
                    fromView.layoutIfNeeded()
                    fromView.transform = fromView.transform.concatenating(CGAffineTransform(translationX: xDiff, y: 0))
                },
                completion: sizeAnimatorHandler
            )
        }
        
        if interactor.interactionInProgress {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            blurView.backgroundColor = CSCardTransitionConstants.backgroundColor
            blurView.frame = fromView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toView.addSubview(blurView)
            
            interactor.cardTransitionInteractorDidFinish = {
                UIView.animate(withDuration: CSCardTransitionConstants.dismissBlurDuration, animations: {
                    blurView.effect = .none
                    blurView.backgroundColor = .clear
                }, completion: { bool in
                    blurView.removeFromSuperview()
                })
                startTransitionBlock()
            }
            
            interactor.cardTransitionInteractorDidCancel = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter, weak transitionContext] in
                fromCardPresentedView?.cardPresentedViewWillCancelDismissing()
                toCardViewPresenter?.cardViewPresenterWillCancelPresenting()
                UIView.animate(
                    withDuration: CSCardTransitionConstants.cancelTransitionResizingDuration,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0,
                    options: [.curveEaseInOut],
                    animations: {
                        fromView?.transform = .identity
                    }, completion: { _ in
                        fromCardPresentedView?.cardPresentedViewShouldUpdateBar(to: fromStatusBarStyle)
                        toCardViewPresenter?.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                        blurView.removeFromSuperview()
                        transitionContext?.completeTransition(false)
                    }
                )
            }
            
            let pi = CGFloat.pi
            let stepLength: CGFloat = 3
            let stepFactor: CGFloat = 100/(50 - stepLength)
            
            interactor.cardTransitionInteractorDidUpdate = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter] progress in
                let curvedProgress = (atan(stepFactor * (progress - 1 / stepFactor)) * 2 / pi + 0.5)
                preTransitionProgress = min(curvedProgress, 1) * CSCardTransitionConstants.preDismissingTransitionProgressPortion
                let scale = (1 - preTransitionProgress / 2)
                fromCardPresentedView?.cardPresentedViewDidUpdateDismissingTransition(progress: preTransitionProgress)
                toCardViewPresenter?.cardViewPresenterDidUpdatePresentingTransition(progress: preTransitionProgress)
                fromView?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            startTransitionBlock()
        }
    }
}

