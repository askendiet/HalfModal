#if os(iOS) || os(tvOS)
import Foundation
import UIKit

public protocol HalfModalPresenter: AnyObject {
    func presentHalfModal(_ viewControllerToPresent: UIViewController, animated flag: Bool, transitioningDelegate: HalfModalTransitioningDelegate, completion: (() -> Void)?)
    var targetScrollView: UIScrollView? { get }
    
    var halfModalPresentationController: HalfModalPresentationController? { get }
}

public extension HalfModalPresenter {
    var targetScrollView: UIScrollView? {
        return nil
    }
    
    var halfModalPresentationController: HalfModalPresentationController? {
        return nil
    }
}

public extension HalfModalPresenter where Self: UIViewController {
    func presentHalfModal(_ viewControllerToPresent: UIViewController, animated flag: Bool, transitioningDelegate: HalfModalTransitioningDelegate, completion: (() -> Void)?) {
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = transitioningDelegate
        present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    var halfModalPresentationController: HalfModalPresentationController? {
        return presentationController as? HalfModalPresentationController
    }
}

public final class HalfModalPresentationController: UIPresentationController {
    public enum Size {
        case full
        case half
        case custom(CGFloat)
    }
    
    public enum ModalPosition {
        case top
        case middle
        case bottom
    }
    
    public enum AnimationType {
        case normal(duration: TimeInterval)
        case bounce(duration: TimeInterval)
    }
    
    public var halfModalStyle: HalfModalStyle = .default
    convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, style: HalfModalStyle) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.halfModalStyle = style
    }
    
    private override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // 呼び出し元のView Controller
    private var presenter: HalfModalPresenter? {
        return presentedViewController as? HalfModalPresenter
    }
  
    public var didChangeModalPosition: ((ModalPosition) -> Void)?
    public private(set) var currentModalPosition: ModalPosition = .bottom {
        didSet {
            didChangeModalPosition?(currentModalPosition)
        }
    }
    private var targetScrollView: UIScrollView? {
        return presenter?.targetScrollView
    }
    // Container View のサイズを指定
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        return CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
    }
    
    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
        guard let containerView = containerView else {
            return
        }
        
        switch currentModalPosition {
        case .top:
            updateContainerOriginY(halfModalStyle.topOffsetY)
            targetScrollView?.isScrollEnabled = true
        case .middle:
            updateContainerOriginY(containerView.bounds.height / 2)
            targetScrollView?.isScrollEnabled = false
        case .bottom:
            updateContainerOriginY(containerView.bounds.maxY - halfModalStyle.bottomOffsetY)
            targetScrollView?.isScrollEnabled = false
        }
    }
    
    public func updatePosition(modalPosition: HalfModalPresentationController.ModalPosition, animationType: AnimationType?) {
        guard let containerView = containerView else {
            return
        }
        
        let action: () -> () = {
            switch modalPosition {
            case .top:
                self.updateContainerOriginY(self.halfModalStyle.topOffsetY)
                self.currentModalPosition = .top
                self.targetScrollView?.isScrollEnabled = true
            case .middle:
                self.updateContainerOriginY(containerView.bounds.height / 2)
                self.currentModalPosition = .middle
                self.targetScrollView?.isScrollEnabled = false
            case .bottom:
                self.updateContainerOriginY(containerView.bounds.maxY - self.halfModalStyle.bottomOffsetY)
                self.currentModalPosition = .bottom
                self.targetScrollView?.isScrollEnabled = false
            }
        }
        if let animationType = animationType {
            switch animationType {
            case .normal(duration: let duration):
                UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut]) {
                    action()
                }
            case .bounce(duration: let duration):
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: { () -> Void in
                    action()
                })
            }
        } else {
            action()
        }
        
        viewPositionY = 0.0
    }
    
    public var didChangeOriginY: ((CGFloat) -> Void)?
    
    private func updateContainerOriginY(_ originY: CGFloat) {
        containerView?.frame.origin.y = originY
        didChangeOriginY?(originY - halfModalStyle.topOffsetY)
    }
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanOnPresentedView(_ :)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()

    // 表示トランジション開始前に呼ばれる
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addGestureRecognizer(panGestureRecognizer)
        
        self.scrollObserver = targetScrollView?.observe(\.contentOffset, options: [.initial], changeHandler: { [weak self] _, _ in
            self?.scrollViewDidScroll()
        })
        let directionList: [UISwipeGestureRecognizer.Direction] = [.up, .down]
        
        directionList.forEach { (direction) in
            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipePresentedView(_:)))
            swipeRecognizer.direction = direction
            swipeRecognizer.delegate = self
            containerView?.addGestureRecognizer(swipeRecognizer)
        }
    }
    
    private func scrollViewDidScroll() {
        guard let scrollView = targetScrollView else {
            return
        }
        
        let offset: CGFloat = scrollView.contentOffset.y + scrollView.contentInset.top + scrollView.safeAreaInsets.top
        if offset > 0 {
            scrollView.bounces = true
        } else {
            if !scrollView.isDecelerating {
                scrollView.bounces = false
            }
        }
    }
    
    private var isScrollTop: Bool {
        let contentOffsetY = targetScrollView?.contentOffset.y ?? 0.0
        return contentOffsetY <= 0.0
    }
    
    private var viewPositionY: CGFloat = 0.0
    private var startPositionY: CGFloat = 0.0
    @objc func didPanOnPresentedView(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startDragging()
        case .changed:
            switch currentModalPosition {
            case .top:
                if isScrollTop {
                    //移動量を取得
                    let diff = recognizer.translation(in: recognizer.view).y
                    updateOffset(diff)
                }
            case .middle, .bottom:
                //移動量を取得
                let diff = recognizer.translation(in: recognizer.view).y
                updateOffset(diff)
            }
            //移動量を0に
            recognizer.setTranslation(.zero, in: recognizer.view)
        case .ended:
            // 近い位置にポジションを変える
            finishDragging(velocity: .zero)
        default:
            break
        }
    }
    
    @objc func didSwipePresentedView(_ recognizer: UISwipeGestureRecognizer) {
        guard isScrollTop else {
            return
        }
        
        switch recognizer.direction {
        case .up:
            switch currentModalPosition {
            case .top:
                break
            case .middle:
                updatePosition(modalPosition: .top, animationType: .bounce(duration: self.halfModalStyle.bounceDuration))
            case .bottom:
                updatePosition(modalPosition: .middle, animationType: .bounce(duration: self.halfModalStyle.bounceDuration))
            }
        case .down:
            switch currentModalPosition {
            case .top:
                updatePosition(modalPosition: .middle, animationType: .bounce(duration: self.halfModalStyle.bounceDuration))
            case .middle:
                updatePosition(modalPosition: .bottom, animationType: .bounce(duration: self.halfModalStyle.bounceDuration))
            case .bottom:
                break
            }
        default:
            break
        }
    }
    
    private func startDragging() {
        viewPositionY = containerView?.frame.origin.y ?? 0.0
        startPositionY = viewPositionY
    }
    
    private func updateOffset(_ offset: CGFloat) {
        let addOffset: CGFloat = offset
        viewPositionY += addOffset
        updateContainerOriginY(max(halfModalStyle.topOffsetY, viewPositionY))
    }
    
    private func finishDragging(velocity: CGPoint) {
        guard let containerView = containerView else {
            return
        }
        
        let baseDiff = (containerView.frame.height - (halfModalStyle.topOffsetY - halfModalStyle.bottomOffsetY)) / 4
        
        let originY = containerView.frame.origin.y
        let diff = originY - startPositionY
        // 変化量が少ない場合は元のポジションに戻す
        if abs(diff) >= baseDiff {
            // 前のpostionをもとに一番近いpositoionへ移動させる
            switch currentModalPosition {
            case .top:
                let middleDiff = containerView.bounds.height / 2 - originY
                let bottomDiff = (containerView.bounds.maxY - self.halfModalStyle.bottomOffsetY) - originY
                if abs(middleDiff) < abs(bottomDiff) {
                    self.updatePosition(modalPosition: .middle, animationType: .bounce(duration: halfModalStyle.bounceDuration))
                } else {
                    self.updatePosition(modalPosition: .bottom, animationType: .bounce(duration: halfModalStyle.bounceDuration))
                }
            case .middle:
                if diff > 0 {
                    self.updatePosition(modalPosition: .bottom, animationType: .bounce(duration: halfModalStyle.bounceDuration))
                } else {
                    self.updatePosition(modalPosition: .top, animationType: .bounce(duration: halfModalStyle.bounceDuration))
                }
            case .bottom:
                let topDiff = self.halfModalStyle.topOffsetY - originY
                let middleDiff = containerView.bounds.height / 2 - originY
                if abs(topDiff) < abs(middleDiff) {
                    self.updatePosition(modalPosition: .top, animationType: .bounce(duration: halfModalStyle.bounceDuration))
                } else {
                    self.updatePosition(modalPosition: .middle, animationType: .bounce(duration: halfModalStyle.bounceDuration))
                }
            }
        } else {
            self.updatePosition(modalPosition: self.currentModalPosition, animationType: .bounce(duration: halfModalStyle.bounceDuration))
        }
        
        viewPositionY = 0.0
    }
    
    private var scrollObserver: NSKeyValueObservation?
    deinit {
        scrollObserver?.invalidate()
    }
}

