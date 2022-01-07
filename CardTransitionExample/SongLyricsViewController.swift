//
//  SongLyricsViewController.swift
//  CardTransitionExample
//
//  Created by Jean Haberer on 09/12/2020.
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
import CSCardTransition

class SongLyricsViewController: UIViewController {
    
    private var currentStatusBarStyle: UIStatusBarStyle = .lightContent
    override var preferredStatusBarStyle: UIStatusBarStyle { currentStatusBarStyle }
    
    // MARK: CSCardPresentedView Requirements
    
    lazy var cardTransitionInteractor: CSCardTransitionInteractor = CSCardTransitionInteractor(viewController: self)
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var lyricsCellView: CTLyricsCellView!
    @IBOutlet weak var viewContainer: UIView!

    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.systemFill.cgColor
        lyricsCellView.contentView.layer.shadowOpacity = 0
        lyricsCellView.iconImageView.layer.cornerRadius = 0
        viewContainer.clipsToBounds = true
    }
}

extension SongLyricsViewController: CSCardPresentedView {
    
    /// Presenting the View
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat) {
        viewContainer.layer.cornerRadius = 12-progress*12
        lyricsCellView.titleLabel.font = lyricsCellView.titleLabel.font.withSize(24+progress*24)
    }
    func cardPresentedViewWillEndPresenting() {
        viewContainer.layer.cornerRadius = 0
        lyricsCellView.titleLabel.font = lyricsCellView.titleLabel.font.withSize(48)
    }
    
    /// Dismissing the view
    func cardPresentedViewWillCancelDismissing() {
        cardPresentedViewWillEndPresenting()
    }
    func cardPresentedViewDidUpdateDismissingTransition(progress: CGFloat) {
        viewContainer.layer.cornerRadius = min(progress*4, 1)*12
        lyricsCellView.titleLabel.font = lyricsCellView.titleLabel.font.withSize(48-progress*24)
    }
    func cardPresentedViewWillEndDismissing() {
        viewContainer.layer.cornerRadius = 12
        lyricsCellView.titleLabel.font = lyricsCellView.titleLabel.font.withSize(24)
    }
    
    /// Update Bar Style
    func cardPresentedViewShouldUpdateBar(to style: UIStatusBarStyle) {
        currentStatusBarStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
}
