//
//  CSCardTransitionAnimation.swift
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

class CSCardTransitionAnimation: NSObject {
    let operationType: UINavigationController.Operation
    let interactor: CSCardTransitionInteractor?
    
    init(operation: UINavigationController.Operation,
         interactor: CSCardTransitionInteractor?
    ) {
        self.operationType = operation
        self.interactor = interactor
    }
}

extension CSCardTransitionAnimation: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let presentedView = transitionContext?.viewController(forKey: .to) as? CSCardPresentedView else { return 0 }
        switch operationType {
        case .push:
            return max(presentedView.cardTransitionProperties.presentResizingDuration, presentedView.cardTransitionProperties.presentPositioningDuration)
        case .pop:
            return max(presentedView.cardTransitionProperties.dismissResizingDuration, presentedView.cardTransitionProperties.dismissPositioningDuration)
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
        
        let transitionProperties = toCardPresentedView.cardTransitionProperties
        
        let toFrame = toView.frame
        
        let transitionContainer = UIView(frame: .zero)
        transitionContainer.addSubview(toView)
        container.addSubview(transitionContainer)
        
        let fromCard = fromCardViewPresenter.cardViewPresenterCard ?? UIView()
        toCardPresentedView.cardPresentedViewWillStartPresenting(from: fromCard)
        
        let absoluteFromCardFrame = (fromCard.superview ?? fromCard).convert(fromCard.frame, to: container)
        transitionContainer.frame = absoluteFromCardFrame
        toView.frame.size = absoluteFromCardFrame.size
        toView.frame.origin = .zero
        transitionContainer.layoutIfNeeded()
        transitionContainer.transform = fromCard.transform
        toView.alpha = fromCard.alpha
        fromCard.alpha = 0
        
        let yDiff = toFrame.origin.y - absoluteFromCardFrame.origin.y
        let xDiff = toFrame.origin.x - absoluteFromCardFrame.origin.x
        
        var statusBarStyleUpdated = false
        toCardPresentedView.cardPresentedViewShouldUpdateBar(to: fromStatusBarStyle)
        
        var animationStartTime: CFTimeInterval = CACurrentMediaTime()
        var firstAnimation = true
        let animationDuration: CFTimeInterval = min(transitionProperties.presentPositioningDuration, transitionProperties.presentResizingDuration)
        let animationDidUpdate = Action {
            if firstAnimation {
                animationStartTime = CACurrentMediaTime()
                firstAnimation = false
            }
            let animationProgress = min(1, (CACurrentMediaTime() - animationStartTime) / animationDuration)
            let curvedProgress = min((log10(1 + animationProgress * 29) / log10(30))*1.4, 1)
            DispatchQueue.main.async {
                fromCardViewPresenter.cardViewPresenterDidUpdateDismissingTransition(progress: CGFloat(curvedProgress))
                toCardPresentedView.cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat(curvedProgress))
                if curvedProgress > 0.8 && !statusBarStyleUpdated {
                    statusBarStyleUpdated = true
                    UIView.animate(
                        withDuration: transitionProperties.presentStatusStyleUpdateDuration,
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
        
        if transitionProperties.presentPositioningDuration > transitionProperties.presentResizingDuration {
            positionAnimatorHandler = completionHandler
        } else {
            sizeAnimatorHandler = completionHandler
        }
        
        fromCardViewPresenter.cardViewPresenterDidStartDismissing()
        toCardPresentedView.cardPresentedViewDidStartPresenting()
        
        animationStartTime = CACurrentMediaTime()
        displayLink.add(to: RunLoop.current, forMode: .common)
        
        UIView.animate(withDuration: 0.2) {
            toView.alpha = 1
        }
        
        UIView.animate(
            withDuration: transitionProperties.presentPositioningDuration,
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
            withDuration: transitionProperties.presentResizingDuration,
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
        let transitionProperties = fromCardPresentedView.cardTransitionProperties
        let originFrame = fromView.frame
        
        // Call the animation delegate
        toCardViewPresenter.cardViewPresenterWillStartPresenting()
        fromCardPresentedView.cardPresentedViewWillStartDismissing()
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        var preTransitionProgress: CGFloat = 0.0
        
        toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: fromStatusBarStyle)
        
        let startTransitionBlock = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter, weak transitionContext, weak interactor] in
            guard let fromView = fromView, let transitionContext = transitionContext else { return }
            guard let fromCardPresentedView = fromCardPresentedView, let toCardViewPresenter = toCardViewPresenter else { return }
            
            // Call the animation delegate
            toCardViewPresenter.cardViewPresenterDidStartPresenting()
            fromCardPresentedView.cardPresentedViewDidStartDismissing()
            
            let animationStartTime: CFTimeInterval = CACurrentMediaTime()
            let animationDuration: CFTimeInterval = min(transitionProperties.dismissPositioningDuration, transitionProperties.dismissResizingDuration)
            let animationDidUpdate = Action {
                let animationProgress = min(CGFloat((CACurrentMediaTime() - animationStartTime) / animationDuration), 1)
                let curvedProgress = min((log10(1 + animationProgress * 29) / log10(30))*1.4, 1)
                let globalProgress = (1 - preTransitionProgress) * (min(curvedProgress, 1))
                DispatchQueue.main.async {
                    fromCardPresentedView.cardPresentedViewDidUpdateDismissingTransition(progress: globalProgress + preTransitionProgress)
                    toCardViewPresenter.cardViewPresenterDidUpdatePresentingTransition(progress: globalProgress + preTransitionProgress)
                }
            }
            let displayLink: CADisplayLink = CADisplayLink(target: animationDidUpdate, selector: #selector(animationDidUpdate.selector))
            displayLink.add(to: RunLoop.current, forMode: .common)
            
            guard let toCardView = toCardViewPresenter.cardViewPresenterCard else {
                UIView.animate(
                    withDuration: transitionProperties.dismissPositioningDuration,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: [.curveEaseIn],
                    animations: {
                        toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                        fromView.clipsToBounds = true
                        fromView.frame.size = CGSize(width: 108, height: 108)
                        fromView.layoutIfNeeded()
                        fromView.transform = CGAffineTransform(translationX: container.frame.width/2-108/2, y: container.frame.height)
                    },
                    completion: { _ in
                        toCardViewPresenter.cardViewPresenterWillEndPresenting()
                        fromCardPresentedView.cardPresentedViewWillEndDismissing()
                        fromCardPresentedView.cardPresentedViewShouldUpdateBar(to: fromStatusBarStyle)
                        toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                        fromView.removeFromSuperview()
                        displayLink.invalidate()
                        interactor?.finish()
                        transitionContext.completeTransition(true)
                    }
                )
                return
            }
            toCardView.alpha = 0
            
            // Get the coordinates of the view inside the container
            let destinationFrame = CGRect(
                origin: (toCardView.superview ?? toCardView).convert(toCardView.frame.origin, to: toView),
                size: toCardView.frame.size
            )
            
            let yDiff = destinationFrame.origin.y - originFrame.origin.y
            let xDiff = destinationFrame.origin.x - originFrame.origin.x
            
            // Animation completion.
            let completionHandler: (Bool) -> Void = { _ in
                toCardView.alpha = 1
                fromView.layer.shadowOpacity = 0
                toCardViewPresenter.cardViewPresenterWillEndPresenting()
                fromCardPresentedView.cardPresentedViewWillEndDismissing()
                UIView.animate(withDuration: transitionProperties.dismissFadeCardAnimationTime, animations: {
                    fromView.alpha = 0
                }, completion: { _ in
                    fromCardPresentedView.cardPresentedViewShouldUpdateBar(to: fromStatusBarStyle)
                    toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                    fromView.removeFromSuperview()
                    displayLink.invalidate()
                    interactor?.finish()
                    transitionContext.completeTransition(true)
                })
            }
            
            // Put the completion handler on the longest lasting animator
            
            var positionAnimatorHandler: ((Bool) -> ())?
            var sizeAnimatorHandler: ((Bool) -> ())?
            
            if transitionProperties.dismissPositioningDuration > transitionProperties.dismissResizingDuration {
                positionAnimatorHandler = completionHandler
            } else {
                sizeAnimatorHandler = completionHandler
            }
            UIView.animate(
                withDuration: transitionProperties.dismissStatusStyleUpdateDuration, delay: 0,
                options: .allowUserInteraction, animations: {
                    toCardViewPresenter.cardViewPresenterShouldUpdateBar(to: toStatusBarStyle)
                }
            )
            
            UIView.animate(
                withDuration: transitionProperties.dismissPositioningDuration,
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
                withDuration: transitionProperties.dismissResizingDuration,
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
        
        if let interactor = interactor, interactor.interactionInProgress {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            blurView.backgroundColor = transitionProperties.transitionBackgroundColor
            blurView.frame = fromView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            toView.addSubview(blurView)
            
            interactor.cardTransitionInteractorDidFinish = {
                UIView.animate(withDuration: transitionProperties.dismissBlurDuration, animations: {
                    blurView.effect = .none
                    blurView.backgroundColor = .clear
                }, completion: { bool in
                    blurView.removeFromSuperview()
                })
                DispatchQueue.main.async {
                    startTransitionBlock()
                }
            }
            
            interactor.cardTransitionInteractorDidCancel = { [weak fromView, weak fromCardPresentedView, weak toCardViewPresenter, weak transitionContext] in
                fromCardPresentedView?.cardPresentedViewWillCancelDismissing()
                toCardViewPresenter?.cardViewPresenterWillCancelPresenting()
                UIView.animate(
                    withDuration: transitionProperties.cancelTransitionResizingDuration,
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
                preTransitionProgress = min(curvedProgress, 1) * transitionProperties.preDismissingTransitionProgressPortion
                let scale = (1 - preTransitionProgress / 2)
                fromCardPresentedView?.cardPresentedViewDidUpdateDismissingTransition(progress: preTransitionProgress)
                toCardViewPresenter?.cardViewPresenterDidUpdatePresentingTransition(progress: preTransitionProgress)
                fromView?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        } else {
            DispatchQueue.main.async {
                startTransitionBlock()
            }
        }
    }
}

