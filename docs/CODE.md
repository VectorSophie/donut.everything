# donut.everything — code.md

This document explains the structure of the original donut.c implementation.

---

## Global Variables

float A = 0, B = 0;

Rotation angles.

---

## Buffers

float z[1760];  
char b[1760];

1760 = 80 × 22 screen grid.

z → depth buffer  
b → output buffer  

---

## Clear Buffers

memset(b, 32, 1760);  
memset(z, 0, 7040);

Fill output with spaces and reset depth buffer.

---

## Nested Angle Loops

for (j = 0; j < 6.28; j += 0.07)  
for (i = 0; i < 6.28; i += 0.02)

j → φ  
i → θ  

6.28 ≈ 2π

---

## 3D Calculation and Rotation

Core torus equation, rotation, and projection are algebraically compressed
into compact expressions to reduce line count.

---

## Projection

int x = 40 + 30 * D * (...);  
int y = 12 + 15 * D * (...);

40,12 → screen center  
30,15 → scaling factors  
D → depth scaling  

---

## Luminance

int N = 8 * (...)

Mapped to ramp:

".,-~:;=!*#$@"

---

## Z-Buffer Test

if (inside bounds && D > z[o]) {
    z[o] = D;
    b[o] = ramp[N > 0 ? N : 0];
}

Ensures correct depth rendering.

---

## Frame Output

printf("\\x1b[H");

Moves cursor to top-left without clearing screen.

---

## Angle Increment

A += 0.04;  
B += 0.02;

Creates compound rotation motion.

---

## Porting Guidance

When porting:

- Expand math for clarity  
- Preserve operation order  
- Maintain identical ramp  
- Keep baseline version reproducible  

Any deviation should be explicitly versioned.