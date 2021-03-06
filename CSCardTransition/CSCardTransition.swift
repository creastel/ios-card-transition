//
//  CSCardTransition.swift
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

public class CSCardTransition {
    
    /// Change this static variable to true to slow down the
    /// transition animations.
    public static var debug = false
    
    /// Returns the Card Transition Animation Controller if the transition
    /// is set up and enabled.
    /// Use this method to swizzle your Navigation Controller.
    ///
    /// - Parameters:
    ///     - navigationController: The current *navigationController*.
    ///     - animationControllerFor: The current transition *operation*.
    ///     - from: The current *View Controller*.
    ///     - to: The *View Controller* to be presented.
    ///
    /// - Returns: An *UIViewControllerAnimatedTransitioning* to be used for the Card Transition.
    ///
    public static func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        if
            operation == .push,
            let fromVC = fromVC as? CSCardViewPresenter,
            let fromCard = fromVC.cardViewPresenterCard,
            let toVC = toVC as? CSCardPresentedView,
            toVC.cardTransitionEnabled,
            fromVC.cardViewPresenterCard != nil
        {
            return CSCardTransitionAnimation(operation: operation, interactor: toVC.cardTransitionInteractor, cardViewPresenterCard: fromCard)
        } else if
            operation == .pop,
            let toVC = toVC as? CSCardViewPresenter,
            let toCard = toVC.cardViewPresenterCard,
            let fromVC = fromVC as? CSCardPresentedView,
            fromVC.cardTransitionEnabled,
            toVC.cardViewPresenterCard != nil
        {
            return CSCardTransitionAnimation(operation: operation, interactor: fromVC.cardTransitionInteractor, cardViewPresenterCard: toCard)
        }
        return nil
    }

    /// Called by your Navigation Controller to allow the delegate to return the
    /// interactive animator object for use during Card Transition.
    /// Use this method to swizzle your Navigation Controller.
    ///
    /// - Parameters:
    ///     - navigationController: The current *navigationController*.
    ///     - interactionControllerFor: The current *animationController*.
    ///
    /// - Returns: The Card Transition's *UIViewControllerInteractiveTransitioning* interactor if interaction is in progress, nil otherwise.
    ///
    public static func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {

        guard let interactor = (navigationController.viewControllers.last as? CSCardPresentedView)?.cardTransitionInteractor else { return nil }
        return interactor.interactionInProgress ? interactor : nil
    }
}
