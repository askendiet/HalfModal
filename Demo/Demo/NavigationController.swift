//
//  NavigationController.swift
//  Demo
//
//  Created by takuya osawa on 2020/10/29.
//

import Foundation
import UIKit
import HalfModal

class NavigationController: UINavigationController, HalfModalPresenter {
    var targetScrollView: UIScrollView? {
        return (topViewController as? HalfModalPresenter)?.targetScrollView
    }
}
