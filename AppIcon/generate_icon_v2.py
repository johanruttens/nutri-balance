#!/usr/bin/env python3
"""
NutriBalance App Icon Generator v2
Creates a refined 1024x1024 PNG icon for the App Store
Design Philosophy: Balanced Vitality - Refined Edition
"""

import math
from PIL import Image, ImageDraw, ImageFilter

# Canvas dimensions
SIZE = 1024
CENTER = SIZE // 2

# Color palette - Balanced Vitality
TEAL_PRIMARY = (16, 185, 129)      # #10B981 - Fresh, vibrant teal
TEAL_DARK = (6, 78, 59)            # #064E3B - Deep forest teal
TEAL_MID = (5, 150, 105)           # #059669 - Medium teal
WHITE = (255, 255, 255)
SOFT_WHITE = (236, 253, 245)       # #ECFDF5 - Tinted white

def create_smooth_gradient(size):
    """Create a smooth radial gradient background."""
    img = Image.new('RGB', (size, size), TEAL_PRIMARY)
    pixels = img.load()

    center = size // 2
    outer_color = (5, 150, 105)    # Darker edge
    inner_color = (52, 211, 153)   # Lighter center

    for y in range(size):
        for x in range(size):
            dist = math.sqrt((x - center) ** 2 + (y - center) ** 2)
            max_dist = center * 1.2
            ratio = min(dist / max_dist, 1.0)

            # Ease-out function for smoother gradient
            ratio = 1 - (1 - ratio) ** 2

            r = int(inner_color[0] + (outer_color[0] - inner_color[0]) * ratio)
            g = int(inner_color[1] + (outer_color[1] - inner_color[1]) * ratio)
            b = int(inner_color[2] + (outer_color[2] - inner_color[2]) * ratio)

            pixels[x, y] = (r, g, b)

    return img

def draw_smooth_arc(draw, center, radius, start_angle, end_angle, width, color):
    """Draw a smooth anti-aliased arc."""
    points = []
    for angle in range(int(start_angle * 10), int(end_angle * 10) + 1):
        rad = math.radians(angle / 10)
        x = center[0] + radius * math.cos(rad)
        y = center[1] + radius * math.sin(rad)
        points.append((x, y))

    if len(points) > 1:
        draw.line(points, fill=color, width=width, joint="curve")

