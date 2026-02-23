import kotlin.math.cos
import kotlin.math.sin
import kotlin.system.measureNanoTime

data class Config(
    var width: Int = 80,
    var height: Int = 22,
    var r1: Double = 1.0,
    var r2: Double = 2.0,
    var k1: Double = 30.0,
    var k2: Double = 5.0,
    var aStep: Double = 0.04,
    var bStep: Double = 0.02,
    var thetaStep: Double = 0.07,
    var phiStep: Double = 0.02,
    var shading: String = ".,-~:;=!*#$@",
    var benchmark: Boolean = false,
    var frames: Int = 500
)

class Renderer(private val cfg: Config) {
    private var a = 0.0
    private var b = 0.0

    fun renderFrame(): String {
        val size = cfg.width * cfg.height
        val buffer = CharArray(size) { ' ' }
        val zbuffer = DoubleArray(size) { 0.0 }

        val sinA = sin(a)
        val cosA = cos(a)
        val sinB = sin(b)
        val cosB = cos(b)

        var theta = 0.0
        while (theta < Math.PI * 2.0) {
            val thetaSin = sin(theta)
            val thetaCos = cos(theta)
            val circleX = cfg.r2 + cfg.r1 * thetaCos
            val circleY = cfg.r1 * thetaSin

            var phi = 0.0
            while (phi < Math.PI * 2.0) {
                val phiSin = sin(phi)
                val phiCos = cos(phi)

                val x = circleX * phiCos
                val y = circleX * phiSin
                val z = circleY

                val x1 = x
                val y1 = y * cosA - z * sinA
                val z1 = y * sinA + z * cosA

                val x2 = x1 * cosB - y1 * sinB
                val y2 = x1 * sinB + y1 * cosB
                val z2 = z1

                val ooz = 1.0 / (z2 + cfg.k2)
                val xp = (cfg.width / 2.0 + cfg.k1 * ooz * x2).toInt()
                val yp = (cfg.height / 2.0 - (cfg.k1 * 0.5) * ooz * y2).toInt()

                val luminance = phiCos * thetaCos * sinB -
                    cosA * thetaCos * phiSin -
                    sinA * thetaSin +
                    cosB * (cosA * thetaSin - thetaCos * sinA * phiSin)

                if (luminance > 0.0 && xp in 0 until cfg.width && yp in 0 until cfg.height) {
                    val idx = xp + cfg.width * yp
                    if (ooz > zbuffer[idx]) {
                        zbuffer[idx] = ooz
                        var shade = (luminance * 8.0).toInt()
                        if (shade < 0) shade = 0
                        if (shade >= cfg.shading.length) shade = cfg.shading.length - 1
                        buffer[idx] = cfg.shading[shade]
                    }
                }

                phi += cfg.phiStep
            }
            theta += cfg.thetaStep
        }

        return buildString(size + cfg.height) {
            for (y in 0 until cfg.height) {
                for (x in 0 until cfg.width) append(buffer[x + y * cfg.width])
                append('\n')
            }
        }
    }

    fun stepAngles() {
        a += cfg.aStep
        b += cfg.bStep
    }
}

fun parseArgs(args: Array<String>): Config {
    val cfg = Config()
    var i = 0
    while (i < args.size) {
        val arg = args[i]
        fun next(): String {
            i += 1
            return if (i < args.size) args[i] else ""
        }

        when (arg) {
            "--benchmark" -> cfg.benchmark = true
            "--width" -> cfg.width = next().toInt()
            "--height" -> cfg.height = next().toInt()
            "--r1" -> cfg.r1 = next().toDouble()
            "--r2" -> cfg.r2 = next().toDouble()
            "--k1" -> cfg.k1 = next().toDouble()
            "--k2" -> cfg.k2 = next().toDouble()
            "--a-step" -> cfg.aStep = next().toDouble()
            "--b-step" -> cfg.bStep = next().toDouble()
            "--theta-step" -> cfg.thetaStep = next().toDouble()
            "--phi-step" -> cfg.phiStep = next().toDouble()
            "--frames" -> cfg.frames = next().toInt()
            "--shading" -> cfg.shading = next()
        }
        i += 1
    }
    return cfg
}

fun main(args: Array<String>) {
    val cfg = parseArgs(args)
    val renderer = Renderer(cfg)

    if (cfg.benchmark) {
        val nanos = measureNanoTime {
            repeat(cfg.frames) {
                renderer.renderFrame()
                renderer.stepAngles()
            }
        }
        val total = nanos / 1_000_000_000.0
        val avg = total / cfg.frames
        val fps = cfg.frames / total
        println("Language: Kotlin")
        println("Frames: ${cfg.frames}")
        println("Total Time: ${"%.4f".format(total)}s")
        println("Avg Frame Time: ${"%.2f".format(avg * 1000.0)}ms")
        println("FPS: ${"%.2f".format(fps)}")
        return
    }

    print("\u001b[2J")
    while (true) {
        print("\u001b[H\u001b[2J")
        print(renderer.renderFrame())
        renderer.stepAngles()
    }
}
