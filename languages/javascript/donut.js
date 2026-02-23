const DEFAULT_SHADING = ".,-~:;=!*#$@";

function parseArgs(argv) {
  const cfg = {
    width: 80,
    height: 22,
    r1: 1.0,
    r2: 2.0,
    k1: 30.0,
    k2: 5.0,
    aStep: 0.04,
    bStep: 0.02,
    thetaStep: 0.07,
    phiStep: 0.02,
    shading: DEFAULT_SHADING,
    benchmark: false,
    frames: 500,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = () => (i + 1 < argv.length ? argv[++i] : "");

    if (arg === "--benchmark") cfg.benchmark = true;
    else if (arg === "--width") cfg.width = Number(next());
    else if (arg === "--height") cfg.height = Number(next());
    else if (arg === "--r1") cfg.r1 = Number(next());
    else if (arg === "--r2") cfg.r2 = Number(next());
    else if (arg === "--k1") cfg.k1 = Number(next());
    else if (arg === "--k2") cfg.k2 = Number(next());
    else if (arg === "--a-step") cfg.aStep = Number(next());
    else if (arg === "--b-step") cfg.bStep = Number(next());
    else if (arg === "--theta-step") cfg.thetaStep = Number(next());
    else if (arg === "--phi-step") cfg.phiStep = Number(next());
    else if (arg === "--frames") cfg.frames = Number(next());
    else if (arg === "--shading") cfg.shading = next();
  }

  return cfg;
}

class Renderer {
  constructor(cfg) {
    this.cfg = cfg;
    this.a = 0.0;
    this.b = 0.0;
  }

  renderFrame() {
    const { width, height, r1, r2, k1, k2, thetaStep, phiStep, shading } = this.cfg;
    const buffer = new Array(width * height).fill(" ");
    const zbuffer = new Array(width * height).fill(0.0);

    const sinA = Math.sin(this.a);
    const cosA = Math.cos(this.a);
    const sinB = Math.sin(this.b);
    const cosB = Math.cos(this.b);

    for (let theta = 0.0; theta < Math.PI * 2.0; theta += thetaStep) {
      const thetaSin = Math.sin(theta);
      const thetaCos = Math.cos(theta);
      const circleX = r2 + r1 * thetaCos;
      const circleY = r1 * thetaSin;

      for (let phi = 0.0; phi < Math.PI * 2.0; phi += phiStep) {
        const phiSin = Math.sin(phi);
        const phiCos = Math.cos(phi);

        const x = circleX * phiCos;
        const y = circleX * phiSin;
        const z = circleY;

        const x1 = x;
        const y1 = y * cosA - z * sinA;
        const z1 = y * sinA + z * cosA;

        const x2 = x1 * cosB - y1 * sinB;
        const y2 = x1 * sinB + y1 * cosB;
        const z2 = z1;

        const ooz = 1.0 / (z2 + k2);
        const xp = Math.trunc(width / 2 + k1 * ooz * x2);
        const yp = Math.trunc(height / 2 - (k1 * 0.5) * ooz * y2);

        const luminance =
          phiCos * thetaCos * sinB -
          cosA * thetaCos * phiSin -
          sinA * thetaSin +
          cosB * (cosA * thetaSin - thetaCos * sinA * phiSin);

        if (luminance > 0 && xp >= 0 && xp < width && yp >= 0 && yp < height) {
          const idx = xp + width * yp;
          if (ooz > zbuffer[idx]) {
            zbuffer[idx] = ooz;
            let shade = Math.trunc(luminance * 8.0);
            if (shade < 0) shade = 0;
            if (shade >= shading.length) shade = shading.length - 1;
            buffer[idx] = shading[shade];
          }
        }
      }
    }

    let out = "";
    for (let y = 0; y < height; y += 1) {
      out += buffer.slice(y * width, (y + 1) * width).join("") + "\n";
    }
    return out;
  }

  stepAngles() {
    this.a += this.cfg.aStep;
    this.b += this.cfg.bStep;
  }
}

function run() {
    const cfg = parseArgs(process.argv.slice(2));
    const renderer = new Renderer(cfg);

    if (cfg.benchmark) {
      const start = process.hrtime.bigint();
      for (let i = 0; i < cfg.frames; i += 1) {
        renderer.renderFrame();
        renderer.stepAngles();
      }
      const end = process.hrtime.bigint();
      const total = Number(end - start) / 1e9;
      const avg = total / cfg.frames;
      const fps = cfg.frames / total;
      console.log("Language: JavaScript (Node.js)");
      console.log(`Frames: ${cfg.frames}`);
      console.log(`Total Time: ${total.toFixed(4)}s`);
      console.log(`Avg Frame Time: ${(avg * 1000).toFixed(2)}ms`);
      console.log(`FPS: ${fps.toFixed(2)}`);
      return;
    }

    process.stdout.write("\x1b[2J");
    while (true) {
      process.stdout.write("\x1b[H\x1b[2J");
      process.stdout.write(renderer.renderFrame());
      renderer.stepAngles();
    }
}

run();
