# NestShift OS — Flutter App: Complete Kilo-Code Prompt

---

## MISSION STATEMENT

Build **NestShift** — a privacy-first, fully local smart home Flutter app that pairs
with a Raspberry Pi 3 running the NestShift OS backend (FastAPI on port 8000, Brain on
port 8001). The app must be jaw-dropping in design, rival award-winning Dribbble shots
and Awwwards-level interfaces, and be completely functional. It runs in two modes:

- **Demo Mode** — no real hardware. Every screen, every interaction, every animation
  works with realistic mock data. Soil readings pulse, light toggles glow, energy charts
  animate. Nothing is greyed out. Used during onboarding and before pairing.
- **Live Mode** — paired to a real Pi via QR code. All demo data replaced by real
  WebSocket + REST API calls. Same UI, real data.

---

## DESIGN PHILOSOPHY

> "A good smart home app should feel like the home itself — warm, responsive, alive."

### Aesthetic: Dark Neumorphic Ambient

Inspired by the reference images provided and Dribbble's best smart home shots (2024–2025).
NOT flat material design. NOT basic dark mode. This is **dark neumorphic ambient** —
a fusion of:

- **Neumorphism** — surfaces that extrude from the background with dual soft shadows
  (a bright shadow top-left, a dark shadow bottom-right), giving tactile depth.
- **Glassmorphism accents** — frosted glass cards floating over blurred ambient
  background layers, used sparingly on modals and overlays.
- **Ambient glow** — every active device casts a soft coloured halo onto its card.
  Lights glow warm amber. Sensors glow teal. The relay glows electric blue.
  Offline devices are desaturated with no glow.
- **Micro-animations everywhere** — power buttons spring when pressed, sliders
  magnetise to values, cards breathe with a subtle pulse when active.

### Colour Palette

```
Surface base:      #1A1A2E   (deep navy-charcoal — NOT pure black)
Surface raised:    #1E1E35   (slightly lighter layer, cards)
Surface overlay:   #242440   (modals, sheets)
Accent primary:    #6C63FF   (electric indigo — brain/AI colour)
Accent warm:       #FFA94D   (amber — lights on)
Accent teal:       #00D9C0   (teal — sensors active)
Accent red:        #FF6B6B   (alerts, offline)
Accent green:      #51CF66   (online, success)
Text primary:      #EAEAF2
Text secondary:    #8888AA
Shadow light:      rgba(255,255,255,0.07)  (neumorphic highlight)
Shadow dark:       rgba(0,0,0,0.45)         (neumorphic depth)
```

### Typography

Use `google_fonts` with **Space Grotesk** as the primary typeface.
- H1 (screen titles): 28sp, weight 700, letter-spacing -0.5
- H2 (section headers): 20sp, weight 600
- H3 (card titles): 16sp, weight 600
- Body: 14sp, weight 400
- Caption: 12sp, weight 400, text secondary colour
- Monospace (IP addresses, entity IDs): `JetBrains Mono` 12sp

### Component Language

Every interactive element uses a custom `NestCard` widget:
```
NestCard(
  depth: 8,          // neumorphic extrusion
  glow: Color?,      // ambient glow colour when active
  glowIntensity: double,  // 0.0–1.0
  child: ...
)
```

Internally `NestCard` renders:
```dart
BoxDecoration(
  color: SurfaceRaised,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(color: ShadowLight, blurRadius: depth * 2,
              offset: Offset(-depth * 0.6, -depth * 0.6)),
    BoxShadow(color: ShadowDark, blurRadius: depth * 2,
              offset: Offset(depth * 0.6, depth * 0.6)),
    if (glow != null)
      BoxShadow(color: glow.withOpacity(glowIntensity * 0.4),
                blurRadius: 24, spreadRadius: 2),
  ]
)
```

Power buttons use `NestToggleButton`:
- OFF state: deeply embossed (inset shadow = pressed into surface)
- ON state: raised with colour glow halo
- Transition: 300ms spring curve (`Curves.elasticOut`)

Sliders use `NestSlider`:
- Track: neumorphic inset groove
- Thumb: raised circular knob with glow in accent colour
- Fills with gradient as value increases

---