def create_icon():
    """Generate the refined NutriBalance app icon."""

    # Create gradient background
    img = create_smooth_gradient(SIZE)
    draw = ImageDraw.Draw(img)

    # === Central White Circle ===
    inner_radius = 340
    # Draw slightly larger circle for anti-aliasing effect
    for r in range(inner_radius + 3, inner_radius - 1, -1):
        alpha = 255 if r <= inner_radius else int(255 * (inner_radius + 3 - r) / 3)
        draw.ellipse(
            [CENTER - r, CENTER - r, CENTER + r, CENTER + r],
            fill=WHITE
        )

    # === Stylized Leaf-Scale Symbol ===

    # Central stem
    stem_width = 28
    stem_top = CENTER - 200
    stem_bottom = CENTER + 80

    draw.rounded_rectangle(
        [CENTER - stem_width//2, stem_top,
         CENTER + stem_width//2, stem_bottom],
        radius=stem_width//2,
        fill=TEAL_DARK
    )

    # Top circle (crown)
    crown_radius = 32
    draw.ellipse(
        [CENTER - crown_radius, stem_top - crown_radius - 10,
         CENTER + crown_radius, stem_top + crown_radius - 10],
        fill=TEAL_DARK
    )

    # === Balanced Curved Arms (Leaf/Scale Hybrid) ===
    arm_width = 26

    # Left curved arm - elegant S-curve
    left_arm = []
    for t in range(101):
        progress = t / 100
        # Quadratic bezier-like curve
        x = CENTER - 30 - 130 * math.sin(progress * math.pi * 0.6)
        y = CENTER - 40 + 150 * progress
        left_arm.append((x, y))

    draw.line(left_arm, fill=TEAL_DARK, width=arm_width, joint="curve")

    # Right curved arm (mirrored)
    right_arm = []
    for t in range(101):
        progress = t / 100
        x = CENTER + 30 + 130 * math.sin(progress * math.pi * 0.6)
        y = CENTER - 40 + 150 * progress
        right_arm.append((x, y))

    draw.line(right_arm, fill=TEAL_DARK, width=arm_width, joint="curve")

    # === Decorative End Circles (like seeds/drops) ===
    end_radius = 24

    # Left end
    left_end_x = CENTER - 145
    left_end_y = CENTER + 108
    draw.ellipse(
        [left_end_x - end_radius, left_end_y - end_radius,
         left_end_x + end_radius, left_end_y + end_radius],
        fill=TEAL_PRIMARY
    )

    # Right end
    right_end_x = CENTER + 145
    right_end_y = CENTER + 108
    draw.ellipse(
        [right_end_x - end_radius, right_end_y - end_radius,
         right_end_x + end_radius, right_end_y + end_radius],
        fill=TEAL_PRIMARY
    )

    # === Inner Accent Curves (subtle leaf veins) ===
    accent_width = 10

    # Left inner curve
    left_accent = []
    for t in range(61):
        progress = t / 60
        x = CENTER - 50 - 50 * math.sin(progress * math.pi * 0.4)
        y = CENTER + 10 + 60 * progress
        left_accent.append((x, y))

    draw.line(left_accent, fill=SOFT_WHITE, width=accent_width, joint="curve")

    # Right inner curve
    right_accent = []
    for t in range(61):
        progress = t / 60
        x = CENTER + 50 + 50 * math.sin(progress * math.pi * 0.4)
        y = CENTER + 10 + 60 * progress
        right_accent.append((x, y))

    draw.line(right_accent, fill=SOFT_WHITE, width=accent_width, joint="curve")

    # === Outer Decorative Ring Segments ===
    ring_radius = 385
    ring_width = 14

    # Four elegant arc segments
    segments = [
        (25, 65),    # Top-right
        (115, 155),  # Bottom-right
        (205, 245),  # Bottom-left
        (295, 335),  # Top-left
    ]

    for start, end in segments:
        arc_points = []
        for angle in range(start * 2, end * 2 + 1):
            rad = math.radians(angle / 2)
            x = CENTER + ring_radius * math.cos(rad)
            y = CENTER + ring_radius * math.sin(rad)
            arc_points.append((x, y))

        if len(arc_points) > 1:
            draw.line(arc_points, fill=WHITE, width=ring_width, joint="curve")

    return img

def main():
    print("Generating NutriBalance App Icon v2...")
    print("Design Philosophy: Balanced Vitality - Refined Edition")
    print("")

    icon = create_icon()

    # Save the main icon
    output_path = "/Users/johanruttens/Repositories/nutri-balance/AppIcon/NutriBalance-AppIcon-1024.png"
    icon.save(output_path, "PNG", quality=100)
    print(f"Icon saved to: {output_path}")

    # Create iOS app icon sizes
    ios_sizes = [
        (1024, "AppStore"),
        (180, "iPhone-60@3x"),
        (120, "iPhone-60@2x"),
        (167, "iPad-Pro-83.5@2x"),
        (152, "iPad-76@2x"),
        (76, "iPad-76@1x"),
        (40, "Spotlight-40@1x"),
        (80, "Spotlight-40@2x"),
        (120, "Spotlight-40@3x"),
        (29, "Settings-29@1x"),
        (58, "Settings-29@2x"),
        (87, "Settings-29@3x"),
    ]

    for size, name in ios_sizes:
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        preview_path = f"/Users/johanruttens/Repositories/nutri-balance/AppIcon/Icon-{name}.png"
        resized.save(preview_path, "PNG")
        print(f"Created: Icon-{name}.png ({size}x{size})")

    print("")
    print("App icon generation complete!")
    print("")
    print("To add to Xcode:")
    print("1. Open Assets.xcassets in Xcode")
    print("2. Select AppIcon")
    print("3. Drag the generated icons to their respective slots")

if __name__ == "__main__":
    main()