extension HalfModalPresentationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == targetScrollView
    }
}

public class HalfModalTransitioningDelegate: NSObject {
    public init(style: HalfModalStyle) {
        self.style = style
    }
    
    public static var `default`: HalfModalTransitioningDelegate = {
        return HalfModalTransitioningDelegate(style: .default)
    }()
    public var style: HalfModalStyle
}

extension HalfModalTransitioningDelegate: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented,
                                               presenting: presenting,
                                               style: style)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(presentationDuration: style.presentationDuration)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator(dismissDuration: style.dismissDuration)
    }
}


final class PresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    internal init(presentationDuration: TimeInterval = 0.4) {
        self.presentationDuration = presentationDuration
    }
    
    var presentationDuration: TimeInterval = 0.4

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presentationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        
        containerView.addSubview(toViewController.view)
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.frame.size.height = containerView.bounds.size.height
        toViewController.view.center.y += containerView.bounds.size.height
        
        let animationDuration = transitionDuration(using: transitionContext)
        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: .linear) {
            toViewController.view.center.y -= containerView.bounds.size.height
        }
        
        animator.addCompletion { (finished) in
            transitionContext.completeTransition(finished == .end)
        }
        
        animator.startAnimation()
    }
}

final class DismissAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    internal init(dismissDuration: TimeInterval = 0.4) {
        self.dismissDuration = dismissDuration
    }
    
    var dismissDuration: TimeInterval = 0.4
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: .linear) {
            fromViewController.view.center.y += containerView.bounds.size.height
        }
        
        animator.addCompletion { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            let fromVC = transitionContext.viewController(forKey: .from)
            fromVC?.view?.removeFromSuperview()
        }
        
        animator.startAnimation()
    }
}
#endif
