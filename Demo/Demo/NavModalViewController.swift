//
//  ModalViewController.swift
//  Demo
//
//  Created by takuya osawa on 2020/10/29.
//

import Foundation
import UIKit
import HalfModal

final class NavModalViewController: UITableViewController, HalfModalPresenter {
    class func make() -> NavModalViewController {
        let vc = UIStoryboard(name: "NavModalViewController", bundle: nil).instantiateInitialViewController() as! NavModalViewController
        return vc
    }
    
    var targetScrollView: UIScrollView? {
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.reloadData()
        if let controller = navigationController as? NavigationController {
            controller.halfModalPresentationController?.didChangeModalPosition = { p in
                print(p)
            }
            
            controller.halfModalPresentationController?.didChangeOriginY = { y in
                print(y)
            }
        }    
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    private let array: [Int] = (0...100).map({ $0 })
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            return tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self)) ?? UITableViewCell()
        }
        cell.textLabel?.text = array[indexPath.row].description
        return cell
    }
}
