import Foundation
import ReferenceCrop

private enum InputError: Error, CustomStringConvertible {
    case usage
    case dimensions
    case focus

    var description: String {
        switch self {
        case .usage: return "Usage: krea2-crop WIDTH HEIGHT RATIO [FOCUS_X FOCUS_Y]"
        case .dimensions: return "Width, height and both ratio parts must be integers."
        case .focus: return "Focus coordinates must be numbers between 0 and 1."
        }
    }
}

private func run(_ arguments: [String]) throws {
    guard arguments.count == 3 || arguments.count == 5 else {
        throw InputError.usage
    }
    let ratio = arguments[2].split(separator: ":", omittingEmptySubsequences: false)
    guard let width = Int(arguments[0]), let height = Int(arguments[1]),
          ratio.count == 2, let ratioWidth = Int(ratio[0]), let ratioHeight = Int(ratio[1]) else {
        throw InputError.dimensions
    }
    var focusX = 0.5
    var focusY = 0.5
    if arguments.count == 5 {
        guard let x = Double(arguments[3]), let y = Double(arguments[4]) else {
            throw InputError.focus
        }
        (focusX, focusY) = (x, y)
    }
    let result = try CropPlanner.plan(
        width: width, height: height,
        ratio: AspectRatio(width: ratioWidth, height: ratioHeight),
        focusX: focusX, focusY: focusY
    )
    FileHandle.standardOutput.write(try JSONEncoder().encode(result))
    FileHandle.standardOutput.write(Data("\n".utf8))
}

do {
    try run(Array(CommandLine.arguments.dropFirst()))
} catch {
    FileHandle.standardError.write(Data("\(error)\n".utf8))
    exit(1)
}
