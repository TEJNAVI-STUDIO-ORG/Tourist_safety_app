---
name: Guardian Pulse
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#45464d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#9d4300'
  on-secondary: '#ffffff'
  secondary-container: '#fd761a'
  on-secondary-container: '#5c2400'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#410002'
  on-tertiary-container: '#f63a35'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#ffdbca'
  secondary-fixed-dim: '#ffb690'
  on-secondary-fixed: '#341100'
  on-secondary-fixed-variant: '#783200'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#93000b'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-margin: 20px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

This design system is engineered for high-stress environments where clarity and reliability are paramount. The brand personality is **Authoritative, Calm, and Vigilant**. It balances the professional stability of a government agency with the modern responsiveness of a high-tech safety tool.

The visual style follows a **Corporate / Modern** aesthetic with a heavy emphasis on **Utility-First** construction. We prioritize information density and legibility over decorative elements. The interface uses generous whitespace to reduce cognitive load during emergencies, ensuring that users can navigate the app instinctively when every second counts.

## Colors

The color palette is strategically split between "Stable" and "Active" states. 

- **Primary Deep Blue (#0F172A):** Used for navigation, headers, and primary actions to instill a sense of trust and institutional reliability.
- **Vibrant Orange (#F97316):** Used for "Caution" states, active alerts, and non-critical safety notifications.
- **SOS Red (#DC2626):** Reserved exclusively for the most critical actions: emergency calls, panic buttons, and immediate danger alerts.
- **Background & Neutrals:** A range of cool grays (Slate) provides a clean, breathable canvas that makes the primary and alert colors pop.

## Typography

This design system utilizes **Inter** for all text elements. Inter’s tall x-height and clear letterforms ensure maximum legibility at small sizes and on low-quality mobile screens. 

- **Headlines:** Use heavy weights (600-700) to establish a clear hierarchy.
- **Body:** Kept at a comfortable 16px-18px for readability while walking or in motion.
- **Utility Labels:** Caps and semi-bold weights are used for status indicators and navigation items to distinguish them from content.

## Layout & Spacing

The design system employs a **Fluid Grid** model optimized for mobile devices. We use a 4px baseline grid to maintain rigorous alignment.

- **Margins:** Standard 20px side margins ensure content does not hug the edge of the screen, providing a "safe zone" for thumb interaction.
- **Stacking:** Vertical spacing follows a strictly linear progression (8px, 16px, 24px) to group related safety information logically.
- **Touch Targets:** All interactive elements must maintain a minimum height of 48px to ensure they are easily tappable during high-stress situations.

## Elevation & Depth

To maintain the "Utility-First" feel, depth is used sparingly to indicate interactivity rather than decoration.

- **Tonal Layers:** The primary dashboard uses a subtle light-gray background (#F8FAFC), with white (#FFFFFF) "cards" to represent different safety modules.
- **Soft Shadows:** Interactive cards use a very subtle, diffused shadow (0px 4px 12px rgba(15, 23, 42, 0.08)) to appear slightly elevated above the background.
- **Active States:** When an alert is active, the elevation increases slightly, and the shadow takes on a tint of the alert color (Orange or Red) to draw immediate attention.

## Shapes

The shape language for this design system is **Rounded**. This softens the "industrial" feel of a safety app, making it feel approachable and modern rather than clinical.

- **Standard Radius:** 8px (0.5rem) for input fields, buttons, and small components.
- **Large Radius:** 16px (1rem) for dashboard cards and containers.
- **Pill Shapes:** Used exclusively for status chips (e.g., "Safe," "Alert Active") and the main SOS trigger to distinguish them from standard buttons.

## Components

### Buttons
- **Primary:** Solid Deep Blue background with White text. Used for main flows.
- **SOS Button:** A large, floating pill-shaped button in Red (#DC2626) with a haptic ripple effect. It must be accessible from every screen.
- **Secondary:** Transparent background with a 1px Deep Blue border.

### Cards
- **Safety Card:** White background, 16px rounded corners, with a left-accent border color indicating the current status (Green for safe, Orange for warning).

### Inputs
- **Search & Fields:** Light gray fill (#F1F5F9) with no border until focused. Upon focus, use a 2px Deep Blue border.

### Chips & Status Indicators
- Use high-contrast backgrounds with white text. Icons should be placed to the left of the label for instant recognition (e.g., a shield for "Safe," a lightning bolt for "Alert").

### Navigation
- A bottom navigation bar with clear, bold icons. Labels are required under icons to ensure there is no ambiguity in functionality.

### Progress & Alerts
- **Alert Banner:** A full-width bar at the top of the screen in Orange or Red, pinning critical information until dismissed or resolved.