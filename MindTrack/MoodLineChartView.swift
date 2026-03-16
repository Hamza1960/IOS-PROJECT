//
//  MoodLineChartView.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Custom Quartz 2D line chart for mood data.
//  Draws axes, grid lines, data points, connecting lines, and gradient fill.
//

import UIKit

class MoodLineChartView: UIView {
    
    var dataPoints: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }
    
    var labels: [String] = []
    var zoomScale: CGFloat = 1.0
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let padding: CGFloat = 30
        let chartRect = CGRect(
            x: padding,
            y: padding,
            width: (rect.width - padding * 2) * zoomScale,
            height: rect.height - padding * 2
        )
        
        // Draw background grid
        drawGrid(context: context, rect: chartRect)
        
        if dataPoints.isEmpty {
            drawPlaceholder(context: context, rect: rect)
            return
        }
        
        let maxVal: CGFloat = 5.0
        let stepX = chartRect.width / CGFloat(max(dataPoints.count - 1, 1))
        
        // Draw gradient fill under the line
        context.saveGState()
        let path = CGMutablePath()
        
        for (i, point) in dataPoints.enumerated() {
            let x = chartRect.minX + CGFloat(i) * stepX
            let y = chartRect.maxY - (point / maxVal) * chartRect.height
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        // Close the path for fill
        let fillPath = path.mutableCopy()!
        fillPath.addLine(to: CGPoint(x: chartRect.minX + CGFloat(dataPoints.count - 1) * stepX, y: chartRect.maxY))
        fillPath.addLine(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        fillPath.closeSubpath()
        
        context.addPath(fillPath)
        context.clip()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 0.3).cgColor,
            UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 0.0).cgColor
        ] as CFArray
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
            context.drawLinearGradient(gradient,
                start: CGPoint(x: chartRect.midX, y: chartRect.minY),
                end: CGPoint(x: chartRect.midX, y: chartRect.maxY),
                options: [])
        }
        context.restoreGState()
        
        // Draw the line
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0).cgColor)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.addPath(path)
        context.strokePath()
        
        // Draw data points
        for (i, point) in dataPoints.enumerated() {
            let x = chartRect.minX + CGFloat(i) * stepX
            let y = chartRect.maxY - (point / maxVal) * chartRect.height
            
            // Dynamic fill circle
            context.setFillColor(UIColor.secondarySystemGroupedBackground.cgColor)
            context.fillEllipse(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
            
            // Colored border
            context.setStrokeColor(UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 1.0).cgColor)
            context.setLineWidth(2.5)
            context.strokeEllipse(in: CGRect(x: x - 6, y: y - 6, width: 12, height: 12))
            
            // Draw mood emoji above point
            let emoji = DataManager.shared.moodEmoji(for: Int16(point))
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
            let emojiSize = emoji.size(withAttributes: attrs)
            emoji.draw(at: CGPoint(x: x - emojiSize.width / 2, y: y - 22), withAttributes: attrs)
        }
        
        // Draw x-axis labels
        if labels.count == dataPoints.count {
            for (i, label) in labels.enumerated() {
                let x = chartRect.minX + CGFloat(i) * stepX
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let size = label.size(withAttributes: attrs)
                label.draw(at: CGPoint(x: x - size.width / 2, y: chartRect.maxY + 5), withAttributes: attrs)
            }
        }
    }
    
    private func drawGrid(context: CGContext, rect: CGRect) {
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(0.5)
        
        // Horizontal lines (5 mood levels)
        for i in 0...5 {
            let y = rect.maxY - (CGFloat(i) / 5.0) * rect.height
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        context.strokePath()
    }
    
    private func drawPlaceholder(context: CGContext, rect: CGRect) {
        let text = "Log entries to see your mood trends 📈"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let size = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2), withAttributes: attrs)
    }
}
