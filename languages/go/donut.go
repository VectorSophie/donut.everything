package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"time"
)

type Config struct {
	Width     int
	Height    int
	R1        float64
	R2        float64
	K1        float64
	K2        float64
	AStep     float64
	BStep     float64
	ThetaStep float64
	PhiStep   float64
	Shading   []rune
	Benchmark bool
	Frames    int
}

func defaultConfig() Config {
	return Config{
		Width:     80,
		Height:    22,
		R1:        1.0,
		R2:        2.0,
		K1:        30.0,
		K2:        5.0,
		AStep:     0.04,
		BStep:     0.02,
		ThetaStep: 0.07,
		PhiStep:   0.02,
		Shading:   []rune(".,-~:;=!*#$@"),
		Benchmark: false,
		Frames:    500,
	}
}

type Renderer struct {
	cfg Config
	a   float64
	b   float64
}

func (r *Renderer) renderFrame() string {
	buffer := make([]rune, r.cfg.Width*r.cfg.Height)
	for i := range buffer {
		buffer[i] = ' '
	}
	zbuffer := make([]float64, r.cfg.Width*r.cfg.Height)

	sinA, cosA := math.Sin(r.a), math.Cos(r.a)
	sinB, cosB := math.Sin(r.b), math.Cos(r.b)

	for theta := 0.0; theta < 2*math.Pi; theta += r.cfg.ThetaStep {
		thetaSin, thetaCos := math.Sin(theta), math.Cos(theta)
		circleX := r.cfg.R2 + r.cfg.R1*thetaCos
		circleY := r.cfg.R1 * thetaSin

		for phi := 0.0; phi < 2*math.Pi; phi += r.cfg.PhiStep {
			phiSin, phiCos := math.Sin(phi), math.Cos(phi)

			x := circleX * phiCos
			y := circleX * phiSin
			z := circleY

			x1 := x
			y1 := y*cosA - z*sinA
			z1 := y*sinA + z*cosA

			x2 := x1*cosB - y1*sinB
			y2 := x1*sinB + y1*cosB
			z2 := z1

			ooz := 1.0 / (z2 + r.cfg.K2)
			xp := int(float64(r.cfg.Width)/2.0 + r.cfg.K1*ooz*x2)
			yp := int(float64(r.cfg.Height)/2.0 - (r.cfg.K1*0.5)*ooz*y2)

			luminance := phiCos*thetaCos*sinB - cosA*thetaCos*phiSin - sinA*thetaSin + cosB*(cosA*thetaSin-thetaCos*sinA*phiSin)

			if luminance > 0 && xp >= 0 && xp < r.cfg.Width && yp >= 0 && yp < r.cfg.Height {
				idx := xp + r.cfg.Width*yp
				if ooz > zbuffer[idx] {
					zbuffer[idx] = ooz
					shade := int(luminance * 8.0)
					if shade < 0 {
						shade = 0
					}
					if shade >= len(r.cfg.Shading) {
						shade = len(r.cfg.Shading) - 1
					}
					buffer[idx] = r.cfg.Shading[shade]
				}
			}
		}
	}

	out := make([]rune, 0, r.cfg.Width*r.cfg.Height+r.cfg.Height)
	for y := 0; y < r.cfg.Height; y++ {
		for x := 0; x < r.cfg.Width; x++ {
			out = append(out, buffer[x+y*r.cfg.Width])
		}
		out = append(out, '\n')
	}
	return string(out)
}

func (r *Renderer) stepAngles() {
	r.a += r.cfg.AStep
	r.b += r.cfg.BStep
}

func parseArgs() Config {
	cfg := defaultConfig()
	args := os.Args[1:]
	for i := 0; i < len(args); i++ {
		arg := args[i]
		next := func() string {
			if i+1 < len(args) {
				i++
				return args[i]
			}
			return ""
		}
		switch arg {
		case "--benchmark":
			cfg.Benchmark = true
		case "--width":
			if v, err := strconv.Atoi(next()); err == nil {
				cfg.Width = v
			}
		case "--height":
			if v, err := strconv.Atoi(next()); err == nil {
				cfg.Height = v
			}
		case "--r1":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.R1 = v
			}
		case "--r2":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.R2 = v
			}
		case "--k1":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.K1 = v
			}
		case "--k2":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.K2 = v
			}
		case "--a-step":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.AStep = v
			}
		case "--b-step":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.BStep = v
			}
		case "--theta-step":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.ThetaStep = v
			}
		case "--phi-step":
			if v, err := strconv.ParseFloat(next(), 64); err == nil {
				cfg.PhiStep = v
			}
		case "--frames":
			if v, err := strconv.Atoi(next()); err == nil {
				cfg.Frames = v
			}
		case "--shading":
			cfg.Shading = []rune(next())
		}
	}
	return cfg
}

func main() {
	cfg := parseArgs()
	renderer := Renderer{cfg: cfg}

	if cfg.Benchmark {
		start := time.Now()
		for i := 0; i < cfg.Frames; i++ {
			_ = renderer.renderFrame()
			renderer.stepAngles()
		}
		total := time.Since(start).Seconds()
		avg := total / float64(cfg.Frames)
		fps := float64(cfg.Frames) / total
		fmt.Println("Language: Go")
		fmt.Printf("Frames: %d\n", cfg.Frames)
		fmt.Printf("Total Time: %.4fs\n", total)
		fmt.Printf("Avg Frame Time: %.2fms\n", avg*1000.0)
		fmt.Printf("FPS: %.2f\n", fps)
		return
	}

	fmt.Print("\x1b[2J")
	for {
		fmt.Print("\x1b[H\x1b[2J")
		fmt.Print(renderer.renderFrame())
		renderer.stepAngles()
	}
}
