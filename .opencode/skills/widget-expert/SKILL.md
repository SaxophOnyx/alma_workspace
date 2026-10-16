---
name: widget-expert
description: Flutter widget and theming rules for user-visible UI. LOAD ONLY WHEN creating new custom widgets or themes from scratch, or heavily refactoring existing widget architecture, styling, or theming. DO NOT LOAD for minor UI tweaks, padding adjustments, text changes, or small bug fixes (rely on existing code context instead).
---

## Flutter Custom Theming & Widget Guidelines

### 1. Core Directives
Priority: These rules override generic widget recommendations.
- Zero Hardcoding: Do not use raw hex colors, raw font sizes, magic numbers, raw animation timings, or user-visible string literals inside widget bodies.
- Semantic Over Raw: Use `context.appColors`, `context.appTexts`, `AppDimens`, and `AppMotions`.
- Design-driven: Use MCP/design references for concrete visual appearance and motion, but implement them through semantic tokens and existing App widgets. Do not hardcode raw design values inside widgets.
- Stateless by default: Use `StatefulWidget` only for transient view state such as animation, focus, hover, press, drag, or expansion.
- Subtle Motion Defaults: When design does not specify motion, subtle implicit animations or built-in framework feedback are allowed for simple state changes such as pressed, enabled/disabled, expanded, or revealed. Use `AppMotions` tokens and existing motion patterns where available. Do not create complex animations or hardcode one-off durations/curves.
- No business state in widgets: Do not store business, form, selection, or shared state inside widgets.
- Minimal API: Expose only necessary inputs. Do not invent styles, states, or parameters not required by the current design or existing usage.
- No navigation in widgets: Widgets do not navigate. Provide a void callback to trigger the navigation.
- Strict Disposal: Every `AnimationController`, `FocusNode`, `ScrollController`, `StreamSubscription`, or `Timer` created in `initState` must be disposed in `dispose()`.
- Safe Async Context: Never use a captured `BuildContext` after an `await` without checking `mounted` (in `State`) or capturing the relevant state (e.g., `ScaffoldMessengerState`) beforehand.
- Simple Implementation (Anti-Overengineering):
    - Implement exactly what the current design requires. Do not add parameters, callbacks, controllers, style variants, or animations for hypothetical future use.
    - Trust the framework widget. Before creating a custom property, wrapper class, or resolver, check whether the underlying widget (e.g., `ElevatedButton`, `TextField`) already exposes the needed styling via its constructor or `style` parameter. Map your style enum directly to those parameters. Do not introduce intermediate style-data classes or configuration objects.
    - One controller per concern. A text field needs one `TextEditingController`. Do not create additional controllers for focus, validation, or formatting unless the design explicitly requires independent control.
    - No single-variant enums. Do not create `App<Widget>Style` with only one value. Introduce the enum when a second variant actually exists in the design.
    - No abstraction for one call-site. If a widget is used once and is feature-specific, keep it as a private class in the feature. Do not extract it to `shared_ui` or wrap it in `App*`.
    - "Bullet-proof" ≠ "handles everything." It means correct for the specified requirements. When requirements are ambiguous, implement the minimal interpretation and flag the ambiguity. Do not guess by adding more code.

### 2. Reuse Before Creation
Before creating a new widget, search in this order:
1. `shared_ui` — Look for an existing `App*` widget that covers the visual contract and interaction model. If it exists, use it. If it needs a small generic change (e.g., a new style-enum variant), extend it there.
2. Current feature's `src/widgets/` — Check whether the feature already contains a widget that matches. Reuse or extend it.
3. Sibling features — Do NOT import from another feature package. If a sibling feature has a widget that would fit, promote it to `shared_ui` first (generalise its API, remove feature-specific coupling), then consume it from `shared_ui`.

When `shared_ui` has no match:
- Obvious primitives (button, switch, card, text field, chip, badge, divider, spinner) → create directly in `shared_ui` as `App<Name>`.
- Anything else → create in the feature. Flag it: "Placed in `<feature>`; say the word to promote to `shared_ui`."

Decision checklist:
- Same visual contract + same interaction → reuse.
- Same visual contract, minor variant (color, size, label) → add a style-enum value or parameter to the existing widget.
- Similar but materially different interaction model → new widget, placed per §5 location rules.
- Near-duplicate with only cosmetic differences → merge into one widget with a style enum. Do not create `AppFooV2`.

