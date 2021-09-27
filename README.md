# HaldModal

- A library for displaying viewController with HaldModal.

## Demo

![demo](https://github.com/askendiet/HalfModal/blob/master/Screenshots/screen.gif)

## Requirements
- iOS 12
- Xcode 12.5

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
https://github.com/askendiet/HalfModal.git
```

## References
- https://pspdfkit.com/blog/2015/presentation-controllers/
- https://qiita.com/t_osawa_009/items/b4cab51f98e7aa1d3228

## License
HalfModal is released under the MIT license. See LICENSE for details.
