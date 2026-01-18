#!/usr/bin/env python3
"""
NutriBalance App Icon Generator
Creates a 1024x1024 PNG icon for the App Store
Design Philosophy: Balanced Vitality
"""

import math
from PIL import Image, ImageDraw

# Canvas dimensions
SIZE = 1024
CENTER = SIZE // 2

# Color palette - Balanced Vitality
TEAL_PRIMARY = (16, 185, 129)      # #10B981 - Fresh, vibrant teal
TEAL_DARK = (6, 95, 70)            # #065F46 - Deep forest teal
TEAL_LIGHT = (167, 243, 208)       # #A7F3D0 - Soft mint highlight
WHITE = (255, 255, 255)
GRADIENT_TOP = (52, 211, 153)      # #34D399 - Lighter teal for gradient

def create_gradient_background(size):
    """Create a smooth radial gradient background."""
    img = Image.new('RGB', (size, size), WHITE)
    pixels = img.load()

    center = size // 2
    max_dist = math.sqrt(2) * center

    for y in range(size):
        for x in range(size):
            # Calculate distance from center
            dist = math.sqrt((x - center) ** 2 + (y - center) ** 2)
            ratio = min(dist / (center * 0.9), 1.0)

            # Interpolate between colors
            r = int(GRADIENT_TOP[0] + (TEAL_PRIMARY[0] - GRADIENT_TOP[0]) * ratio)
            g = int(GRADIENT_TOP[1] + (TEAL_PRIMARY[1] - GRADIENT_TOP[1]) * ratio)
            b = int(GRADIENT_TOP[2] + (TEAL_PRIMARY[2] - GRADIENT_TOP[2]) * ratio)

            pixels[x, y] = (r, g, b)

    return img

def draw_leaf_balance(draw, center_x, center_y, scale):
    """Draw a stylized leaf with balance motif."""

    # Main leaf body - elegant teardrop shape
    leaf_points = []
    for angle in range(0, 360, 2):
        rad = math.radians(angle)
        # Cardioid-like shape for organic leaf
        r = scale * (1 - 0.5 * math.sin(rad)) * (0.8 + 0.2 * math.cos(2 * rad))

        # Rotate 45 degrees for diagonal elegance
        x = center_x + r * math.cos(rad - math.pi/4)
        y = center_y + r * math.sin(rad - math.pi/4)
        leaf_points.append((x, y))

    return leaf_points

def draw_water_drop(draw, cx, cy, radius, color):
    """Draw a stylized water droplet."""
    points = []

    # Create teardrop shape
    for i in range(100):
        t = i / 100 * 2 * math.pi
        # Parametric teardrop
        x = cx + radius * math.sin(t)
        y = cy + radius * (1 - math.cos(t)) * 0.6 - radius * 0.3
        points.append((x, y))

    draw.polygon(points, fill=color)