### 3. Theming & Styling
- Colors: Use `context.appColors.<semanticName>`. Do not use `AppColors` directly in widgets.
- Typography: Use `context.appTexts.<semanticName>`. Do not use `AppFonts` directly in widgets. Do not wrap `AppText` / `AppRichText` in a fixed-height `SizedBox` or `Container`. Use `ConstrainedBox(minHeight: ...)` if a minimum height is needed.
- Dimensions: Use `AppDimens.<semanticName>` for spacing, sizing, and radii.
- Motion: Use `AppMotions.<semanticName>` for animation durations and curves. Do not hardcode `Duration` or `Curve` values in widgets.
- Strings: Widgets may accept `String` parameters, but callers must pass localized strings via `context.translations.<key>`.
- Theme layering: Semantic values belong in `AppColorsTheme` and `AppTextTheme`, backed by raw `AppColors` and `AppFonts`.

### 4. Widget API
- Accepted inputs: Data models, visible-text strings, callbacks, and styling enums.
- Interactable state: Interactable widgets must include `bool isEnabled`, defaulting to `true`.
- Touch targets: Interactive elements should meet platform minimum hit-area guidelines (48 dp Material / 44 pt HIG) unless the design explicitly specifies a smaller target.
- Rejected inputs (from callers): Raw `Color`, raw `TextStyle`, raw spacing/sizing/radius values, raw animation timing values, and framework styling properties.
    - Internal implementation note: This does not mean the widget's internal `build()` cannot use framework styling APIs (e.g., `ElevatedButton.styleFrom`, `InputDecoration`). The prohibition is on callers passing raw styles in.
- Styling enums: Use `App<WidgetName>Style` naming, e.g., `AppButtonStyle.primary`.
- Parameter minimalism: Do not copy underlying widget constructors or add rarely-used parameters.
- Media rendering: Always use `AppImage.asset()` / `AppImage.network()` for content images and `AppIcon.asset()` for UI icons. Do not use raw `Image.asset`, `SvgPicture`, or `Icon` directly.
- Text rendering: Always use `AppText` / `AppRichText`. Do not use raw `Text` or `RichText` directly.

### 5. Widget Architecture
- Location: Shared widgets belong in `shared_ui`. Feature-specific widgets belong in their feature package.
- Decomposition: Keep widgets small and single-purpose; >~150 lines is a warning sign, not a strict goal.
- No widget helper functions: Do not use helper methods/functions that return `Widget`. Extract dedicated widget classes.
- Wrapping: Wrap meaningful components in `App<WidgetName>`. Do not wrap layout primitives such as `Padding`, `SizedBox`, `Column`, `Row`, `Stack`.
- Internal implementation: Prefer standard Material/Cupertino widgets. Do not reinvent framework behavior unless required.
- Styling ownership: Widgets resolve their visual styling by mapping their style enum directly to the underlying framework widget's native style parameters (e.g., `ElevatedButton.styleFrom`, `TextField.decoration`, `Card.shape`). Do not create intermediate style-resolution layers, configuration objects, or custom `BoxDecoration`/`TextStyle` builders unless the framework widget's API is genuinely insufficient. Callers do not control appearance.
- Accessibility ownership: `App*` widgets own their `Semantics`. Do not wrap `App*` widgets in `Semantics` at call sites. Pass `semanticLabel` only when visual content is ambiguous (e.g., icon-only button).

### 6. Common Mistakes
- `Text("Submit")` → use `AppText` with localized string.
- `AppColors.red` in widget code → use `context.appColors.error`.
- Semantic value inside raw theme → move it to `AppColorsTheme` / `AppTextTheme`.
- `Color? backgroundColor` or `double elevation` → expose `AppCardStyle style`.
- `AppSizedBox(height: 8)` → use `SizedBox(height: AppDimens.smallGap)`.
- `Widget _buildTitle()` helper → extract `TitleWidget`.
- Hardcoded `Duration` / `Curve` → use an `AppMotions` token.
- Instant show/hide where design or existing pattern has a transition → use an existing/implicit animation.
- `Image.asset("...")` / `SvgPicture.asset("...")` → use `AppImage.asset(AppImages.myImage)` or `AppIcon.asset(AppIcons.myIcon)`.
- `Semantics` wrapping `AppButton` → remove, A11y is owned by the component.
- `Opacity(opacity: 0)` or `Visibility(visible: false)` to hide → use conditional rendering (`if (show) Widget()`). Use `AnimatedSize`/`AnimatedOpacity` only when the design specifies a transition.
- `SizedBox(height: 40, child: AppText(...))` → use `ConstrainedBox(constraints: BoxConstraints(minHeight: 40))` so text can scale.
- `AppTextField` with multiple `TextEditingController`s (text, focus, validation) → use one controller, passed in or created in `initState`.
- Custom `AppButtonStyleData` class + `resolveStyle()` method → map the enum directly: `style: switch(style) { .primary => ElevatedButton.styleFrom(...), ... }`.

### 7. Testing & Auditing (Widget Tests)
- Don't write UI tests unless explicitly asked.

### 8. Post-Implementation
- Run `dart fix --apply` on changed files.
