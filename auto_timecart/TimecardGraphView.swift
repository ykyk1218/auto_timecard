//
//  TimecardGraphView.swift
//  auto_timecard
//
//  Created by 小林芳樹 on 2016/01/10.
//  Copyright © 2016年 小林芳樹. All rights reserved.
//

import UIKit
import CorePlot

class TimecardGraphView: UIView, CPTPieChartDataSource, CPTPieChartDelegate {
    
    private let hostingView = CPTGraphHostingView()
    private let pieChart = CPTPieChart()
    private var pieChartData = NSMutableArray()
    private var pieChartViewData = NSMutableArray()
    private var chartTitle = ["通常勤務時間", "残業時間"]//, "深夜残業時間"]
    private let timecardModel = TimecardModel()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let baseY: CGFloat = 150.0
        
        //グラフに表示させるデータ
        //self.pieChartData = [100.0, 0.0]
        let email = defaults.objectForKey("email")
        
        self.timecardModel.worktime(["email":email!]) { (json)->() in
            
            self.pieChart.dataSource = self
            self.pieChart.delegate = self
            
            let worktimeSec = json["worktimeSec"]
            let overtimeSec = json["overtimeSec"]
            let worktime = json["worktime"]
            let overtime = json["overtime"]
            
            self.pieChartData = [worktimeSec.int!, overtimeSec.int!]
            self.pieChartViewData = [worktime.string!, overtime.string!]
            self.hostingView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 380)
            self.hostingView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, baseY+80)
            let graph = CPTXYGraph(frame:CGRectZero)
            graph.paddingTop = 0.0
            //graph.title = ""
            graph.axisSet = nil
            graph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top
            graph.plotAreaFrame?.paddingBottom = 0.0
            graph.plotAreaFrame?.paddingTop = 60.0
            
            //グラフの大きさ
            self.pieChart.pieRadius = 80
            
            
            graph.addPlot(self.pieChart)
            self.hostingView.hostedGraph = graph
            
            let theLegend = CPTLegend(graph: graph)
            theLegend.numberOfColumns = 1
            theLegend.fill = CPTFill(color: CPTColor.whiteColor())
            theLegend.borderLineStyle = CPTLineStyle()
            theLegend.borderWidth = 1
            theLegend.borderColor = UIColor.hex("efefef", alpha: 1).CGColor
            theLegend.cornerRadius = 3.0
            
            graph.legend = theLegend
            graph.legendAnchor = CPTRectAnchor.Right
            graph.legendDisplacement = CGPointMake(-10, 100)
            
            self.addSubview(self.hostingView)
            
            self.addAnimation(self.pieChart)
            

        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAnimation(plot:CPTPieChart) {
        let duration = CGFloat(1.5) // アニメーションの時間
        let curve = CPTAnimationCurve.ExponentialInOut // アニメーションカーブ
        CPTAnimation.animate(plot,
            property: "endAngle",
            from:CGFloat(M_PI / 2.0) + CGFloat(M_PI * 2.0),
            to: CGFloat(M_PI / 2.0),
            duration: duration,
            animationCurve: curve,
            delegate: nil)
    }
    
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(self.pieChartData.count)
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        return self.pieChartData.objectAtIndex(Int(idx))
    }
    

    func dataLabelForPlot(plot: CPTPlot, recordIndex idx: UInt) -> CPTLayer? {
        let lblChart = CPTTextLayer()
        
        let textStyle = CPTMutableTextStyle(style: CPTTextStyle.mutableCopy() as? CPTTextStyle)
        textStyle.color = CPTColor.whiteColor()
        lblChart.textStyle = textStyle
        lblChart.text = self.chartTitle[Int(idx)] + "\n" + String(self.pieChartViewData.objectAtIndex(Int(idx)))
        lblChart.position = CGPointMake(-50.0, 0)
        return lblChart
    }
    
    
    /*
    func radialOffsetForPieChart(pieChart: CPTPieChart, recordIndex idx: UInt) -> CGFloat {
        var offset:CGFloat = 0.0
        if (idx == 0) {
            offset = pieChart.pieRadius / 8.0
        }
        return offset
    }
    */
    
    
    func legendTitleForPieChart(pieChart: CPTPieChart, recordIndex idx: UInt) -> String? {
        //凡例に表示させるテキストの設定
        return self.chartTitle[Int(idx)]
        
    }
    
    func sliceFillForPieChart(pieChart: CPTPieChart, recordIndex idx: UInt) -> CPTFill? {
        //グラフの色を設定
        var areaGradientFill: CPTFill = CPTFill()
        
        if(idx == 0) {
            areaGradientFill = CPTFill(color: CPTColor(componentRed: 0.573, green: 1.0, blue: 0.88, alpha: 1.0))
        }else if(idx == 1) {
            areaGradientFill = CPTFill(color: CPTColor(componentRed: 0.8, green: 0.7, blue: 0.6, alpha: 1.0))
        }else if(idx == 2) {
            areaGradientFill = CPTFill(color: CPTColor(componentRed: 0.2, green: 0.2, blue: 0.8, alpha: 1.0))
        }
        return areaGradientFill
        
    }


}