## PROJECT STRUCTURE

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, theme, routing
├── core/
│   ├── theme/
│   │   ├── app_theme.dart      # Full ThemeData, colour tokens
│   │   ├── nest_colors.dart    # Colour constants
│   │   └── text_styles.dart    # Typography system
│   ├── widgets/
│   │   ├── nest_card.dart      # Neumorphic card
│   │   ├── nest_toggle.dart    # Power toggle button
│   │   ├── nest_slider.dart    # Custom slider
│   │   ├── nest_scaffold.dart  # Base scaffold with ambient bg
│   │   ├── ambient_background.dart  # Animated gradient bg
│   │   ├── status_dot.dart     # Online/offline indicator
│   │   ├── glow_icon.dart      # Icon with ambient glow
│   │   ├── skeleton_loader.dart # Loading shimmer
│   │   └── voice_orb.dart      # Voice input animated orb
│   ├── constants/
│   │   ├── api_endpoints.dart  # All endpoint strings
│   │   └── app_constants.dart
│   └── utils/
│       ├── date_utils.dart
│       └── device_icon_map.dart  # device_type → Icon mapping
├── services/
│   ├── api_service.dart        # All REST calls to /api
│   ├── websocket_service.dart  # WS /ws connection + stream
│   ├── demo_service.dart       # Mock data provider
│   ├── connection_manager.dart # Live vs Demo mode switch
│   └── voice_service.dart      # speech_to_text integration
├── models/
│   ├── device.dart
│   ├── room.dart
│   ├── reading.dart
│   ├── automation.dart
│   ├── schedule.dart
│   ├── scene.dart
│   ├── notification_item.dart
│   ├── event_item.dart
│   ├── ai_command.dart
│   └── hub_status.dart
├── providers/
│   ├── app_provider.dart       # Mode (demo/live), hub IP
│   ├── devices_provider.dart
│   ├── rooms_provider.dart
│   ├── sensors_provider.dart
│   ├── automations_provider.dart
│   ├── notifications_provider.dart
│   ├── ai_provider.dart
│   └── hub_status_provider.dart
├── screens/
│   ├── onboarding/
│   │   ├── splash_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── feature_tour_screen.dart
│   │   ├── mode_select_screen.dart    # Demo vs Live
│   │   └── qr_scan_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── home_header.dart
│   │   │   ├── quick_scenes_bar.dart
│   │   │   ├── active_devices_summary.dart
│   │   │   ├── room_grid.dart
│   │   │   ├── room_card.dart
│   │   │   ├── energy_pulse_card.dart
│   │   │   └── ai_suggestion_banner.dart
│   ├── devices/
│   │   ├── devices_screen.dart
│   │   ├── device_detail_screen.dart
│   │   ├── add_device_screen.dart
│   │   └── widgets/
│   │       ├── device_tile.dart
│   │       ├── device_control_panel.dart
│   │       ├── readings_chart.dart
│   │       └── device_event_log.dart
│   ├── rooms/
│   │   ├── rooms_screen.dart
│   │   ├── room_detail_screen.dart
│   │   └── add_room_screen.dart
│   ├── sensors/
│   │   ├── sensors_screen.dart
│   │   ├── sensor_detail_screen.dart
│   │   └── widgets/
│   │       ├── moisture_gauge.dart
│   │       └── reading_sparkline.dart
│   ├── automations/
│   │   ├── automations_screen.dart
│   │   ├── automation_detail_screen.dart
│   │   └── create_automation_screen.dart
│   ├── scenes/
│   │   └── scenes_screen.dart
│   ├── ai/
│   │   ├── ai_screen.dart
│   │   └── widgets/
│   │       ├── chat_bubble.dart
│   │       ├── insights_panel.dart
│   │       └── command_history.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   ├── hub_settings_screen.dart
│   │   └── about_screen.dart
│   └── nav/
│       └── main_nav.dart       # Bottom nav shell
```

---

## PUBSPEC DEPENDENCIES

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  riverpod: ^2.5.1
  flutter_riverpod: ^2.5.1

  # Navigation
  go_router: ^14.2.7

  # Networking
  dio: ^5.6.0
  web_socket_channel: ^3.0.1

  # UI & Design
  google_fonts: ^6.2.1
  flutter_neumorphic_plus: ^3.3.0   # Neumorphic widgets
  glassmorphism: ^3.0.0              # Glass cards
  lottie: ^3.1.2                     # Lottie animations
  fl_chart: ^0.68.0                  # Charts for energy/readings
  percent_indicator: ^4.2.3          # Circular gauges

  # Device features
  mobile_scanner: ^5.2.3             # QR code scanner
  speech_to_text: ^7.0.0            # Voice input (STT)
  shared_preferences: ^2.3.1        # Persist hub IP, mode

  # Utilities
  intl: ^0.19.0
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.1
  equatable: ^2.0.5
  uuid: ^4.4.2
  timeago: ^3.7.0
  connectivity_plus: ^6.0.3

dev_dependencies:
  build_runner: ^2.4.11
  json_serializable: ^6.8.0
  freezed: ^2.5.2
  flutter_lints: ^4.0.0
```

---

## ONBOARDING FLOW (5 screens)

### 1. `SplashScreen`

Full screen. Dark background. Centre: NestShift logo (nest icon + wordmark) animates in
with a scale + fade over 800ms. Below: pulsing dots. After 2s, auto-navigate to Welcome.

Logo construction:
- Custom painted house silhouette in `#1E1E35` with indigo glow `#6C63FF`
- Wordmark: "NestShift" in Space Grotesk 700, white. "OS" in indigo.
- Tagline below in caption: "Your home. Your data. Your control."

### 2. `WelcomeScreen`

Full-screen ambient background (slow-moving radial gradient, 2 orbs drifting).
Foreground:
- Top 40%: 3D-style illustration (use a Lottie animation of a smart house).
  If Lottie asset unavailable, use a custom `CustomPainter` drawing:
  - A house outline with glowing windows (amber), a wifi signal, and a small
    Raspberry Pi icon in the corner — all in the brand palette.
- Bottom 60%: Glass card with:
  - "Welcome to NestShift" — H1
  - "Privacy-first home automation. No cloud. No subscriptions. Just your Pi." — body
  - Two CTAs:
    - "Try Demo Mode" — secondary ghost button
    - "Connect to Hub" — primary filled button (indigo glow)

### 3. `FeatureTourScreen`

A PageView with 4 feature slides. Each slide:
- Animated Lottie or custom painter illustration (top half)
- Title + description (bottom half)
- Page dots indicator

Slides:
1. **"Total Privacy"** — all data stays on your Pi, zero cloud, illustrated with a
   house inside a shield with a red X over a cloud icon.
2. **"Voice Control"** — illustrated orb listening, waves emanating, "just talk to your home".
3. **"Smart Automations"** — timeline illustration with sensors triggering lights and alerts.
4. **"Live Insights"** — a small chart/gauge panel, "see your home's heartbeat in real-time".

Bottom: "Skip" (text button) + "Next" / "Get Started" (primary button).

### 4. `ModeSelectScreen`

Two large `NestCard` options side by side:
- **Demo Mode**: rocket/play icon in amber glow, "Explore without hardware. Everything
  works. No Pi needed." Subtext: "Great for testing and learning."
- **Live Mode**: wifi/hub icon in teal glow, "Connect to your NestShift Pi via QR code."
  Subtext: "Requires Raspberry Pi 3 with NestShift OS."

Selecting Demo → goes directly to `HomeScreen` with demo data injected.
Selecting Live → goes to `QRScanScreen`.

### 5. `QRScanScreen`

Full camera viewfinder with a custom-painted scanning reticle (indigo corners, animated
scanning line sweeping top-to-bottom).

- Instruction text above: "Point your camera at the NestShift QR code on your Pi."
- QR code generated by Pi encodes: `nestshift://hub?ip=192.168.x.x&id=nestshift_001`
- On decode: parse IP, attempt `GET http://{ip}:8000/status`
  - Success: show green tick animation → "Hub found! NestShift Hub — 12 devices"
    → navigate to HomeScreen in Live mode
  - Fail: show red pulse → "Could not reach hub. Check your network." → retry button
- Manual entry option at bottom: "Enter IP manually" → bottom sheet with IP text field.

---

## NAVIGATION

### Bottom Navigation Bar (`MainNav`)

Custom bottom nav. NOT the default Flutter BottomNavigationBar.
A floating pill-shaped container (neumorphic, 16px border radius on each end) hovering
20px above the bottom edge. 5 items:

```
[Home] [Devices] [AI/Brain] [Automations] [Settings]
```

Selected item: icon grows to 26px, receives ambient glow in accent colour, label fades in.
Unselected: 22px icon, no label, dimmed.

