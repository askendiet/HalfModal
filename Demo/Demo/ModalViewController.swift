//
//  ModalViewController.swift
//  Demo
//
//  Created by takuya osawa on 2020/10/29.
//

import Foundation
import UIKit
import HalfModal

final class ModalViewController: UIViewController {
    class func make() -> ModalViewController {
        let vc = UIStoryboard(name: "ModalViewController", bundle: nil).instantiateInitialViewController() as! ModalViewController
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func topTapped(_ sender: Any) {
        (presentationController as? HalfModalPresentationController)?.updatePosition(modalPosition: .top, animationType: .normal(duration: 0.5))
    }
    
    @IBAction func middleTapped(_ sender: Any) {
        (presentationController as? HalfModalPresentationController)?.updatePosition(modalPosition: .middle, animationType: .normal(duration: 0.5))

    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        (presentationController as? HalfModalPresentationController)?.updatePosition(modalPosition: .bottom, animationType: .normal(duration: 0.5))

    }
}
