import UIKit

extension UIImage {

    func blurAndAverageColor(blurRadius: CGFloat) -> UIColor {
        let brightnessFactor: CGFloat = 2
        guard let ciImage = CIImage(image: self) else {
            return UIColor.white
        }

        // Apply blur filter
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(blurRadius, forKey: kCIInputRadiusKey)

        guard let blurredImage = blurFilter?.outputImage else {
            return UIColor.white
        }

        // Calculate average color with brightness adjustment for dark colors
        let extent = blurredImage.extent
        let context = CIContext(options: nil)
        let bitmap = context.createCGImage(blurredImage, from: extent)
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: 4 * Int(extent.width) * Int(extent.height))
        let bytesPerRow = 4 * Int(extent.width)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapContext = CGContext(data: rawData, width: Int(extent.width), height: Int(extent.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        bitmapContext?.draw(bitmap!, in: CGRect(origin: .zero, size: extent.size))

        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0

        for y in 0..<Int(extent.height) {
            for x in 0..<Int(extent.width) {
                let offset = 4 * (y * Int(extent.width) + x)
                let red = CGFloat(rawData[offset]) / 255.0
                let green = CGFloat(rawData[offset + 1]) / 255.0
                let blue = CGFloat(rawData[offset + 2]) / 255.0

                totalRed += red
                totalGreen += green
                totalBlue += blue
            }
        }

        let pixelCount = CGFloat(extent.width * extent.height)
        let averageRed = totalRed / pixelCount
        let averageGreen = totalGreen / pixelCount
        let averageBlue = totalBlue / pixelCount

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
