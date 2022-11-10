//
//  GraphUIKitView.swift
//  one-percent-better-swiftui
//
//  Created by Jeremy Cook on 6/14/22.
//

import UIKit

protocol UpdateGraphValueDelegate {
    func update(to value: String)
}

class GraphUIKitView: UIView, UIGestureRecognizerDelegate {
    
    var graphData: GraphData!
    typealias Range = (min: Double, max: Double)
    var delegate: UpdateGraphValueDelegate!
    
    /// Where the user is touching on the graph
    var touchPoint: CGPoint!
    
    /// A boolean indicating whether the user is touching the graph (not panning)
    private var touchingGraph = false
    
    /// Pan gesture recognizer for graph
    private var panGesture: UIPanGestureRecognizer!
    
    /// A boolean indicating whether the user is panning the graph (not touching)
    private var panningGraph = false
    
    /// Which direction the user began the pan. True if panning up or down, then scroll the table
    /// False if panning left or right, then show the values of the graph
    private var isPanningUpOrDown: Bool?
    
    /// The previous touched point on the graph. Used to create haptic feedback when moving to a new point
    private var previousTouchedPoint: CGPoint?
    
    /// A boolean indicating if the screen is being panned, so that touchesBegan doesn't override the pan
    private var panningRecognized = false
    
    // MARK: Graph properties
    
    private let yOffset: (top: CGFloat, bottom: CGFloat) = (25, 25)
    private let xOffset: (left: CGFloat, right: CGFloat) = (10, 50)
    private var graphSize: CGSize {
        get {
            CGSize(width: frame.width - xOffset.left - xOffset.right,
                   height: frame.height - yOffset.top - yOffset.bottom)
        }
    }
    
    var pointSize: CGFloat {
        get {
            // TODO: make minDays and maxDays depend on custom graph range
            let minDays: CGFloat = 0
            let maxDays: CGFloat = 365
            let maxSize: CGFloat = 7
            let minSize: CGFloat = 0
            // a linear interpolation between (minDays, maxSize) and (maxDays, minSize)
            let size = maxSize + (CGFloat(graphData.numDays) - minDays) * (minSize - maxSize) / (maxDays - minDays)
            return max(size, 0)
        }
    }
    var useDots: Bool = true
    var graphColor: UIColor = .systemBlue
    var roundValue: Bool = false
    
    // MARK: - Configure
    
    func configure(graphData: GraphData) {
        self.graphData = graphData
        if let _ = graphData.graphTracker as? ImprovementTracker {
            self.useDots = false
            self.graphColor = .systemGreen
            self.roundValue = false
        }
        self.setNeedsDisplay()
    }
    
