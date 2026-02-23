import java.util.Arrays;

public final class Donut {
    private static final String DEFAULT_SHADING = ".,-~:;=!*#$@";

    private static final class Config {
        int width = 80;
        int height = 22;
        double r1 = 1.0;
        double r2 = 2.0;
        double k1 = 30.0;
        double k2 = 5.0;
        double aStep = 0.04;
        double bStep = 0.02;
        double thetaStep = 0.07;
        double phiStep = 0.02;
        String shading = DEFAULT_SHADING;
        boolean benchmark = false;
        int frames = 500;
    }

    private static final class Renderer {
        private final Config cfg;
        private double a = 0.0;
        private double b = 0.0;

        Renderer(Config cfg) {
            this.cfg = cfg;
        }

        String renderFrame() {
            int size = cfg.width * cfg.height;
            char[] buffer = new char[size];
            double[] zbuffer = new double[size];
            Arrays.fill(buffer, ' ');
            Arrays.fill(zbuffer, 0.0);

            double sinA = Math.sin(a);
            double cosA = Math.cos(a);
            double sinB = Math.sin(b);
            double cosB = Math.cos(b);

            for (double theta = 0.0; theta < Math.PI * 2.0; theta += cfg.thetaStep) {
                double thetaSin = Math.sin(theta);
                double thetaCos = Math.cos(theta);
                double circleX = cfg.r2 + cfg.r1 * thetaCos;
                double circleY = cfg.r1 * thetaSin;

                for (double phi = 0.0; phi < Math.PI * 2.0; phi += cfg.phiStep) {
                    double phiSin = Math.sin(phi);
                    double phiCos = Math.cos(phi);

                    double x = circleX * phiCos;
                    double y = circleX * phiSin;
                    double z = circleY;

                    double x1 = x;
                    double y1 = y * cosA - z * sinA;
                    double z1 = y * sinA + z * cosA;

                    double x2 = x1 * cosB - y1 * sinB;
                    double y2 = x1 * sinB + y1 * cosB;
                    double z2 = z1;

                    double ooz = 1.0 / (z2 + cfg.k2);
                    int xp = (int) (cfg.width / 2.0 + cfg.k1 * ooz * x2);
                    int yp = (int) (cfg.height / 2.0 - (cfg.k1 * 0.5) * ooz * y2);

                    double luminance = phiCos * thetaCos * sinB
                            - cosA * thetaCos * phiSin
                            - sinA * thetaSin
                            + cosB * (cosA * thetaSin - thetaCos * sinA * phiSin);

                    if (luminance > 0.0 && xp >= 0 && xp < cfg.width && yp >= 0 && yp < cfg.height) {
                        int idx = xp + cfg.width * yp;
                        if (ooz > zbuffer[idx]) {
                            zbuffer[idx] = ooz;
                            int shade = (int) (luminance * 8.0);
                            if (shade < 0) shade = 0;
                            if (shade >= cfg.shading.length()) shade = cfg.shading.length() - 1;
                            buffer[idx] = cfg.shading.charAt(shade);
                        }
                    }
                }
            }

            StringBuilder out = new StringBuilder(size + cfg.height);
            for (int y = 0; y < cfg.height; y++) {
                for (int x = 0; x < cfg.width; x++) {
                    out.append(buffer[x + y * cfg.width]);
                }
                out.append('\n');
            }
            return out.toString();
        }

        void stepAngles() {
            a += cfg.aStep;
            b += cfg.bStep;
        }
    }

    private static Config parseArgs(String[] args) {
        Config cfg = new Config();
        for (int i = 0; i < args.length; i++) {
            String arg = args[i];
            String next = (i + 1 < args.length) ? args[i + 1] : "";
            switch (arg) {
                case "--benchmark":
                    cfg.benchmark = true;
                    break;
                case "--width": cfg.width = Integer.parseInt(next); i++; break;
                case "--height": cfg.height = Integer.parseInt(next); i++; break;
                case "--r1": cfg.r1 = Double.parseDouble(next); i++; break;
                case "--r2": cfg.r2 = Double.parseDouble(next); i++; break;
                case "--k1": cfg.k1 = Double.parseDouble(next); i++; break;
                case "--k2": cfg.k2 = Double.parseDouble(next); i++; break;
                case "--a-step": cfg.aStep = Double.parseDouble(next); i++; break;
                case "--b-step": cfg.bStep = Double.parseDouble(next); i++; break;
                case "--theta-step": cfg.thetaStep = Double.parseDouble(next); i++; break;
                case "--phi-step": cfg.phiStep = Double.parseDouble(next); i++; break;
                case "--frames": cfg.frames = Integer.parseInt(next); i++; break;
                case "--shading": cfg.shading = next; i++; break;
                default:
                    break;
            }
        }
        return cfg;
    }

    public static void main(String[] args) {
        Config cfg = parseArgs(args);
        Renderer renderer = new Renderer(cfg);

        if (cfg.benchmark) {
            long start = System.nanoTime();
            for (int i = 0; i < cfg.frames; i++) {
                renderer.renderFrame();
                renderer.stepAngles();
            }
            double total = (System.nanoTime() - start) / 1_000_000_000.0;
            double avg = total / cfg.frames;
            double fps = cfg.frames / total;

            System.out.println("Language: Java");
            System.out.println("Frames: " + cfg.frames);
            System.out.printf("Total Time: %.4fs%n", total);
            System.out.printf("Avg Frame Time: %.2fms%n", avg * 1000.0);
            System.out.printf("FPS: %.2f%n", fps);
            return;
        }

        System.out.print("\u001b[2J");
        while (true) {
            System.out.print("\u001b[H\u001b[2J");
            System.out.print(renderer.renderFrame());
            renderer.stepAngles();
        }
    }
}
