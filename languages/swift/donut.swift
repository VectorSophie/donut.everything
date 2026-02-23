import Foundation

struct Config {
    var width: Int = 80
    var height: Int = 22
    var r1: Double = 1.0
    var r2: Double = 2.0
    var k1: Double = 30.0
    var k2: Double = 5.0
    var aStep: Double = 0.04
    var bStep: Double = 0.02
    var thetaStep: Double = 0.07
    var phiStep: Double = 0.02
    var shading: [Character] = Array(".,-~:;=!*#$@")
    var benchmark: Bool = false
    var frames: Int = 500
}

final class Renderer {
    private let cfg: Config
    private var a: Double = 0.0
    private var b: Double = 0.0

    init(cfg: Config) {
        self.cfg = cfg
    }

    func renderFrame() -> String {
        let size = cfg.width * cfg.height
        var buffer = Array(repeating: Character(" "), count: size)
        var zbuffer = Array(repeating: 0.0, count: size)

        let sinA = sin(a)
        let cosA = cos(a)
        let sinB = sin(b)
        let cosB = cos(b)

        var theta = 0.0
        while theta < Double.pi * 2.0 {
            let thetaSin = sin(theta)
            let thetaCos = cos(theta)
            let circleX = cfg.r2 + cfg.r1 * thetaCos
            let circleY = cfg.r1 * thetaSin

            var phi = 0.0
            while phi < Double.pi * 2.0 {
                let phiSin = sin(phi)
                let phiCos = cos(phi)

                let x = circleX * phiCos
                let y = circleX * phiSin
                let z = circleY

                let x1 = x
                let y1 = y * cosA - z * sinA
                let z1 = y * sinA + z * cosA

                let x2 = x1 * cosB - y1 * sinB
                let y2 = x1 * sinB + y1 * cosB
                let z2 = z1

                let ooz = 1.0 / (z2 + cfg.k2)
                let xp = Int(Double(cfg.width) / 2.0 + cfg.k1 * ooz * x2)
                let yp = Int(Double(cfg.height) / 2.0 - (cfg.k1 * 0.5) * ooz * y2)

                let luminance = phiCos * thetaCos * sinB
                    - cosA * thetaCos * phiSin
                    - sinA * thetaSin
                    + cosB * (cosA * thetaSin - thetaCos * sinA * phiSin)

                if luminance > 0.0 && xp >= 0 && xp < cfg.width && yp >= 0 && yp < cfg.height {
                    let idx = xp + cfg.width * yp
                    if ooz > zbuffer[idx] {
                        zbuffer[idx] = ooz
                        var shade = Int(luminance * 8.0)
                        if shade < 0 { shade = 0 }
                        if shade >= cfg.shading.count { shade = cfg.shading.count - 1 }
                        buffer[idx] = cfg.shading[shade]
                    }
                }

                phi += cfg.phiStep
            }

            theta += cfg.thetaStep
        }

        var lines = String()
        lines.reserveCapacity(size + cfg.height)
        for y in 0..<cfg.height {
            for x in 0..<cfg.width {
                lines.append(buffer[x + y * cfg.width])
            }
            lines.append("\n")
        }
        return lines
    }

    func stepAngles() {
        a += cfg.aStep
        b += cfg.bStep
    }
}

func parseArgs(_ args: [String]) -> Config {
    var cfg = Config()
    var i = 0
    while i < args.count {
        let arg = args[i]
        func next() -> String {
            i += 1
            return i < args.count ? args[i] : ""
        }

        switch arg {
        case "--benchmark": cfg.benchmark = true
        case "--width": cfg.width = Int(next()) ?? cfg.width
        case "--height": cfg.height = Int(next()) ?? cfg.height
        case "--r1": cfg.r1 = Double(next()) ?? cfg.r1
        case "--r2": cfg.r2 = Double(next()) ?? cfg.r2
        case "--k1": cfg.k1 = Double(next()) ?? cfg.k1
        case "--k2": cfg.k2 = Double(next()) ?? cfg.k2
        case "--a-step": cfg.aStep = Double(next()) ?? cfg.aStep
        case "--b-step": cfg.bStep = Double(next()) ?? cfg.bStep
        case "--theta-step": cfg.thetaStep = Double(next()) ?? cfg.thetaStep
        case "--phi-step": cfg.phiStep = Double(next()) ?? cfg.phiStep
        case "--frames": cfg.frames = Int(next()) ?? cfg.frames
        case "--shading": cfg.shading = Array(next())
        default: break
        }

        i += 1
    }
    return cfg
}

let cfg = parseArgs(Array(CommandLine.arguments.dropFirst()))
let renderer = Renderer(cfg: cfg)

if cfg.benchmark {
    let start = CFAbsoluteTimeGetCurrent()
    for _ in 0..<cfg.frames {
        _ = renderer.renderFrame()
        renderer.stepAngles()
    }
    let total = CFAbsoluteTimeGetCurrent() - start
    let avg = total / Double(cfg.frames)
    let fps = Double(cfg.frames) / total
    print("Language: Swift")
    print("Frames: \(cfg.frames)")
    print(String(format: "Total Time: %.4fs", total))
    print(String(format: "Avg Frame Time: %.2fms", avg * 1000.0))
    print(String(format: "FPS: %.2f", fps))
} else {
    print("\u{001B}[2J", terminator: "")
    while true {
        print("\u{001B}[H\u{001B}[2J", terminator: "")
        print(renderer.renderFrame(), terminator: "")
        renderer.stepAngles()
    }
}
