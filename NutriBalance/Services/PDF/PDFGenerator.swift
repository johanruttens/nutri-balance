import Foundation
import PDFKit
import UIKit

/// Service for generating PDF reports.
final class PDFGenerator {

    // MARK: - Constants

    private let pageWidth: CGFloat = 612 // US Letter width in points
    private let pageHeight: CGFloat = 792 // US Letter height in points
    private let margin: CGFloat = 50
    private let lineHeight: CGFloat = 20

    // MARK: - Colors

    private var primaryColor: UIColor { UIColor(ColorPalette.primary) }
    private var textColor: UIColor { UIColor(ColorPalette.textPrimary) }
    private var secondaryTextColor: UIColor { UIColor(ColorPalette.textSecondary) }

    // MARK: - Generate Report

    func generateReport(from data: PDFReportData) throws -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let pdfData = renderer.pdfData { context in
            drawReport(context: context, data: data, pageRect: pageRect)
        }

        return pdfData
    }

    // MARK: - Drawing

    private func drawReport(
        context: UIGraphicsPDFRendererContext,
        data: PDFReportData,
        pageRect: CGRect
    ) {
        var currentY: CGFloat = 0
        let contentWidth = pageWidth - (margin * 2)

        // Start first page
        context.beginPage()
        currentY = margin

        // Draw header
        currentY = drawHeader(at: currentY, data: data, contentWidth: contentWidth)

        // Draw summary section
        currentY = drawSummarySection(at: currentY, data: data, contentWidth: contentWidth)

        // Draw daily entries
        let sortedDates = data.entriesByDate.keys.sorted()
        for date in sortedDates {
            guard let entries = data.entriesByDate[date] else { continue }

            // Check if we need a new page
            if currentY > pageHeight - 150 {
                context.beginPage()
                currentY = margin
            }

            currentY = drawDaySection(at: currentY, date: date, entries: entries, contentWidth: contentWidth, context: context)
        }

        // Draw footer on last page
        drawFooter(pageRect: pageRect)
    }

    private func drawHeader(at y: CGFloat, data: PDFReportData, contentWidth: CGFloat) -> CGFloat {
        var currentY = y

        // App name
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: primaryColor
        ]
        let title = "NutriBalance"
        title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttributes)
        currentY += 35

        // Report title
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: textColor
        ]
        let subtitle = L("pdf.nutritionReport")
        subtitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttributes)
        currentY += 30

        // User name and date range
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: secondaryTextColor
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage.rawValue)

        let userLine = "\(L("pdf.preparedFor")): \(data.user.displayName)"
        userLine.draw(at: CGPoint(x: margin, y: currentY), withAttributes: detailAttributes)
        currentY += lineHeight

        let dateLine = "\(L("pdf.period")): \(dateFormatter.string(from: data.startDate)) - \(dateFormatter.string(from: data.endDate))"
        dateLine.draw(at: CGPoint(x: margin, y: currentY), withAttributes: detailAttributes)
        currentY += lineHeight

        let generatedLine = "\(L("pdf.generated")): \(dateFormatter.string(from: Date()))"
        generatedLine.draw(at: CGPoint(x: margin, y: currentY), withAttributes: detailAttributes)
        currentY += 30

        // Divider
        let dividerPath = UIBezierPath()
        dividerPath.move(to: CGPoint(x: margin, y: currentY))
        dividerPath.addLine(to: CGPoint(x: margin + contentWidth, y: currentY))
        UIColor.lightGray.setStroke()
        dividerPath.lineWidth = 1
        dividerPath.stroke()
        currentY += 20

        return currentY
    }

    private func drawSummarySection(at y: CGFloat, data: PDFReportData, contentWidth: CGFloat) -> CGFloat {
        var currentY = y

        let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: textColor
        ]
        L("pdf.summary").draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionTitleAttributes)
        currentY += 25

        let bodyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: textColor
        ]

        let summaryLines = [
            "\(L("pdf.totalCalories")): \(data.totalCalories) kcal",
            "\(L("pdf.totalProtein")): \(String(format: "%.1f", data.totalProtein))g",
            "\(L("pdf.totalCarbs")): \(String(format: "%.1f", data.totalCarbs))g",
            "\(L("pdf.totalFat")): \(String(format: "%.1f", data.totalFat))g",
            "\(L("pdf.totalWater")): \(String(format: "%.0f", data.totalWaterIntake))ml"
        ]

        for line in summaryLines {
            line.draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: bodyAttributes)
            currentY += lineHeight
        }

        currentY += 20
        return currentY
    }

    private func drawDaySection(
        at y: CGFloat,
        date: Date,
        entries: [FoodEntry],
        contentWidth: CGFloat,
        context: UIGraphicsPDFRendererContext
    ) -> CGFloat {
        var currentY = y

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage.rawValue)

        let dateTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: primaryColor
        ]
        dateFormatter.string(from: date).draw(at: CGPoint(x: margin, y: currentY), withAttributes: dateTitleAttributes)
        currentY += 25

        // Group by meal category
        let groupedEntries = Dictionary(grouping: entries) { $0.mealCategory }

        for category in MealCategory.orderedForDisplay {
            guard let mealEntries = groupedEntries[category], !mealEntries.isEmpty else { continue }

            // Check if we need a new page
            if currentY > pageHeight - 100 {
                context.beginPage()
                currentY = margin
            }

            let mealAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: textColor
            ]
            category.displayName.draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: mealAttributes)
            currentY += 18

            let entryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: secondaryTextColor
            ]

            for entry in mealEntries {
                let caloriesText = entry.calories.map { "\($0) kcal" } ?? "-"
                let line = "• \(entry.foodName) - \(entry.portionString) (\(caloriesText))"
                line.draw(at: CGPoint(x: margin + 20, y: currentY), withAttributes: entryAttributes)
                currentY += 16
            }

            currentY += 5
        }

        currentY += 15
        return currentY
    }

    private func drawFooter(pageRect: CGRect) {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]

        let footerText = L("pdf.footer")
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerX = (pageWidth - footerSize.width) / 2
        let footerY = pageHeight - margin + 10

        footerText.draw(at: CGPoint(x: footerX, y: footerY), withAttributes: footerAttributes)
    }
}
