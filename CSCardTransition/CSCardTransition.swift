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
            let toVC = toVC as? CSCardPresentedView,
            fromVC.cardViewPresenterCard != nil,
            toVC.cardTransitionEnabled
        {
            return CSCardTransitionAnimation(operation: operation, interactor: toVC.cardTransitionInteractor)
        } else if
            operation == .pop,
            toVC is CSCardViewPresenter,
            let fromVC = fromVC as? CSCardPresentedView,
            fromVC.cardTransitionEnabled
        {
            return CSCardTransitionAnimation(operation: operation, interactor: fromVC.cardTransitionInteractor)
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

        guard let interactor = (animationController as? CSCardTransitionAnimation)?.interactor else { return nil }
        return interactor.interactionInProgress ? interactor : nil
    }
}
