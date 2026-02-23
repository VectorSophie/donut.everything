"""
ASCII spinning torus (donut) in Python.

Features:
- Baseline animation mode that mirrors donut.c math
- Benchmark mode (compute-only) with FPS reporting
- Configurable geometry, screen, rotation speed, and ASCII ramp

No external graphics libraries; terminal output only.
"""

from __future__ import annotations

import argparse
import math
import sys
import time
from collections.abc import Iterable
from dataclasses import dataclass
from typing import cast


DEFAULT_SHADING = ".,-~:;=!*#$@"


@dataclass
class DonutConfig:
    width: int = 80
    height: int = 22
    r1: float = 1.0
    r2: float = 2.0
    k2: float = 5.0
    k1: float = 30.0
    a_step: float = 0.04
    b_step: float = 0.02
    theta_step: float = 0.07
    phi_step: float = 0.02
    shading: str = DEFAULT_SHADING
    mode: str = "baseline"


@dataclass
class CliOptions:
    width: int
    height: int
    r1: float
    r2: float
    k1: float
    k2: float
    a_step: float
    b_step: float
    theta_step: float
    phi_step: float
    shading: str
    mode: str
    benchmark: bool
    frames: int


@dataclass
class BenchmarkResult:
    frames: int
    total_time: float
    avg_frame_time: float
    fps: float


class DonutRenderer:
    def __init__(self, config: DonutConfig) -> None:
        self.cfg: DonutConfig = config
        self.a: float = 0.0
        self.b: float = 0.0

    def run_animation(self) -> None:
        _ = sys.stdout.write("\x1b[2J")
        _ = sys.stdout.flush()
        try:
            while True:
                frame = self._render_frame()
                _ = sys.stdout.write("\x1b[H\x1b[2J")
                _ = sys.stdout.write(frame)
                _ = sys.stdout.flush()
                self._step_angles()
        except KeyboardInterrupt:
            pass

    def run_benchmark(self, frames: int) -> BenchmarkResult:
        start = time.perf_counter()
        for _ in range(frames):
            _ = self._render_frame()
            self._step_angles()
        end = time.perf_counter()
        total = end - start
        avg = total / frames if frames else 0.0
        fps = frames / total if total > 0 else 0.0
        return BenchmarkResult(
            frames=frames,
            total_time=total,
            avg_frame_time=avg,
            fps=fps,
        )

    def _render_frame(self) -> str:
        cfg = self.cfg
        buffer: list[str] = [" "] * (cfg.width * cfg.height)
        zbuffer: list[float] = [0.0] * (cfg.width * cfg.height)

        sin_a, cos_a = math.sin(self.a), math.cos(self.a)
        sin_b, cos_b = math.sin(self.b), math.cos(self.b)

        theta_values = (
            self._precompute_angles(cfg.theta_step) if cfg.mode == "optimized" else None
        )
        phi_values = (
            self._precompute_angles(cfg.phi_step) if cfg.mode == "optimized" else None
        )

        theta_iter = (
            theta_values
            if theta_values is not None
            else self._angle_iter(cfg.theta_step)
        )

        for theta_sin, theta_cos in theta_iter:
            circlex = cfg.r2 + cfg.r1 * theta_cos
            circley = cfg.r1 * theta_sin

            phi_iter = (
                phi_values if phi_values is not None else self._angle_iter(cfg.phi_step)
            )

            for phi_sin, phi_cos in phi_iter:
                x = circlex * phi_cos
                y = circlex * phi_sin
                z = circley

                x1 = x
                y1 = y * cos_a - z * sin_a
                z1 = y * sin_a + z * cos_a

                x2 = x1 * cos_b - y1 * sin_b
                y2 = x1 * sin_b + y1 * cos_b
                z2 = z1

                ooz = 1.0 / (z2 + cfg.k2)
                xp = int(cfg.width / 2 + cfg.k1 * ooz * x2)
                yp = int(cfg.height / 2 - (cfg.k1 * 0.5) * ooz * y2)

                luminance = self._compute_luminance(
                    theta_sin, theta_cos, phi_sin, phi_cos, sin_a, cos_a, sin_b, cos_b
                )

                if luminance > 0:
                    idx = xp + cfg.width * yp
                    if (
                        0 <= xp < cfg.width
                        and 0 <= yp < cfg.height
                        and ooz > zbuffer[idx]
                    ):
                        zbuffer[idx] = ooz
                        shade_index = int(luminance * 8)
                        shade_index = min(shade_index, len(cfg.shading) - 1)
                        shade_char = cfg.shading[shade_index]
                        buffer[idx] = shade_char

        lines = [
            "".join(buffer[i : i + cfg.width]) for i in range(0, len(buffer), cfg.width)
        ]
        return "\n".join(lines) + "\n"

    @staticmethod
    def _compute_luminance(
        theta_sin: float,
        theta_cos: float,
        phi_sin: float,
        phi_cos: float,
        sin_a: float,
        cos_a: float,
        sin_b: float,
        cos_b: float,
    ) -> float:
        return (
            phi_cos * theta_cos * sin_b
            - cos_a * theta_cos * phi_sin
            - sin_a * theta_sin
            + cos_b * (cos_a * theta_sin - theta_cos * sin_a * phi_sin)
        )

    @staticmethod
    def _precompute_angles(step: float) -> list[tuple[float, float]]:
        two_pi = 2 * math.pi
        angles: list[tuple[float, float]] = []
        angle = 0.0
        while angle < two_pi:
            angles.append((math.sin(angle), math.cos(angle)))
            angle += step
        return angles

    @staticmethod
    def _angle_iter(step: float) -> Iterable[tuple[float, float]]:
        two_pi = 2 * math.pi
        angle = 0.0
        while angle < two_pi:
            yield math.sin(angle), math.cos(angle)
            angle += step

    def _step_angles(self) -> None:
        self.a += self.cfg.a_step
        self.b += self.cfg.b_step


