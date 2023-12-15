import Chart
import SnapKit
import UIKit

class ViewController: UIViewController {
    static let maColors = [UIColor.green, UIColor.blue, UIColor.red]

    private var chartView = RateChartView(configuration: ChartConfiguration())
    private var chartData = ChartData(items: [], startWindow: 0, endWindow: 0)
    private var indicators: [ChartIndicator] = []

    private var showIndicators = true

    override func viewDidLoad() {
        super.viewDidLoad()

        let chartButton = UIButton()
        view.addSubview(chartButton)

        chartButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(50)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(30)
        }

        chartButton.setTitleColor(.black, for: .normal)
        chartButton.setTitle("Show Chart", for: .normal)
        chartButton.addTarget(self, action: #selector(generateChartData), for: .touchUpInside)

        view.addSubview(chartView)

        chartView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(200)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(300)
        }

        chartView.backgroundColor = .gray

        let generateButton = UIButton()
        view.addSubview(generateButton)

        generateButton.snp.makeConstraints { maker in
            maker.top.equalTo(chartView.snp.bottom).offset(40)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(30)
        }

        generateButton.setTitleColor(.black, for: .normal)
        generateButton.setTitle("Generate indicators", for: .normal)
        generateButton.addTarget(self, action: #selector(generateIndicators), for: .touchUpInside)

        let toggleButton = UIButton()
        view.addSubview(toggleButton)

        toggleButton.snp.makeConstraints { maker in
            maker.top.equalTo(generateButton.snp.bottom).offset(40)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(30)
        }

        toggleButton.setTitleColor(.black, for: .normal)
        toggleButton.setTitle("Toggle indicators", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleIndicators), for: .touchUpInside)
    }

    @objc func generateChartData() {
        let sevenDays = 7 * 24 * 60 * 60
        let pointCount = 120
        let minValue = 10
        let maxValue = 1000

        let powScale = pow(10, Int.random(in: 2 ... 6))

        var endInterval = Date().timeIntervalSince1970
        endInterval.round()

        let startInterval = endInterval - 2 * TimeInterval(sevenDays)
        let deltaInterval = TimeInterval(2 * sevenDays / pointCount)

        var items = [ChartItem]()
        for index in 0 ..< pointCount {
            let chartItem = ChartItem(timestamp: startInterval + TimeInterval(index) * deltaInterval)
            chartItem.added(name: ChartData.rate, value: randomValue(start: minValue, end: maxValue, powScale: powScale))
            chartItem.added(name: ChartData.volume, value: randomValue(start: minValue, end: maxValue, powScale: powScale))

            items.append(chartItem)
        }

        chartData = ChartData(items: items, startWindow: endInterval - TimeInterval(sevenDays), endWindow: endInterval)
        show()
    }

    private func show() {
        chartView.set(chartData: chartData, indicators: indicators, showIndicators: showIndicators, animated: true)
        chartView.setCurve(colorType: .neutral)
    }

    @objc func toggleIndicators() {
        showIndicators = !showIndicators
        show()
    }

    @objc func generateIndicators() {
        var indicators = [ChartIndicator]()

        // ma:
        for i in 0 ... Int.random(in: 0 ... 2) {
            indicators.append(MaIndicator(id: "ma", index: i, enabled: true, period: Int.random(in: 10 ... 25), type: Bool.random() ? .ema : .sma))
        }
        if Bool.random() {
            indicators.append(RsiIndicator(id: "rsi", index: 0, enabled: true, period: Int.random(in: 10 ... 25), onChart: false))
        } else {
            indicators.append(MacdIndicator(id: "macd", index: 0, enabled: true, fast: Int.random(in: 6 ... 10), slow: Int.random(in: 12 ... 16), signal: 24))
        }
        self.indicators = indicators
        show()
    }

    private func randomValue(start: Int, end: Int, powScale: Decimal) -> Decimal {
        let scale = (powScale as NSNumber).intValue
        let scaledStart = start * scale
        let scaledEnd = end * scale

        return Decimal(Int.random(in: scaledStart ... scaledEnd)) / powScale
    }
}
