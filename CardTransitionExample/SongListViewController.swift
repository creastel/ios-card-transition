//
//  SongListViewController.swift
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

class SongListViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var songCellView: CTSongCellView!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songCellView.updateContent(
            image: UIImage(named: "singer")!,
            title: "Can't wait for it!",
            artist: "Jordan Derulo"
        )
        songCellView.didTouchUpInside = cellPressed
    }
    
    // MARK: Private Methods
    
   @objc private func cellPressed() {
        let viewController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(identifier: "SongPresentation")
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SongListViewController: CSCardViewPresenter {
    var cardViewPresenterCard: UIView? {
        return songCellView
    }
}
