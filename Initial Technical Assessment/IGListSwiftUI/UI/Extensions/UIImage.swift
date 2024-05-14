import UIKit

extension UIImage {
    public func averageColor() -> UIColor {
        let brightnessFactor: CGFloat = 2
        guard let cgImage = cgImage else {
            return UIColor.white
        }

        let width = 40
        let height = 40
        let totalPixels = width * height

        // Calculate average color with brightness adjustment for dark colors
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: 4 * totalPixels)
        let bytesPerRow = 4 * width

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let bitmapContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return UIColor.white }

        bitmapContext.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0

        for y in 0..<height {
            for x in 0..<width {
                let offset = 4 * (y * width + x)
                let red = CGFloat(rawData[offset]) / 255.0
                let green = CGFloat(rawData[offset + 1]) / 255.0
                let blue = CGFloat(rawData[offset + 2]) / 255.0

                totalRed += red
                totalGreen += green
                totalBlue += blue
            }
        }

        let averageRed = totalRed / CGFloat(totalPixels)
        let averageGreen = totalGreen / CGFloat(totalPixels)
        let averageBlue = totalBlue / CGFloat(totalPixels)

        var adjustedRed = averageRed
        var adjustedGreen = averageGreen
        var adjustedBlue = averageBlue

        // Check if the average color is dark and apply brightness adjustment
        let thresholdForDarkColor: CGFloat = 0.9
        if averageRed < thresholdForDarkColor && averageGreen < thresholdForDarkColor && averageBlue < thresholdForDarkColor {
            adjustedRed = min(1.0, averageRed * brightnessFactor)
            adjustedGreen = min(1.0, averageGreen * brightnessFactor)
            adjustedBlue = min(1.0, averageBlue * brightnessFactor)
        }

        rawData.deallocate()
        return UIColor(red: adjustedRed, green: adjustedGreen, blue: adjustedBlue, alpha: 1.0)
    }
}