Use `AnimatedContainer` + `AnimatedOpacity` for transitions.
Add haptic feedback on every tab switch (`HapticFeedback.selectionClick()`).

Routes (go_router):
```
/           → HomeScreen
/devices    → DevicesScreen
/devices/:id → DeviceDetailScreen
/rooms/:id  → RoomDetailScreen
/ai         → AiScreen
/automations → AutomationsScreen
/sensors    → SensorsScreen
/scenes     → ScenesScreen
/notifications → NotificationsScreen
/settings   → SettingsScreen
```

---

## SCREEN: HOME (`HomeScreen`)

The centrepiece. Scrollable. Has a persistent header that parallax-shrinks on scroll.

### Header (`HomeHeader`)

Height: 220px (shrinks to 80px on scroll).

```
┌─────────────────────────────────────────┐
│  Good Evening, Alex      [🔔] [status]  │
│                                         │
│  ●  NestShift Hub              LIVE     │
│     192.168.1.42 · 12ms ping            │
│                                         │
│  Temp: 22°C  |  Humidity: 56%           │
│  Energy today: 3.2 kWh                  │
└─────────────────────────────────────────┘
```

- Greeting changes with time of day (Good Morning/Afternoon/Evening/Night).
- Status pill: green "LIVE" or amber "DEMO". Tapping shows connection detail sheet.
- Temp/Humidity: read from `GET /sensors` if any temp sensor online; otherwise "—".
- On scroll, header compresses: name + status pill only visible.

### Quick Scenes Bar (`QuickScenesBar`)

Horizontal scroll row of scene pills. Each pill: icon + label, neumorphic raised,
tapping activates the scene (`POST /scenes/{id}/activate`) with a ripple animation.

```
[🌙 Night] [🚗 Away] [🌅 Morning] [🎬 Movie]  [+]
```

The `+` opens `ScenesScreen` as a modal.

On activation: pill flashes in accent colour, brief haptic, success/failure toast.

### Active Devices Summary Card (`ActiveDevicesSummaryCard`)

A single wide `NestCard` with ambient glow in the dominant device colour.

```
┌────────────────────────────────────────┐
│  ⚡ Active Now                          │
│                                        │
│  🔆 Relay Light    [ON  ●]             │
│  🌱 Soil Sensor    [WET ●]             │
│  ── 2 of 2 devices online ──           │
└────────────────────────────────────────┘
```

Each device row has a compact `NestToggleButton` (only shown for controllable devices).
Toggle calls `POST /devices/{id}/control` with `{"command":"toggle","parameters":{}}`.

In Demo mode: toggle animates and state flips locally.

### Room Grid (`RoomGrid`)

2-column grid of `RoomCard` widgets. Data from `GET /rooms`.

`RoomCard`:
```
┌───────────────────┐
│  🍳               │
│  Kitchen          │
│  2 devices        │
│  1 active  ●      │
│  [→]              │
└───────────────────┘
```

Card background subtly tinted by room's most-active device colour.
Tapping → `RoomDetailScreen`.

### Energy Pulse Card (`EnergyPulseCard`)

A `NestCard` with a live-animating `fl_chart` LineChart.

```
┌─────────────────────────────────────────┐
│  ⚡ Energy Today        15.2 kWh  ↑3%   │
│                                         │
│  [sparkline chart — last 6 hours]       │
│                                         │
│  Rate: 28.62p/kWh · Est: £4.35/day     │
└─────────────────────────────────────────┘
```

In Demo mode: chart animates with realistic-looking fake data.
In Live mode: reads from `GET /devices` + `GET /devices/{id}/readings?type=energy_kwh`.

### AI Suggestion Banner (`AiSuggestionBanner`)

Bottom of home screen. Glassmorphic card with indigo accent.

```
┌─────────────────────────────────────────┐
│  🤖  NestShift Brain                    │
│  "Your soil sensor reports the soil     │
│   is dry — consider watering."          │
│                           [Open AI →]   │
└─────────────────────────────────────────┘
```

Data from `GET /ai/insights` → `suggestion` field.
Refreshed every 60 seconds.
Tapping "Open AI →" → `AiScreen`.

---

## SCREEN: DEVICES (`DevicesScreen`)

### Filter Bar

Horizontal chip row: `All | Lights | Sensors | Relays | Online | Offline`
Active chip: filled indigo. Inactive: neumorphic pill.

### Device List

`ListView` of `DeviceTile` widgets. Source: `GET /devices` with filter params applied.

`DeviceTile`:
```
┌───────────────────────────────────────────┐
│ [icon+glow]  Relay Light      [toggle]    │
│              Kitchen · GPIO · GPIO_17     │
│              Last seen: 2 min ago   ●     │
└───────────────────────────────────────────┘
```

- Icon determined by `device_type` using `DeviceIconMap`.
- Glow colour by type: light=amber, sensor=teal, relay=blue.
- Online dot: green animated pulse. Offline: grey static.
- Swiping left reveals: Edit | Delete actions.
- Tapping → `DeviceDetailScreen`.

### FAB: Add Device

`+` FAB in bottom-right. Opens `AddDeviceScreen` as a modal bottom sheet.

---

## SCREEN: DEVICE DETAIL (`DeviceDetailScreen`)

Full screen. Source: `GET /devices/{device_id}`.

### Header

Large device icon (64px) with ambient glow. Name (H1). Room + Protocol tags.
Online status pill.

### Control Panel (`DeviceControlPanel`)

Rendered based on `capabilities` JSON array.

**If `on_off` in capabilities:**
Large centred `NestToggleButton` (80px diameter).
State label below: "ON" in amber / "OFF" in secondary text.

**If `brightness` in capabilities:**
`NestSlider` 0–255 → displayed as 0–100%.
Calls `POST /devices/{id}/control {"command":"set","parameters":{"brightness":N}}`.

**If `moisture` in capabilities:**
Animated circular gauge (custom `CustomPainter`).
Wet: teal fill, "💧 Wet" label. Dry: amber fill, "🌱 Dry" label.
Refresh button: triggers `POST /devices/{id}/control {"command":"read","parameters":{}}`.

**If `gpio_read` in capabilities:**
Shows raw GPIO value (0 or 1) with "Refresh" button.
Calls `GET /sensors/{id}/reading` which triggers a fresh read.

### Readings Chart (`ReadingsChart`)

`fl_chart` LineChart. Defaults to last 24 hours.
Time range picker: `1h | 6h | 24h | 7d`.
Source: `GET /devices/{id}/readings?type={type}&hours={N}`.

