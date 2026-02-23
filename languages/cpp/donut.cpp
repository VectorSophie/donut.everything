#include <chrono>
#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

struct Config {
    int width = 80;
    int height = 22;
    double r1 = 1.0;
    double r2 = 2.0;
    double k1 = 30.0;
    double k2 = 5.0;
    double a_step = 0.04;
    double b_step = 0.02;
    double theta_step = 0.07;
    double phi_step = 0.02;
    std::string shading = ".,-~:;=!*#$@";
    bool benchmark = false;
    int frames = 500;
};

class Renderer {
  public:
    explicit Renderer(Config cfg) : cfg_(std::move(cfg)) {}

    void animate() {
        std::cout << "\x1b[2J";
        while (true) {
            std::cout << "\x1b[H\x1b[2J" << render_frame();
            std::cout.flush();
            step_angles();
        }
    }

    void benchmark() {
        const auto start = std::chrono::steady_clock::now();
        for (int i = 0; i < cfg_.frames; ++i) {
            (void)render_frame();
            step_angles();
        }
        const auto end = std::chrono::steady_clock::now();
        const std::chrono::duration<double> total = end - start;
        const double avg = total.count() / static_cast<double>(cfg_.frames);
        const double fps = static_cast<double>(cfg_.frames) / total.count();

        std::cout << "Language: C++\n";
        std::cout << "Frames: " << cfg_.frames << "\n";
        std::cout << "Total Time: " << std::fixed << std::setprecision(4) << total.count() << "s\n";
        std::cout << "Avg Frame Time: " << std::fixed << std::setprecision(2) << (avg * 1000.0) << "ms\n";
        std::cout << "FPS: " << std::fixed << std::setprecision(2) << fps << "\n";
    }

  private:
    std::string render_frame() const {
        constexpr double two_pi = 6.283185307179586;
        std::vector<char> buffer(static_cast<size_t>(cfg_.width * cfg_.height), ' ');
        std::vector<double> zbuffer(static_cast<size_t>(cfg_.width * cfg_.height), 0.0);

        const double sin_a = std::sin(a_);
        const double cos_a = std::cos(a_);
        const double sin_b = std::sin(b_);
        const double cos_b = std::cos(b_);

        for (double theta = 0.0; theta < two_pi; theta += cfg_.theta_step) {
            const double theta_sin = std::sin(theta);
            const double theta_cos = std::cos(theta);
            const double circle_x = cfg_.r2 + cfg_.r1 * theta_cos;
            const double circle_y = cfg_.r1 * theta_sin;

            for (double phi = 0.0; phi < two_pi; phi += cfg_.phi_step) {
                const double phi_sin = std::sin(phi);
                const double phi_cos = std::cos(phi);

                const double x = circle_x * phi_cos;
                const double y = circle_x * phi_sin;
                const double z = circle_y;

                const double x1 = x;
                const double y1 = y * cos_a - z * sin_a;
                const double z1 = y * sin_a + z * cos_a;

                const double x2 = x1 * cos_b - y1 * sin_b;
                const double y2 = x1 * sin_b + y1 * cos_b;
                const double z2 = z1;

                const double ooz = 1.0 / (z2 + cfg_.k2);
                const int xp = static_cast<int>(cfg_.width / 2.0 + cfg_.k1 * ooz * x2);
                const int yp = static_cast<int>(cfg_.height / 2.0 - (cfg_.k1 * 0.5) * ooz * y2);

                const double luminance = phi_cos * theta_cos * sin_b - cos_a * theta_cos * phi_sin -
                                         sin_a * theta_sin + cos_b * (cos_a * theta_sin - theta_cos * sin_a * phi_sin);

                if (luminance > 0.0 && xp >= 0 && xp < cfg_.width && yp >= 0 && yp < cfg_.height) {
                    const int idx = xp + cfg_.width * yp;
                    if (ooz > zbuffer[static_cast<size_t>(idx)]) {
                        zbuffer[static_cast<size_t>(idx)] = ooz;
                        int shade = static_cast<int>(luminance * 8.0);
                        if (shade < 0) shade = 0;
                        if (shade >= static_cast<int>(cfg_.shading.size())) shade = static_cast<int>(cfg_.shading.size()) - 1;
                        buffer[static_cast<size_t>(idx)] = cfg_.shading[static_cast<size_t>(shade)];
                    }
                }
            }
        }

        std::string out;
        out.reserve(static_cast<size_t>(cfg_.width * cfg_.height + cfg_.height));
        for (int y = 0; y < cfg_.height; ++y) {
            for (int x = 0; x < cfg_.width; ++x) out.push_back(buffer[static_cast<size_t>(x + y * cfg_.width)]);
            out.push_back('\n');
        }
        return out;
    }

    void step_angles() {
        a_ += cfg_.a_step;
        b_ += cfg_.b_step;
    }

    Config cfg_;
    double a_ = 0.0;
    double b_ = 0.0;
};

static Config parse_args(int argc, char** argv) {
    Config cfg;
    for (int i = 1; i < argc; ++i) {
        const std::string arg = argv[i];
        auto next = [&](double& target) {
            if (i + 1 < argc) target = std::atof(argv[++i]);
        };
        auto next_int = [&](int& target) {
            if (i + 1 < argc) target = std::atoi(argv[++i]);
        };

        if (arg == "--benchmark") cfg.benchmark = true;
        else if (arg == "--width") next_int(cfg.width);
        else if (arg == "--height") next_int(cfg.height);
        else if (arg == "--r1") next(cfg.r1);
        else if (arg == "--r2") next(cfg.r2);
        else if (arg == "--k1") next(cfg.k1);
        else if (arg == "--k2") next(cfg.k2);
        else if (arg == "--a-step") next(cfg.a_step);
        else if (arg == "--b-step") next(cfg.b_step);
        else if (arg == "--theta-step") next(cfg.theta_step);
        else if (arg == "--phi-step") next(cfg.phi_step);
        else if (arg == "--frames") next_int(cfg.frames);
        else if (arg == "--shading" && i + 1 < argc) cfg.shading = argv[++i];
    }
    return cfg;
}

int main(int argc, char** argv) {
    Config cfg = parse_args(argc, argv);
    Renderer renderer(cfg);
    if (cfg.benchmark) {
        renderer.benchmark();
        return 0;
    }
    renderer.animate();
    return 0;
}
