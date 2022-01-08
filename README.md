# CSCardTransition
CSCardTransition is a small library allowing you to create a wonderful 'push' and 'pop' transition animation like in the AppStore. 
It works perfecty well with a navigation controller, and ensure that you only code what's necessary for your custom transition.
You can use cocoapod to add this library to your project.

<img src="https://user-images.githubusercontent.com/25668948/148649687-4dbd1371-89f4-4943-a619-d89b45168925.gif" width="200"/>

## How to implement the transition in your project?

After creating your card view and your View Controllers, you will simply need to follow this steps:

### Card View Presenter (Required step)
In the View Controller that serves as the view "Presenter", in other word, in the View Controller that contains the card to be expanded, you will need to add the CSCardViewPresenter protocol:
``` swift
extension YourViewController: CSCardViewPresenter {
    var cardViewPresenterCard: UIView? {
        return cardView // The 'card view' that will be expanded in this view controller.
    }
}
```
### Presented Card View (Required step)
In the View Controller that serves as the "Presented" card view, in other word, in the View Controller that is the expanded Card View, you will need to add the CSCardPresentedView protocol:
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

If your status bar style is different from one view to the other, you will need to implement the `cardViewPresenterShouldUpdateBar(to style: UIStatusBarStyle)` protocol in the presenter and the presented view controller so that the transition stays smooth. To do so, you may want to add a var that determines the current status bar style like in the following example:

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

### Custom transition in the View Presenter (Optional step)
You may want to custom you transition by disabling/enabling layout constraints, changing view's alpha, corner radius, ... You can do so by implementing the following methods. You can read the code example to have some ideas.

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

### Custom transition in the Presented view (Optional step)
You may want to custom you transition by disabling/enabling layout constraints, changing view's alpha, corner radius, ... You may also want to disable the card transition at some point for some reasons.
You can do so by implementing the following methods. You can read the code example to have some ideas.

``` swift
extension YourViewController: CSCardPresentedView {
    /// A Boolean indicating whether or not the card transition should occur.
    var cardTransitionEnabled: Bool { get }
        
    /// Called when the transition to this view controller just started.
    func cardPresentedViewDidStartPresenting()
    /// Called when the transition to this view controller is currently in progress
    /// - Parameter progress: The current progress of the transition (between 0 and 1)
    func cardPresentedViewDidUpdatePresentingTransition(progress: CGFloat)
    /// Called when the transition to this view controller is about to end.
    func cardPresentedViewWillEndPresenting()
        
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
}
```

## Notes
A View Presenter can also be a Presented View, that is what makes this library powerful ;)
