import AppKit

let input = "assets/original/celium-sprites.svg"
let output = "assets/original/celium-sprites.png"

guard let image = NSImage(contentsOfFile: input),
      let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: 192,
        pixelsHigh: 16,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
      ) else {
  fatalError("Unable to load or allocate sprite sheet")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSGraphicsContext.current?.imageInterpolation = .none
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: 192, height: 16).fill()
image.draw(in: NSRect(x: 0, y: 0, width: 192, height: 16), from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()

guard let data = bitmap.representation(using: .png, properties: [:]) else {
  fatalError("Unable to encode sprite sheet")
}
try data.write(to: URL(fileURLWithPath: output))
print("Rendered \(output)")
