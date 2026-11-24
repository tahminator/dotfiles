import AppKit

let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

let variants: [(String, String, NSColor)] = [
    ("battery", "battery.100", .white),
    ("charging", "battery.100.bolt", NSColor(red: 0.49, green: 0.77, blue: 0.64, alpha: 1)),
    ("low", "battery.25", NSColor(red: 0.91, green: 0.51, blue: 0.49, alpha: 1)),
    ("volume", "speaker.wave.2.fill", .white),
    ("mute", "speaker.slash.fill", .white),
    ("wifi", "wifi", .white),
    ("wifi-off", "wifi.slash", .white),
]
let configuration = NSImage.SymbolConfiguration(pointSize: 10, weight: .medium)

for (name, symbolName, color) in variants {
    guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
        .withSymbolConfiguration(configuration) else {
        fatalError("Missing SF Symbol: \(symbolName)")
    }
    for percent in 0...100 {
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 56, pixelsHigh: 56,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
            let context = NSGraphicsContext(bitmapImageRep: bitmap) else { fatalError("Cannot create bitmap") }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.cgContext.scaleBy(x: 2, y: 2)
        context.cgContext.setAllowsAntialiasing(true)

        let track = NSBezierPath(ovalIn: NSRect(x: 2.5, y: 2.5, width: 23, height: 23))
        NSColor.white.withAlphaComponent(0.14).setStroke()
        track.lineWidth = 2
        track.stroke()

        if percent > 0 {
            let progress = NSBezierPath()
            progress.lineWidth = 2
            progress.lineCapStyle = .round
            progress.appendArc(withCenter: NSPoint(x: 14, y: 14), radius: 11.5,
                startAngle: 90, endAngle: 90 - CGFloat(percent) * 3.6, clockwise: true)
            color.withAlphaComponent(0.9).setStroke()
            progress.stroke()
        }

        let tinted = symbol.copy() as! NSImage
        tinted.lockFocus()
        color.set()
        NSRect(origin: .zero, size: tinted.size).fill(using: .sourceAtop)
        tinted.unlockFocus()
        tinted.draw(in: NSRect(x: 8, y: 8, width: 12, height: 12))
        NSGraphicsContext.restoreGraphicsState()

        guard let data = bitmap.representation(using: .png, properties: [:]) else { fatalError("Cannot encode PNG") }
        try data.write(to: directory.appendingPathComponent("\(name)-\(percent).png"), options: .atomic)
    }
}
