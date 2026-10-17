#!/usr/bin/env swift
// Measure rendered ink in 100-point template units using AppKit.
// Requires macOS. Run one bundle per process to avoid same-name resource conflicts.
// Example: swift measure-symbol.swift system camera --point-size 1600
// Example: swift measure-symbol.swift bundle Probe.bundle ExampleNewNote
// Render black glyphs on white; dark-pixel threshold is 128.
import AppKit


var arguments = Array(CommandLine.arguments.dropFirst())
var pointSize: CGFloat = 1600

if let index = arguments.firstIndex(of: "--point-size"), index + 1 < arguments.count {
    pointSize = CGFloat(Double(arguments[index + 1]) ?? 1600)
    arguments.removeSubrange(index...(index + 1))
}

guard arguments.count >= 2, let mode = arguments.first, mode == "system" || mode == "bundle" else {
    FileHandle.standardError.write(Data("""
    Usage:
      swift measure-symbol.swift system <symbol> [<symbol> ...] [--point-size 1600]
      swift measure-symbol.swift bundle <X.bundle> <asset> [<asset> ...] [--point-size 1600]

    """.utf8))
    exit(2)
}

let targets: [(label: String, image: NSImage)] = {
    switch mode {
    case "system":
        return arguments.dropFirst().compactMap { name in
            guard let image = NSImage(systemSymbolName: name, accessibilityDescription: nil) else {
                FileHandle.standardError.write(Data("System symbol not found: \(name)\n".utf8))
                return nil
            }
            return (name, image)
        }
    default:
        guard arguments.count >= 3, let bundle = Bundle(path: arguments[1]) else {
            FileHandle.standardError.write(Data("Cannot open bundle: \(arguments.count > 1 ? arguments[1] : "?")\n".utf8))
            exit(2)
        }
        return arguments.dropFirst(2).compactMap { name in
            guard let image = bundle.image(forResource: name) else {
                FileHandle.standardError.write(Data("Bundle resource not found: \(name)\n".utf8))
                return nil
            }
            return (name, image)
        }
    }
}()

guard !targets.isEmpty else { exit(1) }


let unitsPerPoint = 100 / pointSize
let capHeight: CGFloat = 70.459

struct Measurement {
    var ink: CGRect          // points, origin at canvas bottom-left
    var baseline: CGFloat    // points
    var coverage: Double     // fraction of ink bounding box filled
    var inkArea: Double      // ink area in template units squared
}

func measure(_ image: NSImage) -> Measurement? {
    let width = Int(image.size.width.rounded())
    let height = Int(image.size.height.rounded())
    guard width > 0, height > 0 else { return nil }

    var buffer = [UInt8](repeating: 0, count: width * height * 4)
    var box = CGRect.zero
    var coverage = 0.0

    buffer.withUnsafeMutableBytes { (raw: UnsafeMutableRawBufferPointer) in
        guard let context = CGContext(
            data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        image.draw(in: NSRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()

        var minX = width, maxX = -1, minY = height, maxY = -1
        var inked = 0
        let pixels = raw.bindMemory(to: UInt8.self)

        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width + x) * 4
                let luminance = (Int(pixels[index]) + Int(pixels[index + 1]) + Int(pixels[index + 2])) / 3
                guard luminance < 128 else { continue }
                inked += 1
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }
        guard maxX >= 0 else { return }

        box = CGRect(
            x: CGFloat(minX), y: CGFloat(height - 1 - maxY),
            width: CGFloat(maxX - minX + 1), height: CGFloat(maxY - minY + 1)
        )
        coverage = Double(inked) / Double(box.width * box.height)
    }

    guard box.width > 0 else { return nil }
    let area = Double(box.width * box.height) * Double(unitsPerPoint * unitsPerPoint) * coverage
    return Measurement(ink: box, baseline: image.alignmentRect.minY, coverage: coverage, inkArea: area)
}


let formatter = { (value: CGFloat) in String(format: "%7.2f", value) }

print("pointSize \(Int(pointSize)) (1 unit = \(String(format: "%.2f", pointSize / 100)) pt)")
print("")
print("Symbol                                InkWidth InkHeight | Bottom     Top | Center-capCenter | Fill  InkArea(units^2)")

for (label, base) in targets {
    guard let image = base.withSymbolConfiguration(
        .init(pointSize: pointSize, weight: .regular, scale: .medium)
    ), let m = measure(image) else {
        print("\(label): measurement failed")
        continue
    }

    let width = m.ink.width * unitsPerPoint
    let height = m.ink.height * unitsPerPoint
    let descender = m.ink.minY * unitsPerPoint - m.baseline * unitsPerPoint
    let ascender = m.ink.maxY * unitsPerPoint - m.baseline * unitsPerPoint
    let centre = (descender + ascender) / 2
    let centreOffset = centre - capHeight / 2

    print(String(
        format: "%-36@ %@ %@ | %@ %@ | %+8.2f (%+5.1f%%) | %4.0f%% %9.0f",
        label as NSString,
        formatter(width), formatter(height),
        formatter(descender), formatter(ascender),
        centreOffset, 100 * centreOffset / capHeight,
        100 * m.coverage, m.inkArea
    ))
}

print("")
print("Notes:")
print("  · Ink width/height: visible bounds in template units, for comparison with a reference.")
print("  · Bottom/top are relative to the baseline (alignmentRect.minY).")
print("  · Center-capCenter near zero indicates geometric centering; optical adjustment may differ.")
print("  · Fill/ink area estimate visual weight; equal bounds do not imply equal weight.")
