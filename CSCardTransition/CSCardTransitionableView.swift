//
//  CSCardTransitionableView.swift
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

public protocol CSCardViewPresenter: AnyObject {
    // MARK: Variables
    
    /// Must return the UIView located in this View Controller used as the Card for the push transition.
    var cardViewPresenterCard: UIView? { get }
    
    // MARK: Methods
    
    // Dismissing the current view to present the embeded view
    
    /// Called when the transition to the card view controller just started.
    func cardViewPresenterDidStartDismissing()
    /// Called when the transition to the card view controller is currently in progress
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardViewPresenterDidUpdateDismissingTransition(progress: CGFloat)
    /// Called when the transition to the card view controller is about to end.
    func cardViewPresenterWillEndDismissing()
    
    // Presenting the view back to the user
    
    /// Called when the transition back to this view controller is about to start.
    func cardViewPresenterWillStartPresenting()
    /// Called when the transition back to this view controller has started.
    func cardViewPresenterDidStartPresenting()
    /// Called when the transition back to this view controller is about to be canceled.
    func cardViewPresenterWillCancelPresenting()
    /// Called when the transition back to this view controller is currently in progress.
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardViewPresenterDidUpdatePresentingTransition(progress: CGFloat)
    /// Called when the transition back to this view controller is about to be completed.
    func cardViewPresenterWillEndPresenting()
    
    // Status Bar Style Update
    
    /// Called when the status bar style should be updated to match the transition progress
    /// This should be added to all View Controller (Presenter and Presented) if your application
    /// is using different status bar styles from one view controller to another.
    ///
    /// - Parameter style: The style that the view controller status bar must match
    /// - Requires: That you implement a code updating the status bar style (you can find an example in the cocoapod's repo)
    /// - Note: You don't need to animate the transition of the status bar style, the library does it already.
    ///
    func cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle)
}
public protocol CSCardPresentedView: AnyObject {
    // MARK: Variables
    
    /// The CSCardTransitionInteractor used in your View Controller for the pop transition.
    var cardTransitionInteractor: CSCardTransitionInteractor? { get }
    /// A Boolean indicating whether or not the card transition should occur.
    var cardTransitionEnabled: Bool { get }
    /// A variable enabling you to customize the transition properties (durations, animation, ...)
    var cardTransitionProperties: CSCardTransitionProperties { get }
    
    // MARK: Methods
    
    // Present the view with transition
    
    /// Called when the transition to this view controller is about to start.
    /// - Parameter cardView: The UIView used in the parent view controller to start the transitinon.
    func cardPresentedViewWillStartPresenting(from cardView: UIView)
    /// Called when the transition to this view controller just started.
    func cardPresentedViewDidStartPresenting()
    /// Called when the transition to this view controller is currently in progress.
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat)
    /// Called when the transition to this view controller is about to end.
    func cardPresentedViewWillEndPresenting()
    
    // Dismiss the view with transition
    
    /// Called when the transition back to the parent view controller is about to start.
    func cardPresentedViewWillStartDismissing()
    /// Called when the transition back to the parent view controller has started.
    func cardPresentedViewDidStartDismissing()
    /// Called when the transition back to the parent view controller is about to be canceled.
    func cardPresentedViewWillCancelDismissing()
    /// Called when the transition back to the parent view controller is currently in progress.
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardPresentedViewDidUpdateDismissingTransition(progress: CGFloat)
    /// Called when the transition back to the parent view controller is about to be completed.
    func cardPresentedViewWillEndDismissing()
    
    // Status Bar Style Update
    
    /// Called when the status bar style should be updated to match the transition progress
    /// This should be added to all View Controller (Presenter and Presented) if your application
    /// is using different status bar styles from one view controller to another.
    ///
    /// - Parameter style: The style that the view controller status bar must match
    /// - Requires: That you implement a code updating the status bar style (you can find an example in the cocoapod's repo)
    /// - Note: You don't need to animate the transition of the status bar style, the library does it already.
    ///
    func cardPresentedViewShouldUpdateBar(to style: UIStatusBarStyle)
}

// MARK: Default implementations
public extension CSCardViewPresenter {
    func cardViewPresenterWillStartPresenting() {}
    func cardViewPresenterWillCancelPresenting() {}
    func cardViewPresenterDidStartPresenting() {}
    func cardViewPresenterWillEndPresenting() {}
    func cardViewPresenterDidUpdatePresentingTransition(progress: CGFloat) {}
    func cardViewPresenterDidStartDismissing() {}
    func cardViewPresenterWillEndDismissing() {}
    func cardViewPresenterDidUpdateDismissingTransition(progress: CGFloat) {}
    func cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle) {}
}
public extension CSCardPresentedView {
    var cardTransitionEnabled: Bool { true }
    var cardTransitionProperties: CSCardTransitionProperties { return .normal }
    func cardPresentedViewWillStartPresenting(from cardView: UIView) {}
    func cardPresentedViewDidStartPresenting() {}
    func cardPresentedViewWillEndPresenting() {}
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat) {}
    func cardPresentedViewWillStartDismissing() {}
    func cardPresentedViewWillCancelDismissing() {}
    func cardPresentedViewDidStartDismissing() {}
    func cardPresentedViewWillEndDismissing() {}
    func cardPresentedViewDidUpdateDismissingTransition(progress: CGFloat) {}
    func cardPresentedViewShouldUpdateBar(to style: UIStatusBarStyle) {}
}
