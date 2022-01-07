//
//  CTSongCellView.swift
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

class CTSongCellView: UIView {
    
    var didTouchUpInside: (() -> Void)?
    
    // MARK: @IBOutlets
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var iconContainerView: UIView!
    @IBOutlet private var songTitleLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    
    // MARK: Overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchStartedAnimation(touched: true)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartedAnimation(touched: false)
        super.touchesEnded(touches, with: event)
        didTouchUpInside?()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartedAnimation(touched: false)
        super.touchesCancelled(touches, with: event)
    }

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: Public Methods
    
    func updateContent(image: UIImage, title: String, artist: String) {
        iconImageView.image = image
        songTitleLabel.text = title
        artistNameLabel.text = artist
        iconContainerView.layer.shadowColor = UIColor(red: 129/255, green: 175/255, blue: 160/255, alpha: 0.3).cgColor
        songTitleLabel.backgroundColor = .clear
        artistNameLabel.backgroundColor = .clear
        songTitleLabel.clipsToBounds = false
        artistNameLabel.clipsToBounds = false
        songTitleLabel.layer.shadowRadius = 0
        artistNameLabel.layer.shadowRadius = 0
    }
    
    // MARK: Private Methods

    private func commonInit() {
        Bundle.main.loadNibNamed("CTSongCellView", owner: self, options: nil)
        addSubview(contentView)
        self.backgroundColor = .clear
        self.layer.shadowRadius = 16
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.systemFill.cgColor
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.1).cgColor
        iconImageView.layer.cornerRadius = 8
        iconContainerView.layer.shadowRadius = 12
        iconContainerView.layer.shadowOpacity = 0.5
        iconContainerView.layer.shadowOffset = .zero
        iconContainerView.layer.shadowColor = UIColor.systemFill.cgColor
        [songTitleLabel, artistNameLabel].forEach { (view) in
            view?.layer.cornerRadius = 7
            view?.clipsToBounds = true
        }
    }
    
    private func touchStartedAnimation(touched: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .allowUserInteraction,
            animations: {
                if touched {
                    self.layer.shadowRadius = 8
                    self.transform = CGAffineTransform.identity.scaledBy(x: 0.93, y: 0.93)
                } else {
                    self.layer.shadowRadius = 16
                    self.transform = .identity
                }
            }
        )
    }
}
