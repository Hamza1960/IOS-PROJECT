//
//  EnergyBarChartView.swift
//  MindTrack
//
//  Created by Hamza Patel on 3/12/26.
//
//  Custom Quartz 2D bar chart for energy level data.
//  Draws filled bars with gradient coloring and labels.
//

import UIKit

class EnergyBarChartView: UIView {
    
    var dataPoints: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }
    
    var labels: [String] = []
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let padding: CGFloat = 30
        let chartRect = CGRect(
            x: padding,
            y: padding,
            width: rect.width - padding * 2,
            height: rect.height - padding * 2
        )
        
        if dataPoints.isEmpty {
            drawPlaceholder(context: context, rect: rect)
            return
        }
        
        let maxVal: CGFloat = 10.0
        let barCount = dataPoints.count
        let totalSpacing = CGFloat(barCount + 1) * 8
        let barWidth = (chartRect.width - totalSpacing) / CGFloat(barCount)
        
        // Draw horizontal grid lines
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(0.5)
        for i in 0...10 {
            let y = chartRect.maxY - (CGFloat(i) / maxVal) * chartRect.height
            context.move(to: CGPoint(x: chartRect.minX, y: y))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: y))
        }
        context.strokePath()
        
        // Draw bars
        for (i, value) in dataPoints.enumerated() {
            let x = chartRect.minX + 8 + CGFloat(i) * (barWidth + 8)
            let barHeight = (value / maxVal) * chartRect.height
            let y = chartRect.maxY - barHeight
            
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            
            // Bar gradient color based on energy level
            let color = energyColor(for: value)
            
            // Draw rounded bar
            let barPath = UIBezierPath(roundedRect: barRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4, height: 4))
            context.addPath(barPath.cgPath)
            context.setFillColor(color.cgColor)
            context.fillPath()
            
            // Draw value label on top
            let valueText = "\(Int(value))"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            let size = valueText.size(withAttributes: attrs)
            valueText.draw(at: CGPoint(x: x + barWidth / 2 - size.width / 2, y: y - 15), withAttributes: attrs)
            
            // Draw date label below
            if i < labels.count {
                let labelAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 8, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let labelSize = labels[i].size(withAttributes: labelAttrs)
                labels[i].draw(at: CGPoint(x: x + barWidth / 2 - labelSize.width / 2, y: chartRect.maxY + 5), withAttributes: labelAttrs)
            }
        }
    }
    
    private func energyColor(for value: CGFloat) -> UIColor {
        if value >= 8 {
            return UIColor(red: 0.42, green: 0.81, blue: 0.50, alpha: 0.9)
        } else if value >= 5 {
            return UIColor(red: 0.40, green: 0.49, blue: 0.92, alpha: 0.9)
        } else if value >= 3 {
            return UIColor(red: 1.00, green: 0.85, blue: 0.24, alpha: 0.9)
        } else {
            return UIColor(red: 1.00, green: 0.42, blue: 0.42, alpha: 0.9)
        }
    }
    
    private func drawPlaceholder(context: CGContext, rect: CGRect) {
        let text = "Log entries to see energy levels ⚡"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let size = text.size(withAttributes: attrs)
        text.draw(at: CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2), withAttributes: attrs)
    }
}