    func updateRange(endDate: Date, numDaysBefore: Int) {
        graphData.updateRange(endDate: endDate, numDaysBefore: numDaysBefore)
        self.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panScreen(touch:)))
        self.addGestureRecognizer(panGesture)
        panGesture.delegate = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panScreen(touch:)))
        self.addGestureRecognizer(panGesture)
        panGesture.delegate = self
    }
    
    // MARK: Pan and Touch Gesture Recognizers
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesture {
            panningRecognized = true
            // If panning left or right, then only recognize this panning gesture
            if let isPanningUpOrDown = isPanningUpOrDown {
                if !isPanningUpOrDown {
                    return false
                }
            } else if !isPanningUpOrDown(velocity: panGesture.velocity(in: self)) {
                return false
            }
            // If already touching graph, or already panning graph,
            // then only recognize this panning gesture
            if touchingGraph || panningGraph {
                return false
            }
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingGraph = true
        touchPoint = touches[touches.startIndex].location(in: self)
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingGraph = false
        panningRecognized = false
        if !panningGraph {
            touchPoint = nil
            delegate.update(to: "")
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingGraph = false
        if !panningGraph {
            touchPoint = nil
            delegate.update(to: "")
            setNeedsDisplay()
        }
    }
    
    @objc func panScreen(touch: UIPanGestureRecognizer) {
        if touch.state == .began {
            if !touchingGraph {
                isPanningUpOrDown = isPanningUpOrDown(velocity: touch.velocity(in: self))
                panningGraph = !isPanningUpOrDown!
            } else {
                panningGraph = true
            }
        }
        
        if touch.state == .ended || touch.state == .cancelled {
            panningGraph = false
            isPanningUpOrDown = nil
            panningRecognized = false
            if !touchingGraph {
                touchPoint = nil
                delegate.update(to: "")
                setNeedsDisplay()
            }
        } else if touchingGraph || panningGraph {
            touchPoint = touch.location(in: self)
            setNeedsDisplay()
        }
    }
    
    func isPanningUpOrDown(velocity: CGPoint) -> Bool {
        if abs(velocity.x) > abs(velocity.y) {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Draw
    
    override func draw(_ rect: CGRect) {
//        print("draw getting called!!!")
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        
        guard !(graphData.dates.isEmpty || graphData.values.isEmpty) else {
            return
        }
        
        let yRange = calculateYRange(yArray: graphData.values)
        
        drawXLabels(context: context)
        drawYLabels(context: context, range: yRange)
        //debugGraphBorders(context: context)
        
        context.setFillColor(graphColor.cgColor)
        
        // check if there's data before this range
        if graphData.beforeDate != nil {
            // draw line out front corresponding to previous data point slope
            drawPreviousLine(range: yRange)
        } else if !Cal.isDate(graphData.dates[0], inSameDayAs: graphData.startDate) {
            // draw gray line out front
            drawGrayBeginning(x: graphData.dates[0], y: graphData.values[0], range: yRange)
        }
        
        let graphLine = UIBezierPath()
        graphLine.lineWidth = 2
        graphLine.lineCapStyle = .square
        
        var firstPoint = true
        
        var graphPoints: [CGPoint] = []
        
        for (j, day) in graphData.dates.enumerated() {
            
            let xPos = getGraphX(x: day)
            let yPos = getGraphY(y: graphData.values[j], range: yRange)
            
            let graphPoint = CGPoint(x: xPos, y: yPos)
            graphPoints.append(graphPoint)
            
            if firstPoint {
                graphLine.move(to: graphPoint)
                firstPoint = false
            } else {
                graphLine.addLine(to: graphPoint)
            }
            
            if useDots {
                // circle dot
                let circleRect = CGRect(x: graphPoint.x - (pointSize / 2), y: graphPoint.y - (pointSize / 2), width: pointSize, height: pointSize)
                graphColor.setFill()
                context.addEllipse(in: circleRect)
                context.drawPath(using: .fillStroke)
            }
        }
        
        // draw the graph line
        graphColor.setStroke()
        graphLine.stroke()
        
        if touchPoint != nil {
            drawVerticalLine(context: context, graphPoints: graphPoints, xArr: graphData.dates, yArr: graphData.values, range: yRange)
        }
    }
    
    // MARK: - Calculate Y Range
    
    private func calculateYRange(yArray: [Double]) -> Range {
        var yRange: Range = (yArray.min()!, yArray.max()!)
        
        // in case range is a single value
        if yRange.min == yRange.max {
            yRange.min -= 2
            yRange.max += 2
        }
        
        // update range so that previous line extends backwards, and not up or down
        if let y0 = graphData.beforeValue {
            if y0 < yRange.min {
                yRange.min = y0
            } else if y0 > yRange.max {
                yRange.max = y0
            }
        }
        
        return yRange
    }
    
    // MARK: - Draw Y Labels
    
    private func drawYLabels(context: CGContext, range: Range) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrs: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 12.0, weight: .regular),
            .foregroundColor: UIColor.systemGray
        ]
        
        let numLabels = 4
        for i in 0 ..< numLabels {
            let labelValue = range.max - Double(i) * (range.max - range.min) / Double(numLabels - 1)
            
            var labelString = String(format:"%.0f", labelValue)
            if (range.max - range.min) < 2 || labelValue.hasDecimals() {
                labelString = String(format:"%.1f", labelValue)
            }
            
            let attrString = NSAttributedString(string: labelString, attributes: attrs)
            let textHeight: CGFloat = 15
            let labelY = yOffset.top + CGFloat(i) * (graphSize.height / CGFloat(numLabels - 1))
            let stringRect = CGRect(x: xOffset.left + graphSize.width,
                                    y: labelY - textHeight/2,
                                    width: xOffset.right,
                                    height: textHeight)
            //context.addRect(stringRect)
            //context.drawPath(using: .stroke)
            attrString.draw(in: stringRect)
            
            // line
            let line = UIBezierPath()
            line.lineWidth = 1.0
            line.move(to: CGPoint(x: xOffset.left + graphSize.width, y: labelY))
            line.addLine(to: CGPoint(x: xOffset.left, y: labelY))
            UIColor.systemGray.withAlphaComponent(0.25).setStroke()
            line.stroke()
        }
    }
    
    // MARK: - Draw X Labels
    
    private func drawXLabels(context: CGContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attrs: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 12.0, weight: .regular),
            .foregroundColor: UIColor.systemGray
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let textSize = CGSize(width: 30, height: 15)
        
        
        // start
        var dateLabel = graphData.startDate.monthAndDay()