def create_icon():
    """Generate the NutriBalance app icon."""

    # Create gradient background
    img = create_gradient_background(SIZE)
    draw = ImageDraw.Draw(img)

    # Draw outer circle (app icon boundary - iOS style)
    # Using rounded square approximation for iOS icon shape
    margin = 0

    # === Central Element: Stylized Leaf-Drop Fusion ===

    # Draw main decorative element - a balanced composition
    # Central white circle as base
    inner_radius = 320
    draw.ellipse(
        [CENTER - inner_radius, CENTER - inner_radius,
         CENTER + inner_radius, CENTER + inner_radius],
        fill=WHITE
    )

    # Draw stylized leaf/balance symbol
    leaf_scale = 200

    # Left leaf element
    left_leaf = []
    for angle in range(-90, 90, 2):
        rad = math.radians(angle)
        r = leaf_scale * (0.7 + 0.3 * math.cos(rad * 2))
        x = CENTER - 80 + r * math.cos(rad) * 0.5
        y = CENTER + r * math.sin(rad)
        left_leaf.append((x, y))

    # Right leaf element (mirrored)
    right_leaf = []
    for angle in range(90, 270, 2):
        rad = math.radians(angle)
        r = leaf_scale * (0.7 + 0.3 * math.cos(rad * 2))
        x = CENTER + 80 + r * math.cos(rad) * 0.5
        y = CENTER + r * math.sin(rad)
        right_leaf.append((x, y))

    # Draw elegant curved lines suggesting balance
    line_width = 24

    # Central vertical stem
    stem_top = CENTER - 180
    stem_bottom = CENTER + 140

    # Draw curved stem with gradient effect
    for i in range(5):
        offset = i * 4
        alpha = 255 - i * 30
        stem_color = TEAL_DARK
        draw.line(
            [(CENTER - offset//2, stem_top), (CENTER - offset//2, stem_bottom)],
            fill=stem_color, width=max(1, line_width - i * 4)
        )

    # Draw left leaf curve
    leaf_curve_points = []
    for t in range(0, 101, 2):
        progress = t / 100
        # Bezier-like curve
        x = CENTER - 20 - 140 * math.sin(progress * math.pi * 0.7)
        y = CENTER - 60 + 180 * progress - 40 * math.sin(progress * math.pi)
        leaf_curve_points.append((x, y))

    if len(leaf_curve_points) > 1:
        draw.line(leaf_curve_points, fill=TEAL_DARK, width=line_width, joint="curve")

    # Draw right leaf curve (mirrored)
    right_curve_points = []
    for t in range(0, 101, 2):
        progress = t / 100
        x = CENTER + 20 + 140 * math.sin(progress * math.pi * 0.7)
        y = CENTER - 60 + 180 * progress - 40 * math.sin(progress * math.pi)
        right_curve_points.append((x, y))

    if len(right_curve_points) > 1:
        draw.line(right_curve_points, fill=TEAL_DARK, width=line_width, joint="curve")

    # Add small decorative circles at leaf tips (like water drops or seeds)
    dot_radius = 20

    # Left dot
    draw.ellipse(
        [CENTER - 155 - dot_radius, CENTER + 95 - dot_radius,
         CENTER - 155 + dot_radius, CENTER + 95 + dot_radius],
        fill=TEAL_PRIMARY
    )

    # Right dot
    draw.ellipse(
        [CENTER + 155 - dot_radius, CENTER + 95 - dot_radius,
         CENTER + 155 + dot_radius, CENTER + 95 + dot_radius],
        fill=TEAL_PRIMARY
    )

    # Top dot (crown of the balance)
    top_dot_radius = 24
    draw.ellipse(
        [CENTER - top_dot_radius, stem_top - 20 - top_dot_radius,
         CENTER + top_dot_radius, stem_top - 20 + top_dot_radius],
        fill=TEAL_DARK
    )

    # Add subtle inner details - small curved accents
    accent_width = 8

    # Left inner accent
    left_accent = []
    for t in range(0, 51, 2):
        progress = t / 50
        x = CENTER - 40 - 60 * math.sin(progress * math.pi * 0.5)
        y = CENTER + 20 + 60 * progress
        left_accent.append((x, y))

    if len(left_accent) > 1:
        draw.line(left_accent, fill=TEAL_LIGHT, width=accent_width)

    # Right inner accent
    right_accent = []
    for t in range(0, 51, 2):
        progress = t / 50
        x = CENTER + 40 + 60 * math.sin(progress * math.pi * 0.5)
        y = CENTER + 20 + 60 * progress
        right_accent.append((x, y))

    if len(right_accent) > 1:
        draw.line(right_accent, fill=TEAL_LIGHT, width=accent_width)

    # Add outer ring accent
    ring_width = 12
    outer_ring_radius = 360

    # Draw partial ring arcs for sophistication
    for start_angle, end_angle in [(30, 60), (120, 150), (210, 240), (300, 330)]:
        arc_points = []
        for angle in range(start_angle, end_angle + 1, 2):
            rad = math.radians(angle)
            x = CENTER + outer_ring_radius * math.cos(rad)
            y = CENTER + outer_ring_radius * math.sin(rad)
            arc_points.append((x, y))

        if len(arc_points) > 1:
            draw.line(arc_points, fill=WHITE, width=ring_width)

    return img

def main():
    print("Generating NutriBalance App Icon...")
    print("Design Philosophy: Balanced Vitality")
    print("")

    icon = create_icon()

    # Save the icon
    output_path = "/Users/johanruttens/Repositories/nutri-balance/AppIcon/NutriBalance-AppIcon-1024.png"
    icon.save(output_path, "PNG", quality=100)
    print(f"Icon saved to: {output_path}")

    # Also create smaller preview sizes
    sizes = [512, 180, 120, 60]
    for size in sizes:
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        preview_path = f"/Users/johanruttens/Repositories/nutri-balance/AppIcon/NutriBalance-AppIcon-{size}.png"
        resized.save(preview_path, "PNG")
        print(f"Preview saved: {preview_path}")

    print("")
    print("App icon generation complete!")

if __name__ == "__main__":
    main()