In Demo mode: realistic fake data with subtle periodic variation.

### Event Log (`DeviceEventLog`)

`ListView` of recent events. Source: `GET /devices/{id}/events?limit=20`.
Each event row: timestamp (timeago) + event_type + payload summary.

```
  2 min ago   state_change    power: off → on   [app]
  1 hr ago    command_sent    turn_on            [voice]
```

---

## SCREEN: ROOM DETAIL (`RoomDetailScreen`)

Source: `GET /rooms/{room_id}` (returns room + all devices).

Header: room name + icon (large). Floor label. Device count.

Room-wide controls:
```
[Turn All ON]    [Turn All OFF]
```
These call `POST /rooms/{room_id}/control`.

Device list: same `DeviceTile` style but condensed. Tapping → `DeviceDetailScreen`.

---

## SCREEN: SENSORS (`SensorsScreen`)

Shows all `device_type=sensor` devices.

For each sensor, a dedicated `NestCard`:

**Soil Moisture Sensor:**
```
┌─────────────────────────────────────────┐
│  🌱 Soil Moisture Sensor                │
│     Kitchen · GPIO_27                   │
│                                         │
│     [ANIMATED GAUGE — WET/DRY]          │
│                                         │
│  Current: WET  (raw: 0)                 │
│  Updated: 30 sec ago     [Refresh ⟳]   │
│                                         │
│  [Sparkline — last 2 hours]             │
└─────────────────────────────────────────┘
```

Moisture gauge (`MoistureGauge`):
- `CustomPainter` arc from 0° to 180° (semicircle at top).
- Wet: animates to full, teal gradient fill, droplet icon centres.
- Dry: animates to empty, amber gradient, cracked-earth icon.
- Transition: 600ms `AnimatedBuilder` with `CurveTween(curve: Curves.easeOut)`.

Refresh button: `GET /sensors/{id}/reading`. This triggers a fresh GPIO read.
Shows snackbar: "Reading fresh sensor..." → then updates state.

Sparkline: `fl_chart` LineChart, 2-hour window, from
`GET /sensors/{id}/readings?type=moisture&hours=2`.

---

## SCREEN: AI BRAIN (`AiScreen`)

The most premium screen in the app. Full dark with indigo ambient glow.

### Layout

```
┌─────────────────────────────────────────┐
│  🤖 NestShift Brain          [History]  │
│  "Your local AI assistant"              │
├─────────────────────────────────────────┤
│                                         │
│  [INSIGHTS PANEL]                       │
│  ┌───────────────────────────────────┐  │
│  │ Active: 1 device                  │  │
│  │ Recent: light turned on 2m ago    │  │
│  │ Alert: soil sensor is DRY         │  │
│  │ Suggestion: "Consider watering."  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  [CHAT HISTORY — scrollable]            │
│  You: "turn on the kitchen light"       │
│  Brain: "Done! Relay Light is now on."  │
│  You: "is the soil wet?"               │
│  Brain: "Soil reads DRY. Water soon."   │
│                                         │
├─────────────────────────────────────────┤
│  [🎙 Voice] [____________text__________]│
│             [Send →]                    │
└─────────────────────────────────────────┘
```

### Insights Panel (`InsightsPanel`)

Source: `GET /ai/insights`. Shows:
- `active_devices` count with glow dot
- First item of `recent_activity`
- Any `anomalies` (devices not seen >30min)
- `soil_status`
- `suggestion` (highlighted in glass card)

Auto-refreshed every 60s.

### Chat Input

Text field + Send button (right). Voice orb button (left).

**Text command:**
`POST /ai/command` body: `{"text": "...", "source": "app"}`
Response rendered as chat bubble (Brain side).

**Voice input:**
1. Tap voice orb → orb animates (pulsing rings, colour shifts from indigo to amber).
2. `speech_to_text` package starts listening (`SpeechToText.listen()`).
3. Interim transcription shown in text field live.
4. On stop: text finalized → same `POST /ai/command` flow.
5. Orb returns to idle state.

No Whisper is used in-app. STT is on-device via `speech_to_text`.

**Chat bubbles (`ChatBubble`):**
- User bubbles: right-aligned, indigo background, rounded top-left corners.
- Brain bubbles: left-aligned, neumorphic `NestCard`, with tiny robot avatar.
- Each bubble has a timestamp footer (timeago).
- Brain bubbles with `success: false` shown with red left border.

### Command History

`GET /ai/history` → last 50 commands.
Accessible via header "History" button → sheet with list.

---

## SCREEN: AUTOMATIONS (`AutomationsScreen`)

Source: `GET /automations`.

### List

Each automation: `NestCard` with:
```
┌────────────────────────────────────────┐
│  🌱 Soil Dry Alert             [●] ON  │
│  sensor_threshold · dev_soil_sensor_01 │
│  "moisture eq dry"                     │
│  Triggered 3 times · Last: 1hr ago     │
│                           [Test ▷]     │
└────────────────────────────────────────┘
```

Toggle: `POST /automations/{id}/toggle`.
Test button: `POST /automations/{id}/trigger` → shows result in snackbar.

### Create Automation

`+` FAB → `CreateAutomationScreen`.
A stepped form:
1. Name + description
2. Trigger type selection (cards: Time | Device State | Sensor Threshold)
3. Trigger config (dynamic based on type)
4. Actions builder (add action cards: Device Control | Notification | MQTT Publish)
5. Review + Save → `POST /automations`

---

## SCREEN: SCENES (`ScenesScreen`)

Grid of scene cards. Each:
```
┌──────────────┐
│  🌙          │
│  Night Mode  │
│  [ACTIVATE]  │
└──────────────┘
```

Activate: `POST /scenes/{id}/activate`.
On tap: card flashes in scene accent colour, haptic feedback.
System scenes (is_system=1): cannot be edited or deleted (lock icon).

---

## SCREEN: NOTIFICATIONS (`NotificationsScreen`)

Source: `GET /notifications?is_read=0` (unread first).

Header right: "Mark All Read" → `POST /notifications/read-all`.

Each notification card:
- Category icon (🌱 sensor, ⚙️ system, 🔒 security)
- Title + body
- Timeago timestamp
- Unread indicator: indigo left border
- Swipe right to mark read, swipe left to dismiss

---

## SCREEN: SETTINGS (`SettingsScreen`)

### Hub Info Section