//        var dateLabel = dateFormatter.string(from: graphData.startDate)
        var attrString = NSAttributedString(string: dateLabel, attributes: attrs)
        var stringRect = CGRect(x: xOffset.left,
                                y: frame.height - textSize.height,
                                width: textSize.width,
                                height: textSize.height)
        attrString.draw(in: stringRect)
        
        // end
        // adjust bc end date is the start of next day
        let end = Cal.date(byAdding: .day, value: -1, to: graphData.endDate)!
        dateLabel = end.monthAndDay()
        attrString = NSAttributedString(string: dateLabel, attributes: attrs)
        stringRect = CGRect(x: frame.width - xOffset.right - textSize.width,
                            y: frame.height - textSize.height,
                            width: textSize.width,
                            height: textSize.height)
        attrString.draw(in: stringRect)
        
        // middle
        let middleDate = Cal.date(byAdding: .day, value: graphData.numDays / 2, to: graphData.startDate)!
        dateLabel = middleDate.monthAndDay()
        attrString = NSAttributedString(string: dateLabel, attributes: attrs)
        stringRect = CGRect(x: xOffset.left + graphSize.width / 2 - textSize.width / 2,
                            y: frame.height - textSize.height,
                            width: textSize.width,
                            height: textSize.height)
        attrString.draw(in: stringRect)
    }
    
    // MARK: - Get Graph X and Y
    
    func getGraphX(x day: Date) -> CGFloat {
        let i = Cal.numberOfDaysBetween(graphData.startDate, and: day) - 1
        let widthRatio = CGFloat(i) / CGFloat(graphData.numDays - 1)
        let x = xOffset.left + graphSize.width * widthRatio
        return x
    }
    
    func getGraphY(y yVal: Double, range: Range) -> CGFloat {
        let heightRatio = CGFloat(yVal - range.min) / CGFloat(range.max - range.min)
        let y = yOffset.top + graphSize.height * (1 - heightRatio)
        return y
    }
    
    // MARK: - Draw Vertical Line
    
    func drawVerticalLine(context: CGContext, graphPoints: [CGPoint], xArr: [Date], yArr: [Double], range: Range) {
        var closestPoint: CGPoint!
        var closestDist: CGFloat!
        var closestIndex: Int!
        
        for (i, point) in graphPoints.enumerated() {
            let dist = abs(touchPoint.x - point.x)
            if closestPoint == nil || dist < closestDist {
                closestPoint = point
                closestDist = dist
                closestIndex = i
            }
        }
        
        // TODO: Enable haptic engine manager again
        if previousTouchedPoint != closestPoint {
            HapticEngineManager.playHaptic(intensity: 0.5)
        }
        previousTouchedPoint = closestPoint
        
        // vertical line
        let vertLine = UIBezierPath()
        vertLine.lineWidth = 1
        //let gx = getGraphX(x: xArr[closestIndex])
        let top = CGPoint(x: closestPoint.x, y: yOffset.top)
        let bottom = CGPoint(x: closestPoint.x, y: frame.height - yOffset.bottom)
        vertLine.move(to: bottom)
        vertLine.addLine(to: top)
        UIColor.systemGray.setStroke()
        vertLine.stroke()
        
        // circle dot
        let circleRect = CGRect(x: closestPoint.x - (pointSize / 2), y: closestPoint.y - (pointSize / 2), width: pointSize, height: pointSize)
        graphColor.setFill()
        context.addEllipse(in: circleRect)
        context.drawPath(using: .fillStroke)
        
        // date
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
            .foregroundColor: UIColor.label
        ]
        let date = xArr[closestIndex]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let dateLabel = dateFormatter.string(from: date)
        let attrString = NSAttributedString(string: dateLabel, attributes: attrs)
        let textSize: CGSize = .init(width: 60, height: 20)
        var x = closestPoint.x - textSize.width / 2
        if x < xOffset.left {
            x = xOffset.left
        } else if x > (frame.width - xOffset.right - textSize.width) {
            x = frame.width - xOffset.right - textSize.width
        }
        let stringRect = CGRect(x: x,
                                y: 0,
                                width: textSize.width,
                                height: textSize.height)
        //UIColor.systemGray.setStroke()
        //context.addRect(stringRect)
        //context.drawPath(using: .stroke)
        attrString.draw(in: stringRect)
        
        // value in top right corner
        var value = graphData.graphTracker.getValue(date: xArr[closestIndex])!
