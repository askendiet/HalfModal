import Foundation
import UIKit

public struct HalfModalStyle {
    public init(size: HalfModalPresentationController.Size, defaultPosition: HalfModalPresentationController.ModalPosition, topOffsetY: CGFloat, bottomOffsetY: CGFloat, bounceDuration: TimeInterval, presentationDuration: TimeInterval = 0.4, dismissDuration: TimeInterval = 0.4) {
        self.size = size
        self.defaultPosition = defaultPosition
        self.topOffsetY = topOffsetY
        self.bottomOffsetY = bottomOffsetY
        self.bounceDuration = bounceDuration
        self.presentationDuration = presentationDuration
        self.dismissDuration = dismissDuration
    }
    
    public func recreate(size: HalfModalPresentationController.Size? = nil,
                         defaultPosition: HalfModalPresentationController.ModalPosition? = nil,
                         topOffsetY: CGFloat? = nil,
                         bottomOffsetY: CGFloat? = nil,
                         bounceDuration: TimeInterval? = nil,
                         presentationDuration: TimeInterval? = nil,
                         dismissDuration: TimeInterval? = nil) -> HalfModalStyle {
        return HalfModalStyle(size: size ?? self.size,
                              defaultPosition: defaultPosition ?? self.defaultPosition,
                              topOffsetY: topOffsetY ?? self.topOffsetY,
                              bottomOffsetY: bottomOffsetY ?? self.bottomOffsetY,
                              bounceDuration: bounceDuration ?? self.bounceDuration)
    }
    
    public static var `default`: HalfModalStyle {
        return .init(size: .half,
                     defaultPosition: .bottom,
                     topOffsetY: 0.0,
                     bottomOffsetY: 0.0,
                     bounceDuration: 0.5)
    }
    
    public var size: HalfModalPresentationController.Size
    public var defaultPosition: HalfModalPresentationController.ModalPosition
    public var topOffsetY: CGFloat
    public var bottomOffsetY: CGFloat
    public var bounceDuration: TimeInterval
    public var presentationDuration: TimeInterval
    public var dismissDuration: TimeInterval
}
