use std::env;
use std::f64::consts::TAU;
use std::io::{self, Write};
use std::time::Instant;

#[derive(Clone)]
struct Config {
    width: usize,
    height: usize,
    r1: f64,
    r2: f64,
    k1: f64,
    k2: f64,
    a_step: f64,
    b_step: f64,
    theta_step: f64,
    phi_step: f64,
    shading: Vec<char>,
    benchmark: bool,
    frames: usize,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            width: 80,
            height: 22,
            r1: 1.0,
            r2: 2.0,
            k1: 30.0,
            k2: 5.0,
            a_step: 0.04,
            b_step: 0.02,
            theta_step: 0.07,
            phi_step: 0.02,
            shading: ".,-~:;=!*#$@".chars().collect(),
            benchmark: false,
            frames: 500,
        }
    }
}

struct Renderer {
    cfg: Config,
    a: f64,
    b: f64,
}

impl Renderer {
    fn new(cfg: Config) -> Self {
        Self {
            cfg,
            a: 0.0,
            b: 0.0,
        }
    }

    fn render_frame(&self) -> String {
        let mut buffer = vec![' '; self.cfg.width * self.cfg.height];
        let mut zbuffer = vec![0.0_f64; self.cfg.width * self.cfg.height];

        let sin_a = self.a.sin();
        let cos_a = self.a.cos();
        let sin_b = self.b.sin();
        let cos_b = self.b.cos();

        let mut theta = 0.0;
        while theta < TAU {
            let theta_sin = theta.sin();
            let theta_cos = theta.cos();
            let circle_x = self.cfg.r2 + self.cfg.r1 * theta_cos;
            let circle_y = self.cfg.r1 * theta_sin;

            let mut phi = 0.0;
            while phi < TAU {
                let phi_sin = phi.sin();
                let phi_cos = phi.cos();

                let x = circle_x * phi_cos;
                let y = circle_x * phi_sin;
                let z = circle_y;

                let x1 = x;
                let y1 = y * cos_a - z * sin_a;
                let z1 = y * sin_a + z * cos_a;

                let x2 = x1 * cos_b - y1 * sin_b;
                let y2 = x1 * sin_b + y1 * cos_b;
                let z2 = z1;

                let ooz = 1.0 / (z2 + self.cfg.k2);
                let xp = (self.cfg.width as f64 / 2.0 + self.cfg.k1 * ooz * x2) as isize;
                let yp = (self.cfg.height as f64 / 2.0 - (self.cfg.k1 * 0.5) * ooz * y2) as isize;

                let luminance =
                    phi_cos * theta_cos * sin_b - cos_a * theta_cos * phi_sin - sin_a * theta_sin
                        + cos_b * (cos_a * theta_sin - theta_cos * sin_a * phi_sin);

                if luminance > 0.0
                    && xp >= 0
                    && yp >= 0
                    && (xp as usize) < self.cfg.width
                    && (yp as usize) < self.cfg.height
                {
                    let idx = xp as usize + self.cfg.width * yp as usize;
                    if ooz > zbuffer[idx] {
                        zbuffer[idx] = ooz;
                        let mut shade = (luminance * 8.0) as isize;
                        if shade < 0 {
                            shade = 0;
                        }
                        let max_idx = self.cfg.shading.len() as isize - 1;
                        if shade > max_idx {
                            shade = max_idx;
                        }
                        buffer[idx] = self.cfg.shading[shade as usize];
                    }
                }

                phi += self.cfg.phi_step;
            }
            theta += self.cfg.theta_step;
        }

        let mut out = String::with_capacity(self.cfg.width * self.cfg.height + self.cfg.height);
        for y in 0..self.cfg.height {
            for x in 0..self.cfg.width {
                out.push(buffer[x + y * self.cfg.width]);
            }
            out.push('\n');
        }
        out
    }

    fn step_angles(&mut self) {
        self.a += self.cfg.a_step;
        self.b += self.cfg.b_step;
    }

    fn run_benchmark(&mut self) {
        let start = Instant::now();
        for _ in 0..self.cfg.frames {
            let _ = self.render_frame();
            self.step_angles();
        }
        let total = start.elapsed().as_secs_f64();
        let avg = total / self.cfg.frames as f64;
        let fps = self.cfg.frames as f64 / total;
        println!("Language: Rust");
        println!("Frames: {}", self.cfg.frames);
        println!("Total Time: {:.4}s", total);
        println!("Avg Frame Time: {:.2}ms", avg * 1000.0);
        println!("FPS: {:.2}", fps);
    }

    fn animate(&mut self) {
        print!("\x1b[2J");
        let _ = io::stdout().flush();
        loop {
            print!("\x1b[H\x1b[2J{}", self.render_frame());
            let _ = io::stdout().flush();
            self.step_angles();
        }
    }
}

fn parse_args() -> Config {
    let mut cfg = Config::default();
    let args: Vec<String> = env::args().collect();
    let mut i = 1;
    while i < args.len() {
        let arg = &args[i];
        let next = |args: &Vec<String>, i: &mut usize| -> Option<String> {
            if *i + 1 < args.len() {
                *i += 1;
                Some(args[*i].clone())
            } else {
                None
            }
        };

        match arg.as_str() {
            "--benchmark" => cfg.benchmark = true,
            "--width" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.width = v.parse().unwrap_or(cfg.width);
                }
            }
            "--height" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.height = v.parse().unwrap_or(cfg.height);
                }
            }
            "--r1" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.r1 = v.parse().unwrap_or(cfg.r1);
                }
            }
            "--r2" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.r2 = v.parse().unwrap_or(cfg.r2);
                }
            }
            "--k1" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.k1 = v.parse().unwrap_or(cfg.k1);
                }
            }
            "--k2" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.k2 = v.parse().unwrap_or(cfg.k2);
                }
            }
            "--a-step" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.a_step = v.parse().unwrap_or(cfg.a_step);
                }
            }
            "--b-step" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.b_step = v.parse().unwrap_or(cfg.b_step);
                }
            }
            "--theta-step" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.theta_step = v.parse().unwrap_or(cfg.theta_step);
                }
            }
            "--phi-step" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.phi_step = v.parse().unwrap_or(cfg.phi_step);
                }
            }
            "--frames" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.frames = v.parse().unwrap_or(cfg.frames);
                }
            }
            "--shading" => {
                if let Some(v) = next(&args, &mut i) {
                    cfg.shading = v.chars().collect();
                }
            }
            _ => {}
        }
        i += 1;
    }
    cfg
}

fn main() {
    let cfg = parse_args();
    let mut renderer = Renderer::new(cfg.clone());
    if cfg.benchmark {
        renderer.run_benchmark();
    } else {
        renderer.animate();
    }
}
