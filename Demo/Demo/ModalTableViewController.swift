//
//  TableViewController.swift
//  Demo
//
//  Created by takuya osawa on 2020/10/29.
//

import Foundation
import UIKit
import HalfModal

final class ModalTableViewController: UITableViewController, HalfModalPresenter {
    class func make() -> ModalTableViewController {
        let vc = UIStoryboard(name: "ModalTableViewController", bundle: nil).instantiateInitialViewController() as! ModalTableViewController
        return vc
    }
    
    var targetScrollView: UIScrollView? {
        return tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.reloadData()
    }
    
    private let array: [Int] = (0...100).map({ $0 })
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = array[indexPath.row].description
        return cell!
    }
}