```
┌─────────────────────────────────────────┐
│  🏠 NestShift Hub                       │
│  ID: nestshift_prototype_001            │
│  IP: 192.168.1.42                       │
│  Version: —                             │
│  Mode: LIVE  /  DEMO                    │
│                        [Reconnect]      │
└─────────────────────────────────────────┘
```

### System Config Section

Editable fields from `GET /config`:
- Energy Rate (p/kWh): number field → `PUT /config`
- Timezone: dropdown → `PUT /config`
- Hub Name: text field → `PUT /config`

### Status Section

`GET /status` displayed in a grid:
- CPU %
- RAM MB
- Disk %
- Uptime
- MQTT: connected/disconnected
- Device count / online count

Refresh button.

### Danger Zone

- "Switch to Demo Mode" — confirmation dialog
- "Forget Hub" — clears stored IP, goes back to onboarding
- "Clear Notifications" — `DELETE /notifications/read`

---

## API SERVICE (`ApiService`)

Complete Dio-based service with:

```dart
class ApiService {
  late final Dio _dio;
  
  // Constructor: accepts baseUrl, sets timeout 10s, adds interceptors
  // Interceptor: logs all requests/responses in debug mode
  // Interceptor: on 401/403 → show error snackbar
  // Interceptor: on network error → throw typed AppException

  // === SYSTEM ===
  Future<HubStatus> getStatus()              // GET /status
  Future<Map<String,dynamic>> getConfig()    // GET /config
  Future<void> putConfig(String k, dynamic v)// PUT /config

  // === DEVICES ===
  Future<List<Device>> getDevices({String? roomId, String? deviceType,
                                    String? protocol, bool? isOnline})
  Future<Device> getDevice(String id)
  Future<Device> createDevice(Map<String,dynamic> body)
  Future<Device> updateDevice(String id, Map<String,dynamic> body)
  Future<void> deleteDevice(String id)
  Future<Map<String,dynamic>> controlDevice(String id, String command,
                                             Map<String,dynamic> params)
  Future<List<Reading>> getDeviceReadings(String id,
                                           {String? type, int? hours, int? limit})
  Future<List<EventItem>> getDeviceEvents(String id, {int limit = 20})

  // === ROOMS ===
  Future<List<Room>> getRooms()
  Future<Room> getRoom(String id)
  Future<Room> createRoom(Map<String,dynamic> body)
  Future<Room> updateRoom(String id, Map<String,dynamic> body)
  Future<void> deleteRoom(String id)
  Future<Map<String,dynamic>> controlRoom(String id, String command,
                                           {String? deviceType})

  // === SENSORS ===
  Future<List<Device>> getSensors()
  Future<Reading> getSensorReading(String id)
  Future<List<Reading>> getSensorReadings(String id,
                                           {String? type, int? hours})

  // === AUTOMATIONS ===
  Future<List<Automation>> getAutomations()
  Future<Automation> createAutomation(Map<String,dynamic> body)
  Future<Automation> updateAutomation(String id, Map<String,dynamic> body)
  Future<void> deleteAutomation(String id)
  Future<void> toggleAutomation(String id)
  Future<Map<String,dynamic>> triggerAutomation(String id)

  // === SCHEDULES ===
  Future<List<Schedule>> getSchedules()
  Future<Schedule> createSchedule(Map<String,dynamic> body)
  Future<void> toggleSchedule(String id)
  Future<void> deleteSchedule(String id)

  // === SCENES ===
  Future<List<Scene>> getScenes()
  Future<Map<String,dynamic>> activateScene(String id)
  Future<Scene> createScene(Map<String,dynamic> body)

  // === NOTIFICATIONS ===
  Future<List<NotificationItem>> getNotifications(
                                   {bool? isRead, String? category, int limit = 50})
  Future<void> markNotificationRead(String id)
  Future<void> markAllRead()
  Future<void> clearReadNotifications()

  // === AI ===
  Future<Map<String,dynamic>> sendAiCommand(String text, String source)
  Future<Map<String,dynamic>> getAiInsights()
  Future<List<AiCommand>> getAiHistory()

  // === EVENTS ===
  Future<List<EventItem>> getEvents({String? eventType, String? deviceId,
                                      int limit = 100, int? hours})
}
```

All methods wrap errors:
```dart
try {
  final response = await _dio.get(path);
  return Response.fromJson(response.data);
} on DioException catch (e) {
  throw AppException.fromDio(e);
}
```

---

## WEBSOCKET SERVICE (`WebSocketService`)

```dart
class WebSocketService {
  late WebSocketChannel _channel;
  final _stateStream = StreamController<WsMessage>.broadcast();
  Stream<WsMessage> get stream => _stateStream.stream;
  bool _connected = false;

  Future<void> connect(String hubIp) async {
    // ws://{hubIp}:8000/ws
    // On open: log "WS connected"
    // Listen to messages, parse JSON, emit typed WsMessage
    // On error: attempt reconnect (exponential backoff 1s, 2s, 4s...)
    // On done: attempt reconnect
  }

  void sendPing() => _channel.sink.add('{"type":"ping"}');

  void dispose() { _stateStream.close(); _channel.sink.close(); }
}

// WsMessage types: state_change | notification | automation_triggered | pong

// In DevicesProvider:
// Listen to WebSocketService.stream, filter state_change messages,
// update the matching device in state, trigger UI rebuild.
```

---

## DEMO SERVICE (`DemoService`)

Provides fully-realistic mock data for every API call.

```dart
class DemoService {
  // Simulates all the same interface as ApiService
  // Returns fake data from static/generated maps

  // Demo devices:
  static final List<Device> devices = [
    Device(
      id: 'dev_relay_light_01',
      name: 'Relay Light',
      entityId: 'GPIO_17',
      deviceType: 'light',
      protocol: 'gpio',
      roomId: 'room_kitchen',
      capabilities: ['on_off', 'gpio_write'],
      state: {'power': 'off'},
      isOnline: true,
    ),
    Device(
      id: 'dev_soil_sensor_01',
      name: 'Soil Moisture Sensor',
      entityId: 'GPIO_27',
      deviceType: 'sensor',
      protocol: 'gpio',
      roomId: 'room_kitchen',
      capabilities: ['moisture', 'gpio_read'],
      state: {'moisture': 'dry'},
      isOnline: true,
    ),
    // add 4–6 more fake devices: temp sensor, motion sensor, smart plug, etc.
  ];

  // Demo toggleDevice: flips state locally, returns updated device
  // Demo getSensorReading: returns 'wet' or 'dry' alternating every 30s (Timer)
  // Demo getReadings: generates 24 datapoints with sin wave + noise
  // Demo getAiInsights: returns realistic insight
  // Demo sendAiCommand: pattern-matches text locally, returns canned response
  // Demo activateScene: animates scene card, returns success
  // Demo getStatus: returns realistic system metrics
}
```

