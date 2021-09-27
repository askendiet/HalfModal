import UIKit
import HalfModal

final class TableViewController: UITableViewController, HalfModalPresenter {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Half modal list"
        tableView.tableFooterView = .init()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)
        let items = ItemType.allCases.map({ Item(itemType: $0) })
        snapshot.appendItems(items, toSection: .first)
        dataSource.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc: UIViewController = {
            switch item.itemType {
            case .modal:
                return ModalViewController.make()
            case .navigation:
                let vc = NavModalViewController.make()
                vc.title = item.itemType.rawValue
                let nav = NavigationController(rootViewController: vc)
                return nav
            case .tableModal:
                return ModalTableViewController.make()
            }
        }()
        
        if presentedViewController == nil {
            self.presentHalfModal(vc,
                                  animated: true,
                                  transitioningDelegate: HalfModalTransitioningDelegate(style: .init(size: .full,
                                                                                                     defaultPosition: .bottom,
                                                                                                     topOffsetY: view.safeAreaInsets.top,
                                                                                                     bottomOffsetY: view.safeAreaInsets.bottom + 50, bounceDuration: 0.5)),
                                  completion: nil)
        } else {
            dismiss(animated: false, completion: {
                self.presentHalfModal(vc,
                                      animated: true,
                                      transitioningDelegate: HalfModalTransitioningDelegate(style: .init(size: .full,
                                                                                                         defaultPosition: .bottom,
                                                                                                         topOffsetY: self.view.safeAreaInsets.top,
                                                                                                         bottomOffsetY: self.view.safeAreaInsets.bottom + 50, bounceDuration: 0.5)),
                                      completion: nil)
            })
        }
    }
    
    enum Section: String, CaseIterable {
        case first
    }
    
    enum ItemType: String, CaseIterable {
        case navigation
        case modal
        case tableModal
    }
    
    struct Item: Hashable {
        let id: String  = UUID().uuidString
        let itemType: ItemType
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Item> = {
        let dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) {
            (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.itemType.rawValue
            return cell
        }
        
        return dataSource
    }()
}