//        var value = String(format:"%.0f", yArr[closestIndex])
//        if yArr[closestIndex].hasDecimals() {
//            value = String(format:"%.1f", yArr[closestIndex])
//        }
        if roundValue,
           let doubleVal = Double(value) {
            // round to 3 digits
            let rounded = round(doubleVal * 1000) / 1000
            value = String(rounded)
        }
        delegate.update(to: value)
    }
    
    // MARK: - Previous Data Line
    
    func drawPreviousLine(range: Range) {
        guard let x0 = graphData.beforeDate,
              let y0 = graphData.beforeValue else {
                  return
              }
        let x1 = graphData.dates[0]
        let y1 = graphData.values[0]
        
        let i = Cal.numberOfDaysBetween(x0, and: x1) - 1
        let widthRatio = CGFloat(i) / CGFloat(graphData.numDays - 1)
        let gx0 = xOffset.left - widthRatio * graphSize.width
        let gy0 = getGraphY(y: y0, range: range)
        let gx1 = getGraphX(x: x1)
        let gy1 = getGraphY(y: y1, range: range)
        
        let graphLine = UIBezierPath()
        graphLine.lineWidth = 2
        graphLine.move(to: CGPoint(x: gx0, y: gy0))
        graphLine.addLine(to: CGPoint(x: gx1, y: gy1))
        graphColor.setStroke()
        graphLine.stroke()
    }
    
    // MARK: - Gray Line at Beginning
    
    // the gray line which gets drawn at the beginning if there is no previous data
    func drawGrayBeginning(x: Date, y: Double, range: Range) {
        // Draw the gray line out front
        let grayLine = UIBezierPath()
        grayLine.lineWidth = 2
        
        let xPos = getGraphX(x: x)
        let yPos = getGraphY(y: y, range: range)
        
        let startPoint = CGPoint(x: 0, y: yPos)
        grayLine.move(to: startPoint)
        grayLine.addLine(to: CGPoint(x: xPos, y: yPos))
        let  dashes: [ CGFloat ] = [ 0.0, 5.0 ]
        grayLine.setLineDash(dashes, count: dashes.count, phase: 0.0)
        grayLine.lineCapStyle = .round
        UIColor.systemGray.setStroke()
        grayLine.stroke()
    }
    
    // MARK: - Debug Graph Borders
    
    func debugGraphBorders(context: CGContext) {
        UIColor.systemGray.setStroke()
        let inner = CGRect(x: xOffset.left,
                           y: yOffset.top,
                           width: graphSize.width,
                           height: graphSize.height)
        context.addRect(inner)
        let outer = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        context.addRect(outer)
        context.drawPath(using: .stroke)
    }
}