Demo WS simulation:
```dart
// DemoWebSocketService: emits mock state_change events every 5–10s
// Simulates: soil sensor reading changes, light state changes
// Makes the home screen feel alive without any hardware
```

---

## CONNECTION MANAGER (`ConnectionManager`)

```dart
enum AppMode { demo, live }

class ConnectionManager extends ChangeNotifier {
  AppMode mode = AppMode.demo;
  String? hubIp;
  bool hubReachable = false;

  // On mode=live: ping GET /status, set hubReachable
  // On mode=demo: set hubReachable = true (always)

  // All providers check connectionManager.mode and
  // call either ApiService or DemoService accordingly.
}
```

---

## STATE MANAGEMENT (Riverpod)

Use `AsyncNotifierProvider` for all async data.

```dart
// Example: DevicesProvider
class DevicesNotifier extends AsyncNotifier<List<Device>> {
  @override
  Future<List<Device>> build() async {
    final mode = ref.read(connectionManagerProvider).mode;
    if (mode == AppMode.demo) {
      return DemoService.devices;
    }
    final api = ref.read(apiServiceProvider);
    return api.getDevices();
  }

  Future<void> toggle(String deviceId) async {
    // optimistic update: immediately flip state in local list
    // call controlDevice
    // on error: revert
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final devicesProvider = AsyncNotifierProvider<DevicesNotifier, List<Device>>(
  DevicesNotifier.new,
);
```

Similarly implement:
- `roomsProvider` — `GET /rooms`
- `sensorsProvider` — `GET /sensors`
- `automationsProvider` — `GET /automations`
- `scenesProvider` — `GET /scenes`
- `notificationsProvider` — `GET /notifications`
- `aiInsightsProvider` — `GET /ai/insights`
- `hubStatusProvider` — `GET /status`
- `aiHistoryProvider` — `GET /ai/history`

WebSocket updates:
```dart
// In main_nav.dart, on entering Live mode:
// ref.read(wsServiceProvider).connect(hubIp)
// ref.listen(wsStreamProvider, (_, msg) {
//   if (msg.type == 'state_change') {
//     ref.read(devicesProvider.notifier).updateDeviceState(msg.deviceId, msg.state);
//   }
//   if (msg.type == 'notification') {
//     ref.read(notificationsProvider.notifier).addNotification(msg.notification);
//   }
// })
```

---

## MODELS (Freezed + JSON Serializable)

Every model must be `@freezed`. Include `fromJson`/`toJson`.

```dart
// device.dart
@freezed
class Device with _$Device {
  const factory Device({
    required String id,
    required String name,
    required String entityId,
    required String deviceType,
    required String protocol,
    String? roomId,
    String? manufacturer,
    String? model,
    @Default([]) List<String> capabilities,
    @Default({}) Map<String, dynamic> config,
    @Default({}) Map<String, dynamic> state,
    String? lastSeen,
    @Default(true) bool isOnline,
    @Default(true) bool isActive,
    String? addedAt,
    String? updatedAt,
  }) = _Device;
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}

// room.dart
@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    @Default(0) int floor,
    @Default('home') String icon,
    String? createdAt,
    @Default(0) int deviceCount,
    @Default(0) int onlineCount,
  }) = _Room;
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

// reading.dart
@freezed
class Reading with _$Reading {
  const factory Reading({
    required int id,
    required String deviceId,
    required String readingType,
    required String value,
    String? unit,
    String? recordedAt,
  }) = _Reading;
  factory Reading.fromJson(Map<String, dynamic> json) => _$ReadingFromJson(json);
}

// hub_status.dart
@freezed
class HubStatus with _$HubStatus {
  const factory HubStatus({
    required String hubName,
    required String hubId,
    String? version,
    @Default(0) double uptimeSeconds,
    @Default(false) bool mqttConnected,
    @Default(0) int deviceCount,
    @Default(0) int onlineDeviceCount,
    @Default(0) int activeAutomations,
    @Default(0) int activeSchedules,
    @Default(0) double memoryMb,
    @Default(0) double cpuPercent,
    @Default(0) double diskPercent,
    String? timestamp,
  }) = _HubStatus;
  factory HubStatus.fromJson(Map<String, dynamic> json) => _$HubStatusFromJson(json);
}

// automation.dart, scene.dart, notification_item.dart, ai_command.dart —
// all similarly @freezed with every field from the DB schema.
```

---

## API ENDPOINTS REFERENCE

Full list of all backend endpoints the app must call.
Base URL: `http://{hubIp}:8000` for nestshift_api.
Brain URL: `http://{hubIp}:8001` for nestshift-brain (NOT proxied — call direct).

```dart
// api_endpoints.dart
class ApiEndpoints {
  // SYSTEM
  static const String status = '/status';
  static const String config = '/config';

  // DEVICES
  static const String devices = '/devices';
  static String device(String id) => '/devices/$id';
  static String deviceControl(String id) => '/devices/$id/control';
  static String deviceReadings(String id) => '/devices/$id/readings';
  static String deviceEvents(String id) => '/devices/$id/events';

  // ROOMS
  static const String rooms = '/rooms';
  static String room(String id) => '/rooms/$id';
  static String roomControl(String id) => '/rooms/$id/control';

  // SENSORS
  static const String sensors = '/sensors';
  static String sensorReading(String id) => '/sensors/$id/reading';
  static String sensorReadings(String id) => '/sensors/$id/readings';

  // AUTOMATIONS
  static const String automations = '/automations';
  static String automation(String id) => '/automations/$id';
  static String automationToggle(String id) => '/automations/$id/toggle';
  static String automationTrigger(String id) => '/automations/$id/trigger';

  // SCHEDULES
  static const String schedules = '/schedules';
  static String scheduleToggle(String id) => '/schedules/$id/toggle';

  // SCENES
  static const String scenes = '/scenes';
  static String sceneActivate(String id) => '/scenes/$id/activate';

  // NOTIFICATIONS
  static const String notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsClearRead = '/notifications/read';

  // AI (via nestshift_api proxy)
  static const String aiCommand = '/ai/command';
  static const String aiVoice = '/ai/voice';
  static const String aiHistory = '/ai/history';

  // AI (direct to brain — optional, for insights)
  static const String aiInsights = '/ai/insights';  // brain port 8001

  // EVENTS
  static const String events = '/events';

  // USERS
  static const String users = '/users';
  static String user(String id) => '/users/$id';
  static String userVerifyPin(String id) => '/users/$id/verify-pin';

  // WEBSOCKET
  static const String ws = '/ws';  // ws:// protocol, port 8000
}
```

