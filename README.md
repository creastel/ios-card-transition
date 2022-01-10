# CSCardTransition

[![Version](https://img.shields.io/cocoapods/v/CSCardTransition.svg)](http://cocoapods.org/pods/CSCardTransition)
![Xcode 10.0+](https://img.shields.io/badge/Xcode-10.0%2B-blue.svg)
![iOS 10.0+](https://img.shields.io/badge/iOS-10.0%2B-blue.svg)
![Swift 5.0+](https://img.shields.io/badge/Swift-5.0%2B-blue.svg)
[![License](https://img.shields.io/cocoapods/l/CSCardTransition.svg)](https://github.com/appssemble/CSCardTransition/blob/master/LICENSE?raw=true)

**CSCardTransition** is a small library allowing you to create wonderful `push` and `pop` transition animations like in the App Store. 
It works side by side with your navigation controller, and ensure that you only code what's necessary for your custom transition.
You can use _CocoaPod_ to add this library to your project.

<table>
  <tr>
    <td><a href="https://github.com/Creastel/CSCardTransition">CSCardTransitionExample</a></td>
     <td><a href="https://creas.tel/ontime">On Time - Available on the App Store</a></td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/25668948/148649687-4dbd1371-89f4-4943-a619-d89b45168925.gif" width=270></td>
    <td><img src="https://user-images.githubusercontent.com/25668948/148735697-cfff7415-7969-4f18-a510-3101519705c6.gif" width=270></td>
  </tr>
</table>


## How to implement the transition in your project?

After creating a _"Card Presenter"_ View Controller and your _"Presented Card"_ View Controller, you will simply need to follow this steps:

### Card View Presenter (Required step)
In the View Controller that serves as the view "Presenter", in other word, in the View Controller that contains the card to be expanded, you will need to add the `CSCardViewPresenter` protocol and define what `UIView` should be used as the card to be presented:
``` swift
extension YourViewController: CSCardViewPresenter {
    var cardViewPresenterCard: UIView? {
        return cardView // Return the view that represents the start of your transition
    }
}
```
### Presented Card View (Required step)
In the View Controller that serves as the "Presented" card view, in other word, in the View Controller that is the expanded Card View, you will need to define a `CSCardTransitionInteractor` and add the `CSCardPresentedView` protocol:
``` swift
class YourViewController: UIViewController {
    ...
    // To enable the drag gesture to pop out the card view and go back to the parent view controller.
    lazy var cardTransitionInteractor: CSCardTransitionInteractor = CSCardTransitionInteractor(viewController: self)
    ...
}
extension YourViewController: CSCardPresentedView {
    ... // You will probably add certain methods here later.
}
```

### Status Bar Style Transition (Optional step)

If your status bar style is different from one view to the other, you will need to implement the `cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle)` protocol in the Card Presenter View Controller **and** in the Presented Card View Controller so that the transition stays smooth. To do so, you may want to add a new var that determines the current status bar style like in the following example:

``` swift
class YourViewController: UIViewController {
    ...
    // /!\ Set the following var to the style of the status bar in you view controller (here: .default)
    private var currentStatusBarStyle: UIStatusBarStyle = .default
    override var preferredStatusBarStyle: UIStatusBarStyle { currentStatusBarStyle } // Overrides the status bar style
    ...
}
extension YourViewController: CSCardViewPresenter // Do the same for the CSCardPresentedView {
    ...
    /// Called when the status bar style should be updated to match the transition progress
    func cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle) {
        currentStatusBarStyle = style
        setNeedsStatusBarAppearanceUpdate() // Tell the OS to change the status bar style
    }
}
```

### Custom transition in the Presented view (Optional _but often followed_ step)
You may want to customize you transition by disabling/enabling/updating layout constraints, changing view's alpha, corner radius, ... You may also want to disable the card transition at some point for some reason _(for example when you don't know if the card view is still on screen in the Parent View Controller)_.
You can do so by implementing the following methods. You can read the code example to get some ideas.

``` swift
extension YourViewController: CSCardPresentedView {
    /// A Boolean indicating whether or not the card transition should occur.
    var cardTransitionEnabled: Bool { get }
        
    /// Called when the transition to this view controller just started.
    func cardPresentedViewDidStartPresenting() {}
    /// Called when the transition to this view controller is currently in progress
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat) {}
    /// Called when the transition to this view controller is about to end.
    func cardPresentedViewWillEndPresenting() {}
        
    /// Called when the transition back to the parent view controller is about to start.
    func cardPresentedViewWillStartDismissing() {}
    /// Called when the transition back to the parent view controller has started.
    func cardPresentedViewDidStartDismissing() {}
    /// Called when the transition back to the parent view controller is about to be canceled.
    func cardPresentedViewWillCancelDismissing() {}
    /// Called when the transition back to the parent view controller is currently in progress.
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardPresentedViewDidUpdateDismissingTransition(progress: CGFloat) {}
    /// Called when the transition back to the parent view controller is about to be completed.
    func cardPresentedViewWillEndDismissing() {}
}
```

### Custom transition in the View Presenter (Optional step)
You may want to customize you transition in the presenter by disabling/enabling layout constraints, changing view's alpha, corner radius, ... You can do so by implementing the following methods. You can read the code example to get some ideas.

``` swift
extension YourViewController: CSCardViewPresenter {
    /// Called when the transition to the card view controller just started.
    func cardViewPresenterDidStartDismissing() {}
    /// Called when the transition to the card view controller is currently in progress
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardViewPresenterDidUpdateDismissingTransition(progress: CGFloat) {}
    /// Called when the transition to the card view controller is about to end.
    func cardViewPresenterWillEndDismissing() {}
    
    /// Called when the transition back to this view controller is about to start.
    func cardViewPresenterWillStartPresenting() {}
    /// Called when the transition back to this view controller has started.
    func cardViewPresenterDidStartPresenting() {}
    /// Called when the transition back to this view controller is about to be canceled.
    func cardViewPresenterWillCancelPresenting() {}
    /// Called when the transition back to this view controller is currently in progress.
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardViewPresenterDidUpdatePresentingTransition(progress: CGFloat) {}
    /// Called when the transition back to this view controller is about to be completed.
    func cardViewPresenterWillEndPresenting() {}
}
```

### Good to know
A `CSCardPresentedView` can also be a `CSCardViewPresenter`, that is what makes this library so powerful ;)

## Informations

This library is brought to you by <b>[Creastel](https://creas.tel)</b>.
<br/>
You can reach us at [hello@creastel.com](mailto:hello@creastel.com).
