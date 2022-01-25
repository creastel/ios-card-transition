//
//  SongPresentationViewController.swift
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

class SongPresentationViewController: UIViewController {
    
    private var currentStatusBarStyle: UIStatusBarStyle = .default
    override var preferredStatusBarStyle: UIStatusBarStyle { currentStatusBarStyle }
    
    // MARK: CSCardPresentedView Requirements
    
    lazy var cardTransitionInteractor: CSCardTransitionInteractor = CSCardTransitionInteractor(viewController: self)
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var lyricsCellView: CTLyricsCellView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // Constraints for small View
    @IBOutlet var smallConstraints: [NSLayoutConstraint]!
    
    // Constraints for big View
    @IBOutlet var bigConstraints: [NSLayoutConstraint]!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.systemFill.cgColor
        viewContainer.layer.cornerRadius = 12
        viewContainer.layer.borderWidth = 1
        viewContainer.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.1).cgColor
        lyricsCellView.iconImageView.layer.cornerRadius = 8
        lyricsCellView.titleLabel.alpha = 0
        activateSmallConstraint()
        lyricsCellView.didTouchUpInside = cellPressed
        viewContainer.clipsToBounds = true
    }
    
    // MARK: Private Methods
    
   @objc private func cellPressed() {
        let viewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(identifier: "LyricsPresentation")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func activateSmallConstraint() {
        bigConstraints.forEach { (constraint) in
            constraint.isActive = false
        }
        smallConstraints.forEach { (constraint) in
            constraint.isActive = true
        }
    }
    
    private func activateBigConstraint() {
        smallConstraints.forEach { (constraint) in
            constraint.isActive = false
        }
        bigConstraints.forEach { (constraint) in
            constraint.isActive = true
        }
    }
}

extension SongPresentationViewController: CSCardPresentedView {
    
    func cardPresentedViewDidStartPresenting() {
        // Layout changes are automatically animated when written here
        activateBigConstraint()
    }
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat) {
        viewContainer.layer.cornerRadius = 12-progress*12
        lyricsCellView.iconImageView.layer.cornerRadius = 8 + 4*progress
        titleLabel.font = titleLabel.font.withSize(18+progress*6)
        subtitleLabel.font = subtitleLabel.font.withSize(14+progress*4)
        lyricsCellView.titleLabel.alpha = progress
    }
    func cardPresentedViewWillEndPresenting() {
        viewContainer.layer.cornerRadius = 0
        lyricsCellView.iconImageView.layer.cornerRadius = 12
        titleLabel.font = titleLabel.font.withSize(24)
        subtitleLabel.font = subtitleLabel.font.withSize(18)
        lyricsCellView.titleLabel.alpha = 1
    }
    
    func cardPresentedViewWillCancelDismissing() {
        cardPresentedViewWillEndPresenting()
    }
    func cardPresentedViewDidStartDismissing() {
        activateSmallConstraint()
    }
    func cardPresentedViewDidUpdateDismissingTransition(progress: CGFloat) {
        viewContainer.layer.cornerRadius = min(progress*4, 1)*12
        lyricsCellView.iconImageView.layer.cornerRadius = 12 - 4*progress
        titleLabel.font = titleLabel.font.withSize(18+(1-progress)*6)
        subtitleLabel.font = subtitleLabel.font.withSize(14+(1-progress)*4)
        lyricsCellView.titleLabel.alpha = 1-progress
    }
    func cardPresentedViewWillEndDismissing() {
        viewContainer.layer.cornerRadius = 12
        titleLabel.font = titleLabel.font.withSize(18)
        subtitleLabel.font = subtitleLabel.font.withSize(14)
        lyricsCellView.iconImageView.layer.cornerRadius = 8
        lyricsCellView.titleLabel.alpha = 0
    }
}

extension SongPresentationViewController: CSCardViewPresenter {
    var cardViewPresenterCard: UIView? {
        return lyricsCellView
    }

    // Update Bar Style
    func cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle) {
        currentStatusBarStyle = style
        setNeedsStatusBarAppearanceUpdate()
    }
}
