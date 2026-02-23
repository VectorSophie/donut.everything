using System;
using System.Diagnostics;
using System.Text;

internal sealed class Config
{
    public int Width = 80;
    public int Height = 22;
    public double R1 = 1.0;
    public double R2 = 2.0;
    public double K1 = 30.0;
    public double K2 = 5.0;
    public double AStep = 0.04;
    public double BStep = 0.02;
    public double ThetaStep = 0.07;
    public double PhiStep = 0.02;
    public string Shading = ".,-~:;=!*#$@";
    public bool Benchmark;
    public int Frames = 500;
}

internal sealed class Renderer
{
    private readonly Config _cfg;
    private double _a;
    private double _b;

    public Renderer(Config cfg) { _cfg = cfg; }

    public string RenderFrame()
    {
        var size = _cfg.Width * _cfg.Height;
        var buffer = new char[size];
        var zbuffer = new double[size];
        for (var i = 0; i < size; i++) buffer[i] = ' ';
        for (var i = 0; i < size; i++) zbuffer[i] = 0.0;

        var sinA = Math.Sin(_a);
        var cosA = Math.Cos(_a);
        var sinB = Math.Sin(_b);
        var cosB = Math.Cos(_b);

        for (var theta = 0.0; theta < Math.PI * 2.0; theta += _cfg.ThetaStep)
        {
            var thetaSin = Math.Sin(theta);
            var thetaCos = Math.Cos(theta);
            var circleX = _cfg.R2 + _cfg.R1 * thetaCos;
            var circleY = _cfg.R1 * thetaSin;

            for (var phi = 0.0; phi < Math.PI * 2.0; phi += _cfg.PhiStep)
            {
                var phiSin = Math.Sin(phi);
                var phiCos = Math.Cos(phi);

                var x = circleX * phiCos;
                var y = circleX * phiSin;
                var z = circleY;

                var x1 = x;
                var y1 = y * cosA - z * sinA;
                var z1 = y * sinA + z * cosA;

                var x2 = x1 * cosB - y1 * sinB;
                var y2 = x1 * sinB + y1 * cosB;
                var z2 = z1;

                var ooz = 1.0 / (z2 + _cfg.K2);
                var xp = (int)(_cfg.Width / 2.0 + _cfg.K1 * ooz * x2);
                var yp = (int)(_cfg.Height / 2.0 - (_cfg.K1 * 0.5) * ooz * y2);

                var luminance = phiCos * thetaCos * sinB
                                - cosA * thetaCos * phiSin
                                - sinA * thetaSin
                                + cosB * (cosA * thetaSin - thetaCos * sinA * phiSin);

                if (luminance > 0.0 && xp >= 0 && xp < _cfg.Width && yp >= 0 && yp < _cfg.Height)
                {
                    var idx = xp + _cfg.Width * yp;
                    if (ooz > zbuffer[idx])
                    {
                        zbuffer[idx] = ooz;
                        var shade = (int)(luminance * 8.0);
                        if (shade < 0) shade = 0;
                        if (shade >= _cfg.Shading.Length) shade = _cfg.Shading.Length - 1;
                        buffer[idx] = _cfg.Shading[shade];
                    }
                }
            }
        }

        var sb = new StringBuilder(size + _cfg.Height);
        for (var y = 0; y < _cfg.Height; y++)
        {
            for (var x = 0; x < _cfg.Width; x++) sb.Append(buffer[x + y * _cfg.Width]);
            sb.Append('\n');
        }
        return sb.ToString();
    }

    public void StepAngles()
    {
        _a += _cfg.AStep;
        _b += _cfg.BStep;
    }
}

internal static class Program
{
    private static Config ParseArgs(string[] args)
    {
        var cfg = new Config();
        for (var i = 0; i < args.Length; i++)
        {
            string arg = args[i];
            string Next() => i + 1 < args.Length ? args[++i] : "";

            if (arg == "--benchmark") cfg.Benchmark = true;
            else if (arg == "--width") cfg.Width = int.Parse(Next());
            else if (arg == "--height") cfg.Height = int.Parse(Next());
            else if (arg == "--r1") cfg.R1 = double.Parse(Next());
            else if (arg == "--r2") cfg.R2 = double.Parse(Next());
            else if (arg == "--k1") cfg.K1 = double.Parse(Next());
            else if (arg == "--k2") cfg.K2 = double.Parse(Next());
            else if (arg == "--a-step") cfg.AStep = double.Parse(Next());
            else if (arg == "--b-step") cfg.BStep = double.Parse(Next());
            else if (arg == "--theta-step") cfg.ThetaStep = double.Parse(Next());
            else if (arg == "--phi-step") cfg.PhiStep = double.Parse(Next());
            else if (arg == "--frames") cfg.Frames = int.Parse(Next());
            else if (arg == "--shading") cfg.Shading = Next();
        }
        return cfg;
    }

    private static void Main(string[] args)
    {
        var cfg = ParseArgs(args);
        var renderer = new Renderer(cfg);

        if (cfg.Benchmark)
        {
            var sw = Stopwatch.StartNew();
            for (var i = 0; i < cfg.Frames; i++)
            {
                renderer.RenderFrame();
                renderer.StepAngles();
            }
            sw.Stop();
            var total = sw.Elapsed.TotalSeconds;
            var avg = total / cfg.Frames;
            var fps = cfg.Frames / total;

            Console.WriteLine("Language: C#");
            Console.WriteLine($"Frames: {cfg.Frames}");
            Console.WriteLine($"Total Time: {total:F4}s");
            Console.WriteLine($"Avg Frame Time: {avg * 1000.0:F2}ms");
            Console.WriteLine($"FPS: {fps:F2}");
            return;
        }

        Console.Write("\x1b[2J");
        while (true)
        {
            Console.Write("\x1b[H\x1b[2J");
            Console.Write(renderer.RenderFrame());
            renderer.StepAngles();
        }
    }
}
