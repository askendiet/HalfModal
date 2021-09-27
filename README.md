# HaldModal

- A library for displaying viewController with HaldModal.

## Demo

![demo](https://github.com/asken-private/HalfModal/blob/master/Screenshots/screen.gif)

## Requirements
- iOS 12
- Xcode 12

## Example
```swift
import Foundation
import UIKit
import HalfModal

final class FirstViewController: UIViewController, HalfModalPresenter {
    
    @IBAction func tap(_ sender: Any) {
        let vc = TableViewController()
        presentHalfModal(vc, animated: true, transitioningDelegate: .default, completion: nil)
    }
}
```

## Installation
### Swift Package Manager
```
git@github.com:asken-private/HalfModal.git
```

## References
- https://pspdfkit.com/blog/2015/presentation-controllers/
- https://qiita.com/t_osawa_009/items/b4cab51f98e7aa1d3228

## License
HalfModal is released under the MIT license. See LICENSE for details.
