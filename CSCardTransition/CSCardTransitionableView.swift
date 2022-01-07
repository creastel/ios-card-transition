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
    var cardViewPresenterCard: UIView? { get }
    
    // MARK: Methods
    /// Presenting the view back to the user
    func cardViewPresenterWillStartPresenting()
    func cardViewPresenterWillCancelPresenting()
    func cardViewPresenterDidStartPresenting()
    func cardViewPresenterWillEndPresenting()
    func cardViewPresenterDidUpdatePresentingTransition(progress: CGFloat)
    /// Dismissing the current view to present the embeded view
    func cardViewPresenterDidStartDismissing()
    func cardViewPresenterWillEndDismissing()
    func cardViewPresenterDidUpdateDismissingTransition(progress: CGFloat)
    /// Status Bar Style Update
    func cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle)
}
public protocol CSCardPresentedView: AnyObject {
    // MARK: Variables
    var cardTransitionInteractor: CSCardTransitionInteractor { get }
    var cardTransitionEnabled: Bool { get }
    
    // MARK: Methods
    /// Present the view with transition
    func cardPresentedViewDidStartPresenting()
    func cardPresentedViewWillEndPresenting()
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat)
    /// Dismiss the view with transition
    func cardPresentedViewWillStartDismissing()
    func cardPresentedViewWillCancelDismissing()
    func cardPresentedViewDidStartDismissing()
    func cardPresentedViewWillEndDismissing()
    func cardPresentedViewDidUpdateDismissingTransition(progress: CGFloat)
    /// Status Bar Style Update
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
