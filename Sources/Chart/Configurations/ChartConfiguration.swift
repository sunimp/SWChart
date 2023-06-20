import UIKit

public class ChartConfiguration {
    static let onePixel = 1 / UIScreen.main.scale

    public var showBorders = true
    public var showIndicators = true
    public var showLimits = true
    public var showVerticalLines = true
    public var isInteractive = true

    public var mainHeight: CGFloat = 183
    public var indicatorHeight: CGFloat = 47
    public var timelineHeight: CGFloat = 21

    public var animationDuration: TimeInterval = 0.35

    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor = UIColor.clear.withAlphaComponent(0.5)

    public var backgroundColor: UIColor = .clear

    public var curveType: CurveType = .line
    public var curveWidth: CGFloat = 1
    public var curvePadding: UIEdgeInsets = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)
    public var curveBottomInset: CGFloat = 0

    public var trendUpColor = UIColor.green
    public var trendDownColor = UIColor.red
    public var pressedColor: UIColor = UIColor.white
    public var outdatedColor: UIColor = UIColor.white

    public var trendUpGradient = [UIColor.green, UIColor.green]
    public var trendDownGradient = [UIColor.red, UIColor.red]
    public var pressedGradient = [UIColor.lightGray, UIColor.lightGray]
    public var neutralGradient = [UIColor.gray, UIColor.gray]

    public var gradientPositions: [CGFloat] = [0, 1]
    public var gradientLocations: [NSNumber]? = nil
    public var gradientAlphas: [CGFloat] = [0.05, 0.5]

    public var limitLinesWidth: CGFloat = onePixel
    public var limitLinesDashPattern: [NSNumber]? = [2, 2]
    public var limitLinesColor: UIColor = UIColor.white.withAlphaComponent(0.5)
    public var limitLinesPadding: UIEdgeInsets = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)

    public var limitTextColor: UIColor = UIColor.white.withAlphaComponent(0.5)
    public var limitTextFont: UIFont = .systemFont(ofSize: 12)
    public var highLimitTextInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: -1, right: 32)
    public var highLimitTextSize: CGSize = CGSize(width: 0, height: 14)
    public var lowLimitTextInsets: UIEdgeInsets = UIEdgeInsets(top: -1, left: 16, bottom: 4, right: 32)
    public var lowLimitTextSize: CGSize = CGSize(width: 0, height: 14)

    public var verticalLinesWidth: CGFloat = onePixel
    public var verticalLinesColor: UIColor = UIColor.gray.withAlphaComponent(0.5)
    public var verticalInvisibleIndent: CGFloat? = 5

    public var volumeBarsFillColor: UIColor = .lightGray
    public var volumeBarsColor: UIColor = .clear
    public var volumeBarsWidth: CGFloat = 4
    public var volumeMinimalHeight: CGFloat = 2
    public var volumeBarsInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)

    public var timelineTextColor: UIColor = UIColor.white.withAlphaComponent(0.5)
    public var timelineFont: UIFont = .systemFont(ofSize: 12)
    public var timelineInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0)

    public var touchLineWidth: CGFloat = onePixel
    public var touchCircleRadius: CGFloat = 3.5
    public var touchLineColor: UIColor = UIColor.white
    public var touchCircleColor: UIColor = UIColor.white

    public var dominanceLineColor = UIColor.orange
    public var dominanceLineWidth: CGFloat = 1

    public var rsiPadding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    public var rsiTopLimitValue: CGFloat = 0.7
    public var rsiBottomLimitValue: CGFloat = 0.3

    public var rsiHighTextInsets: UIEdgeInsets = UIEdgeInsets(top: 4, left: -1, bottom: -1, right: 16)
    public var rsiLowTextInsets: UIEdgeInsets = UIEdgeInsets(top: -1, left: -1, bottom: 4, right: 16)

    public var rsiTextSize: CGSize = CGSize(width: 15, height: 14)

    public init() {
    }

    public enum CurveType {
        case line
        case bars
    }

}
