import UIKit
import Chart
import SnapKit

class ViewController: UIViewController {
    private var chartView = RateChartView()

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
        chartButton.addTarget(self, action: #selector(showChart), for: .touchUpInside)

        let configuration = ChartConfiguration()
        chartView.apply(configuration: configuration)
        view.addSubview(chartView)

        chartView.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(200)
            maker.leading.trailing.equalToSuperview().inset(32)
        }

        chartView.backgroundColor = .gray
    }

    @objc func showChart() {
        let sevenDays = 7 * 24 * 60 * 60
        let pointCount = 100
        let minValue = 10
        let maxValue = 1000

        let powScale = pow(10, Int.random(in: 2...6))

        let endInterval = Date().timeIntervalSince1970
        let startInterval = endInterval - TimeInterval(sevenDays)
        let deltaInterval = TimeInterval(sevenDays / pointCount)

        var items = [ChartItem]()
        for index in 0..<pointCount {
            let chartItem = ChartItem(timestamp: startInterval + TimeInterval(index) * deltaInterval)
            chartItem.added(name: .rate, value: randomValue(start: minValue, end: maxValue, powScale: powScale))
            chartItem.added(name: .volume, value: randomValue(start: minValue, end: maxValue, powScale: powScale))

            items.append(chartItem)
        }

        let data = ChartData(items: items, startTimestamp: startInterval, endTimestamp: endInterval)
        chartView.set(chartData: data, animated: true)
    }
    
    private func randomValue(start: Int, end: Int, powScale: Decimal) -> Decimal {
        let scale = (powScale as NSNumber).intValue
        let scaledStart = start * scale
        let scaledEnd = end * scale

        return Decimal(Int.random(in: scaledStart...scaledEnd)) / powScale
    }

}