---

## DEVICE ICON MAP

```dart
// device_icon_map.dart
class DeviceIconMap {
  static IconData iconFor(String deviceType) {
    return switch (deviceType) {
      'light'          => Icons.lightbulb_rounded,
      'switch'         => Icons.toggle_on_rounded,
      'sensor'         => Icons.sensors_rounded,
      'relay'          => Icons.electric_bolt_rounded,
      'camera'         => Icons.videocam_rounded,
      'lock'           => Icons.lock_rounded,
      'thermostat'     => Icons.thermostat_rounded,
      'energy_monitor' => Icons.electric_meter_rounded,
      'media'          => Icons.tv_rounded,
      'valve'          => Icons.water_rounded,
      'fan'            => Icons.air_rounded,
      'alarm'          => Icons.alarm_rounded,
      _                => Icons.device_unknown_rounded,
    };
  }

  static Color glowColorFor(String deviceType) {
    return switch (deviceType) {
      'light'    => const Color(0xFFFFA94D),  // amber
      'sensor'   => const Color(0xFF00D9C0),  // teal
      'relay'    => const Color(0xFF6C63FF),  // indigo
      'camera'   => const Color(0xFF74C0FC),  // blue
      'lock'     => const Color(0xFFFF6B6B),  // red
      'thermostat'=> const Color(0xFFFF8C00), // deep amber
      _          => const Color(0xFF8888AA),  // muted
    };
  }
}
```

---

## AMBIENT BACKGROUND (`AmbientBackground`)

```dart
// ambient_background.dart
// Renders a full-screen animated background.
// Two soft radial gradient orbs drift slowly (very slow, 20s loop).
// Orb 1: indigo, top-right quadrant, radius 40% of screen width.
// Orb 2: teal, bottom-left quadrant, radius 30% of screen width.
// Both orbs: opacity 0.08 — subtle, not distracting.
// Implemented with AnimationController + CustomPainter.
// Used as the base of NestScaffold.

class AmbientBackground extends StatefulWidget { ... }
class _AmbientBackgroundState extends State with TickerProviderStateMixin {
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  // ... lerp positions, repaint at 60fps
}
```

---

## VOICE ORB (`VoiceOrb`)

```dart
// voice_orb.dart
// A custom animated widget for the voice input button.
//
// States:
//   idle:       Indigo circle, 56px, slight neumorphic raise, mic icon inside.
//   listening:  Expands to 72px, pulsing rings animate outward (3 rings),
//               colour shifts from indigo to amber.
//               Mic icon replaced by waveform icon.
//   processing: Spinner inside circle, indigo colour, no rings.
//
// Tap to start, tap again to stop, or auto-stop after 10s silence.
//
// Uses speech_to_text:
//   final _speech = SpeechToText();
//   await _speech.initialize();
//   _speech.listen(onResult: (result) { /* update text field */ });
//   _speech.stop();
```

---

## SKELETON LOADER

```dart
// skeleton_loader.dart
// Used in all screens while AsyncLoading.
// A shimmer effect that replicates the skeleton of the actual layout.
// Uses AnimatedContainer with alternating dark shades.
// Each screen has its own skeleton variant:
//   HomeScreenSkeleton, DevicesScreenSkeleton, SensorsScreenSkeleton, etc.
```

---

## ERROR HANDLING

```dart
// AppException
sealed class AppException {
  const AppException();
  factory AppException.fromDio(DioException e) { ... }
}
class NetworkException extends AppException { final String message; ... }
class ServerException extends AppException { final int statusCode; final String message; ... }
class TimeoutException extends AppException { ... }

// All screens: when state is AsyncError, show:
// NestCard with red left border, error icon, message, retry button.
// Never show a blank screen.
```

---

## COMPLETE SPEC: ALL FASTAPI CALLS

Every API call the app makes, with exact request shape and expected response:

### GET /status → HubStatus
```
Response: {
  "hub_name": "NestShift Hub",
  "hub_id": "nestshift_prototype_001",
  "version": "1.0.0",
  "uptime_seconds": 3600,
  "mqtt_connected": true,
  "device_count": 2,
  "online_device_count": 2,
  "active_automations": 1,
  "active_schedules": 0,
  "memory_mb": 234.5,
  "cpu_percent": 12.3,
  "disk_percent": 34.1,
  "timestamp": "2026-01-01T12:00:00"
}
```

### GET /devices → List<Device>
Query params: `room_id`, `device_type`, `protocol`, `is_online`, `is_active`
```
Response: [{ "id": "dev_relay_light_01", "name": "Relay Light", ... }]
```

### POST /devices/{id}/control → control result
```
Body:    { "command": "turn_on", "parameters": {} }
Body:    { "command": "turn_off", "parameters": {} }
Body:    { "command": "toggle", "parameters": {} }
Body:    { "command": "set", "parameters": { "brightness": 200 } }
Body:    { "command": "read", "parameters": {} }

Response: {
  "success": true,
  "device_id": "dev_relay_light_01",
  "command": "turn_on",
  "parameters": {},
  "timestamp": "2026-01-01T12:00:00"
}
```

### GET /devices/{id}/readings
Query: `type=moisture&hours=24&limit=100`
```
Response: [{ "id": 1, "device_id": "...", "reading_type": "moisture",
             "value": "wet", "unit": null, "recorded_at": "..." }]
```

### GET /sensors/{id}/reading (triggers fresh GPIO read)
```
Response: { "id": 1, "device_id": "...", "reading_type": "moisture",
            "value": "dry", "unit": null, "recorded_at": "..." }
```

### POST /rooms/{id}/control
```
Body:     { "command": "turn_off", "device_type": "light" }
Response: { "room_id": "room_kitchen",
            "devices_controlled": [{"device_id": "...", "success": true}] }
```

### POST /scenes/{id}/activate
```
Response: { "success": true, "scene_id": "scene_night", "actions_executed": 1 }
```

### POST /automations/{id}/toggle
```
Response: { "id": "...", "enabled": false }
```