def parse_args(argv: list[str]) -> CliOptions:
    parser = argparse.ArgumentParser(description="ASCII spinning torus (donut)")
    _ = parser.add_argument("--width", type=int, default=80, help="Screen width")
    _ = parser.add_argument("--height", type=int, default=22, help="Screen height")
    _ = parser.add_argument("--r1", type=float, default=1.0, help="Tube radius")
    _ = parser.add_argument("--r2", type=float, default=2.0, help="Center radius")
    _ = parser.add_argument(
        "--k1", type=float, default=5.0, help="Projection scaling constant"
    )
    _ = parser.add_argument(
        "--k2", type=float, default=5.0, help="Camera distance constant"
    )
    _ = parser.add_argument(
        "--a-step", type=float, default=0.04, help="Rotation speed for angle A"
    )
    _ = parser.add_argument(
        "--b-step", type=float, default=0.02, help="Rotation speed for angle B"
    )
    _ = parser.add_argument(
        "--theta-step", type=float, default=0.07, help="Theta angular step"
    )
    _ = parser.add_argument(
        "--phi-step", type=float, default=0.02, help="Phi angular step"
    )
    _ = parser.add_argument(
        "--shading",
        type=str,
        default=DEFAULT_SHADING,
        help="ASCII shading characters dark→bright",
    )
    _ = parser.add_argument(
        "--mode",
        choices=["baseline", "optimized"],
        default="baseline",
        help="Rendering mode",
    )
    _ = parser.add_argument(
        "--benchmark",
        action="store_true",
        help="Run benchmark mode (no terminal output)",
    )
    _ = parser.add_argument(
        "--frames", type=int, default=500, help="Number of frames for benchmark"
    )
    ns = parser.parse_args(argv)
    width: int = cast(int, ns.width)
    height: int = cast(int, ns.height)
    r1: float = cast(float, ns.r1)
    r2: float = cast(float, ns.r2)
    k1: float = cast(float, ns.k1)
    k2: float = cast(float, ns.k2)
    a_step: float = cast(float, ns.a_step)
    b_step: float = cast(float, ns.b_step)
    theta_step: float = cast(float, ns.theta_step)
    phi_step: float = cast(float, ns.phi_step)
    shading: str = cast(str, ns.shading)
    mode: str = cast(str, ns.mode)
    benchmark: bool = cast(bool, ns.benchmark)
    frames: int = cast(int, ns.frames)

    return CliOptions(
        width=width,
        height=height,
        r1=r1,
        r2=r2,
        k1=k1,
        k2=k2,
        a_step=a_step,
        b_step=b_step,
        theta_step=theta_step,
        phi_step=phi_step,
        shading=shading,
        mode=mode,
        benchmark=benchmark,
        frames=frames,
    )


def main(argv: list[str]) -> int:
    args: CliOptions = parse_args(argv)
    cfg = DonutConfig(
        width=args.width,
        height=args.height,
        r1=args.r1,
        r2=args.r2,
        k1=args.k1,
        k2=args.k2,
        a_step=args.a_step,
        b_step=args.b_step,
        theta_step=args.theta_step,
        phi_step=args.phi_step,
        shading=args.shading,
        mode=args.mode,
    )

    renderer = DonutRenderer(cfg)

    if args.benchmark:
        results = renderer.run_benchmark(args.frames)
        print("Language: Python")
        print(f"Frames: {results.frames}")
        print(f"Total Time: {results.total_time:.4f}s")
        print(f"Avg Frame Time: {results.avg_frame_time * 1000:.2f}ms")
        print(f"FPS: {results.fps:.2f}")
        return 0

    renderer.run_animation()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