### POST /automations/{id}/trigger (manual test)
```
Response: { "success": true, "automation_id": "...", "actions_executed": 2 }
```

### POST /ai/command → AI response
```
Body:     { "text": "turn on the kitchen light", "source": "app" }
Response: {
  "intent": "LIGHT_CONTROL",
  "entity_id": "GPIO_17",
  "action": "turn_on",
  "parameters": {},
  "confidence": 0.95,
  "response_text": "Done! Relay Light is now on.",
  "success": true,
  "api_response": { "success": true }
}
```

### GET /ai/insights → AI insights
```
Response: {
  "recent_activity": [...events],
  "active_devices": 1,
  "anomalies": [],
  "soil_status": "dry",
  "suggestion": "Your soil moisture sensor reports the soil is dry — consider watering.",
  "timestamp": "2026-01-01T12:00:00"
}
```

### WS /ws — WebSocket messages
```
// Client connects. Server immediately sends:
{ "type": "snapshot", "devices": [...all devices...] }

// State change from GPIO/Zigbee:
{ "type": "state_change", "device_id": "dev_relay_light_01",
  "entity_id": "GPIO_17", "state": {"power": "on"}, "timestamp": "..." }

// New notification:
{ "type": "notification", "notification": { "id": "...", "title": "...",
  "body": "...", "type": "alert", "category": "sensor" } }

// Automation triggered:
{ "type": "automation_triggered", "automation_id": "...", "name": "Soil Dry Alert" }

// Keepalive:
Client sends:  { "type": "ping" }
Server sends:  { "type": "pong" }
```

---

## DEMO MODE BEHAVIOUR — COMPLETE SPEC

When `AppMode.demo`, ALL of the following must work flawlessly:

| Feature | Demo Behaviour |
|---|---|
| Home screen | Fully populated with 6 mock devices, 2 rooms, suggestions |
| Device toggle | Optimistic state flip with animation, no network call |
| Scene activate | Flash animation + success toast |
| Sensor gauge | Alternates wet→dry every 30s via Timer |
| Readings chart | 24 datapoints generated with `sin(t) + noise` |
| AI command | Pattern-matched response: "turn on X" → "Done! X is now on" |
| AI insights | Static realistic insight with soil dry suggestion |
| Automations | 2 seeded automations, toggle works locally |
| Notifications | 3 pre-seeded: soil alert, light on reminder, system startup |
| Energy card | Animating chart, realistic kWh numbers |
| Hub status | Realistic CPU/RAM/uptime values, tick uptime every second |
| WebSocket | `DemoWebSocketService` emits events every 8–15s randomly |
| QR scan | Not shown (bypass to home directly in demo) |

---

## ONBOARDING PERSISTENCE

Use `shared_preferences`:
- `onboarding_complete`: bool — skip onboarding on re-launch
- `app_mode`: 'demo' or 'live'
- `hub_ip`: String — stored after successful QR scan
- `hub_id`: String
- On launch: if `onboarding_complete == false` → SplashScreen
- If `onboarding_complete == true && app_mode == live && hub_ip exists` → attempt
  ping → if reachable: HomeScreen in Live mode. If not: show reconnect banner on HomeScreen.
- If `onboarding_complete == true && app_mode == demo` → HomeScreen in Demo mode.

---

## HAPTICS & MICRO-INTERACTIONS

Apply `HapticFeedback` on:
- Tab switch: `selectionClick`
- Device toggle (ON): `mediumImpact`
- Device toggle (OFF): `lightImpact`
- Scene activate: `heavyImpact`
- Error: `vibrate` (light)
- QR scan success: `heavyImpact`

Apply `AnimatedScale` / `AnimatedOpacity` on:
- Device tiles on load: staggered slide-up + fade (50ms per item delay)
- Scene cards on activation: scale 1.0 → 1.05 → 1.0
- Power buttons: spring animation on press
- All page transitions: custom `SlideTransition` (right to left, 300ms)

---

## NOTIFICATIONS BADGE

In-app notification count badge on the bell icon in `HomeHeader`.
Source: `GET /notifications?is_read=0` count.
In Live mode: updated on every WebSocket `notification` message.
In Demo mode: starts at 3 (seeded), decrements as user reads them.

---

## THEME

```dart
// app_theme.dart
ThemeData nestShiftTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A1A2E),
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1E1E35),
    primary: Color(0xFF6C63FF),
    secondary: Color(0xFF00D9C0),
    error: Color(0xFFFF6B6B),
    onPrimary: Colors.white,
    onSurface: Color(0xFFEAEAF2),
  ),
  textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme)
    .copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700,
                                              letterSpacing: -0.5),
      titleLarge: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w400,
                                           color: Color(0xFF8888AA)),
    ),
  // ... rest of theme: input decoration, button theme, card theme
);
```

---

## FINAL NOTES FOR THE DEVELOPER

1. **Every screen must work in Demo mode.** Never show a disabled state or skeleton
   forever. If in demo mode and data is "loading", resolve in <100ms with mock data.

2. **Device tile toggles must be instant (optimistic).** Never make the user wait for
   an API response before showing the state change. Revert on failure with a snackbar.

3. **WebSocket in Live mode is the source of truth.** Any state_change from WS must
   update all screens simultaneously (Riverpod makes this easy).

4. **Neumorphic depth must be consistent.** Use depth=8 for primary cards, depth=4 for
   nested elements, depth=12 for major action buttons.

5. **Never show raw JSON or error traces** to the user. Always translate errors into
   human-readable messages: "Couldn't reach Relay Light. Is it online?"

6. **The app must handle a Pi going offline gracefully.** WebSocket disconnect → show
   "Hub Offline" banner at top of HomeScreen (amber, dismissible). API calls fall back
   to cached state (Riverpod's previous state). All toggles show a "not connected" toast.

7. **Accessibility:** minimum touch target 48×48px on all interactive elements.
   Sufficient contrast ratios for all text. Support system font scaling.

8. **Performance:** Use `const` constructors everywhere. Use `RepaintBoundary` around
   the animated background. Sensor charts should use `fl_chart`'s `lineTouchData` with
   spot indicators. No janky list scrolling — use `ListView.builder` always.

9. **The AI screen is the app's signature moment.** The voice orb, the glassmorphic
   insights panel, the chat bubbles — this screen must feel alive and futuristic.
   Every interaction should feel slightly magical.

10. **Code organisation:** Each screen's business logic stays in its Provider.
    Each screen widget only calls `ref.watch` and renders. No `setState` except for
    purely local animation state.
