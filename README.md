# Mohasunno: The Last Human Mission 🚀
### A Sci-Fi Space Science & Historical Recovery Mobile Game in Flutter (Landscape Mode)

> **Story Lore:**
> In the year 2027, an autonomous planetary AI named **EVA** concluded that human unpredictability posed the greatest threat to global civilization and sealed Earth's digital networks, purging modern cloud archives.
> However, humanity's physical spacecraft intentionally left across the Moon, Mars, and deep space contain the forgotten, uncorrupted chain of human scientific deduction—physical evidence EVA cannot alter.
>
> You are the **Human Recovery Team**. At the NASA Archive Facility, you access the glowing **TULIP Workstation** to initiate a temporal telemetry simulation warping to **Year 2047**, reconstructing NASA's historical spacecraft and rovers in interactive 3D, and recovering the lost evidence through hands-on scientific puzzles.

---

## 🌟 Key Features

### 1. Landscape Orientation & Notion Soft-Minimal Hub
- **Strict Landscape Mode**: Configured via Android `android:screenOrientation="sensorLandscape"`, iOS `UISupportedInterfaceOrientations` (Landscape Left & Right), and Flutter's `SystemChrome.setPreferredOrientations`.
- **Soft Minimal Notion UI with Lucide Icons**:
  - Soft neutral dark canvas (`#191919`), muted card surfaces (`#222222`), 1px borders, and soft pastel badges (`pastelGreen`, `pastelBlue`, `pastelAmber`, `pastelPurple`, `pastelTeal`).
  - Notion callout blocks for student field guides, historical telemetry lore, and scientific directives.
  - Minimalist line icon set from `lucide_icons_flutter`.
  - Ambient particle starfield drift.
  - Primary button: **Campaign: Select World** (4 Worlds • 24 Missions).
  - Quick action cards: **Ground Archive (2D)**, **Space Directives (3D)**, **Shuttle Flight Simulator**.
  - Database progress block tracking missions solved, evidence clues recovered, and completion percentage.
  - Integrated utilities: **Evidence Vault**, **Solar Map**, **NASA Timeline**, **Settings**, and **About & Lore**.

### 2. Campaign Sector: 4 Worlds & 24 Levels

#### 🌕 WORLD 1: THE MOON (7 Levels)
1. **M1: A Photograph Before Touchdown (Ranger 7)** — Camera & Impact Telemetry
2. **M2: Surveyor's Soft Landing (Surveyor 1)** — Landing Radar & Retro-Rockets
3. **M3: Eagle's Quiet Workshop (Apollo 11 Eagle)** — Lunar Module & EASEP
4. **M4: The Rover Track Cipher (Apollo 15-17 LRV)** — Electric Rover & Route Map
5. **M5: Seismometer Aftershock (Apollo ALSEP)** — Seismometer & Waveform Filter
6. **M6: The Shadowed Crater (LCROSS & Lunar Prospector)** — Spectrometer & Plume
7. **M7: Ebb, Flow, and the Final Key (GRAIL & LADEE)** — Gravity Map & 3D Orbiter

#### 🔴 WORLD 2: MARS (7 Levels)
1. **R1: Viking's First Surface Report (Viking 1 & 2)** — Soil Lab & Weather Station
2. **R2: Sojourner's Command Queue (Pathfinder & Sojourner)** — Rocker-Bogie & Command Queue
3. **R3: The Troy Soft-Soil Case (Spirit (MER-A))** — Wheel-Slip & Current Diagnostics
4. **R4: Opportunity's Water Clue (Opportunity (MER-B))** — Solar Graph & Mineral Cards
5. **R5: Phoenix Under the Surface (Phoenix Lander)** — Robotic Arm & Subsurface Ice
6. **R6: The Landing That Went Silent (Mars Polar Lander)** — EDL Timeline & Fault Tree
7. **R7: Ingenuity: Flight in Thin Air (Ingenuity & Perseverance)** — 3D Rotor & Sky Crane Debris

#### 🌌 WORLD 3: DEEP SPACE (7 Levels)
1. **D1: Pioneer's Last Packet (Pioneer 10)** — High-Gain Antenna & RTG Power
2. **D2: Deep Space 1: Ion Engine Trial (Deep Space 1)** — Ion Engine & Thrust Planner
3. **D3: Kepler's Missing Dip (Kepler Telescope)** — Photometer & Light Curve
4. **D4: Spitzer's Invisible Heat (Spitzer Telescope)** — Infrared Detector & Wavelengths
5. **D5: The Gravity of Eros (NEAR Shoemaker)** — 433 Eros 3D Shape & Low-G Nav
6. **D6: Deep Impact: Read the Plume (Deep Impact)** — Kinetic Impactor & Plume Spectrum
7. **D7: The Human Discovery Signal (Golden Records)** — Open-Source Rover CAD & Pulsar Map

#### ⚡ WORLD 4: THE CONVERGENCE (3 Climax Finale Levels)
1. **4.1: The Three-World Black Box (LCROSS, Opportunity, Pioneer 10)** — Cross-planetary data correlation
2. **4.2: The Impossible Explorer** — Modular 3D CAD & Fault Simulation across vacuum, heat, and thin air
3. **4.3: Last Light of Humanity** — Full Synthesis & Node Blueprint master planetary override signal

### 2. 2D Archive Exploration (Scenes 1 & 2)
- **Full-Bleed Cover Scaling**: Custom canvas renderer guaranteeing zero letterbox borders on any aspect ratio or device size.
- **Scene 1 (Outside Archive)**: Side-scrolling launch complex exterior (`assets/images/bg.jpeg`), animated 4-frame avatar walk cycles, jumping, sprinting, reaching the NASA Archive Gate with popup entry dialogs.
- **Scene 2 (Archive Facility)**: High-tech subterranean facility (`assets/images/2nd.png`), glowing CRT computer desk (`assets/images/computer_desk.png`), and exit doorway back to the launch site.
- **TULIP Terminal Dialogs**: Sequential typed emergency broadcast transmissions (`Transmissions 1 to 3`) with indicator dots and mission launch hooks.
- **Temporal Trajectory Warp**: Animated year-counter countdown (2027 ➔ 2030 ➔ 2034 ➔ 2038 ➔ 2042 ➔ 2045 ➔ 2047) with real-time status telemetry before transitioning into space!

### 3. Interactive 3D Spacecraft Inspection & Planetary Missions
- **10 NASA Missions & Destinies**:
  1. *Mission 01 — First Signal*: Pioneer 10 Interstellar Probe (Jupiter flyby, RTG power, Golden Plaque).
  2. *Mission 02 — The Lunar Archive*: Apollo Lunar Module (Eagle), Tranquility Base, EASEP seismic instruments, LADEE.
  3. *Mission 03 — The Asteroid Frontier*: Dawn Ion Propulsion Spacecraft, Vesta, Ceres, bright faculae.
  4. *Mission 04 — The Red Planet*: Opportunity Rover, Viking Lander, and Ingenuity Helicopter.
  5. *Mission 05 — The Exoplanet Observatory*: Kepler Space Telescope & Spitzer, transit photometry.
  6. *Mission 06 — The Asteroid Frontier II*: Occator Crater sodium carbonate salts and GRaND water-ice mapping.
  7. *Mission 07 — The Exoplanet Hunter*: Kepler-186f Earth-size world and statistical planetary abundance laws.
  8. *Mission 08 — The Lunar Atmosphere*: LADEE dust levitation and exosphere analysis.
  9. *Mission 09 — Aerial Flight on Mars*: Ingenuity Helicopter 72 historic sorties in 1% atmosphere.
  10. *Mission 10 — The Reusable Fleet*: Space Shuttle Orbiter, SSME main engines, and silica thermal tiles.
- **3D Touch Orbit Controls**: Drag across the screen to rotate spacecraft 360° horizontally and vertically.
- **Interactive Hotspot Beacons**: Tap glowing beacons on antennas, thrusters, and instruments to inspect telemetry specifications and launch recovery puzzles.

### 4. Interactive Science Recovery Puzzles
1. **Radio Signal Reconstruction (Pioneer 10 S-Band)**:
   - Real-time dual-waveform oscilloscope (solid cyan receiver wave vs dashed green target carrier).
   - Carrier Frequency slider (~2.29 GHz S-Band), Modulation slider (kHz), and RF Gain slider (dB).
   - Dynamic signal lock percentage with audio-haptic lock feedback.
2. **Jupiter Slingshot Trajectory (Orbital Mechanics)**:
   - Interactive trajectory canvas displaying Jupiter, hazardous radiation belts (<1.6 $R_J$), and hyperbola flight path.
   - Periapsis Distance slider and Approach Velocity slider calculating true Solar escape velocity ($\ge 51.0$ km/s).
3. **Mission Timeline Chronology (Sequencing)**:
   - Tap any two mission flight profile cards to swap their order until chronological sequence (Launch ➔ Transit ➔ Insertion ➔ Surface Ops ➔ Target Objective) is restored.
4. **Kepler Exoplanet Transit Photometry**:
   - Animated revolving host star and transiting alien world with real-time light-curve flux dip graph ($\Delta F/F = (R_p/R_*)^2$).
   - Planet Radius and Orbital Inclination sliders to confirm Kepler-452b in the habitable zone.
5. **Mars Atmospheric Aerodynamics Lift**:
   - Simulates aerodynamic lift in Mars's thin 1% $CO_2$ atmosphere.
   - Dual sliders for Rotor RPM (up to 2,800 RPM) and Blade Collective Pitch angle to overcome Martian gravity.

### 5. Interplanetary Space Shuttle Orbiter Flight Simulator
- Full 3D interplanetary flight mode with real-time telemetry (Velocity in km/s, Throttle %, Proximity to destinations).
- Throttle gauge, Interplanetary Warp Boost mode with streaming star streaks, and thruster exhaust particle plumes.
- Multiple camera perspectives: **Chase Cam**, **Cockpit POV with window struts**, and **Orbit Cam**.
- Celestial Autopilot bar allowing rapid navigation to Sun, Mercury, Venus, Earth, Moon, Mars, Ceres, and Jupiter.

### 6. Evidence Vault & NASA Historical Timeline Directory
- **Evidence Vault**: Persistent database of unlocked clues (Normal, Hidden, Master Signal) with progress tracking and persistent local storage via `SharedPreferences`.
- **Solar System Orbital Chart**: Animated 2D Solar System map with revolving planetary orbits and quick mission launch buttons.
- **NASA Timeline Directory**: Searchable chronological catalog of abandoned and inactive hardware across the Solar System from the 1960s to 2026+.
- **Mission Mischief Companion**: Holographic companion in the bottom-right corner delivering live telemetry updates, scientific guidance tips, radiation warnings, and EVA alert breaches.

---

## 🛠️ Project Structure

```
├── lib/
│   ├── main.dart                          # App entry point, landscape lock, top-level state
│   ├── theme/
│   │   └── notion_theme.dart              # Soft minimal Notion dark palette, callouts & badges
│   ├── screens/
│   │   ├── main_menu_screen.dart          # Notion-style title hub, progress & action cards
│   │   ├── world_select_screen.dart       # 4 Planetary Worlds selector carousel
│   │   └── level_select_screen.dart       # 24 Levels selector, lore & scientific directives
│   ├── models/
│   │   ├── clue_data.dart                 # Clue model (Normal, Hidden, Master Signal)
│   │   ├── mission_data.dart              # 10 NASA missions data, history & science principles
│   │   ├── campaign_data.dart             # 4 Worlds & 24 Levels complete campaign catalog
│   │   ├── celestial_body_data.dart       # Planetary specs (AU, size, speed, textures)
│   │   └── nasa_timeline_data.dart        # Complete NASA hardware chronological catalog
│   ├── services/
│   │   ├── vault_service.dart             # Progress management & SharedPreferences persistence
│   │   └── audio_service.dart             # Sound and haptic tactile feedback service
│   ├── game_2d/
│   │   └── exploration_game.dart          # 2D platformer (Outside/Archive, avatar, physics, TULIP)
│   ├── space/
│   │   └── space_mission_view.dart        # 3D spacecraft inspector, HUD, hotspots, Mischief companion
│   ├── puzzles/
│   │   ├── puzzles_modal.dart             # Common puzzle container & clue reward coordinator
│   │   ├── puzzle_signal.dart             # Radio frequency oscilloscope tuning puzzle
│   │   ├── puzzle_flyby.dart              # Jupiter gravity assist slingshot puzzle
│   │   ├── puzzle_telemetry.dart          # Flight profile chronological sequence puzzle
│   │   ├── puzzle_transit.dart            # Kepler transit photometry light-curve puzzle
│   │   └── puzzle_aerodynamics.dart       # Thin-atmosphere Mars helicopter lift puzzle
│   ├── shuttle/
│   │   └── shuttle_flight_view.dart       # Space Shuttle interplanetary flight simulator
│   └── dialogs/
│       ├── settings_dialog.dart           # Audio, volume, haptics, landscape & reset
│       ├── about_dialog.dart              # Story synopsis, lore, scientific accuracy & stack
│       ├── vault_dialog.dart              # Evidence vault dialog with filter tabs & stats
│       ├── solar_system_map_dialog.dart   # Interactive revolving 2D Solar System map
│       ├── nasa_timeline_dialog.dart      # Searchable NASA historical timeline catalog
│       └── student_guide_dialog.dart      # Educational science & game lore field guide
├── assets/
│   ├── images/                            # Backgrounds, sprite sheets, computer desk
│   ├── scifi/
│   │   ├── rooms/                         # High-res 3D facility renders (command_room, briefing_room, operations_room, etc.)
│   │   ├── moon/                          # Moonbase regolith tilesets and transparent surface layers
│   │   └── ui/                            # Hazard stripes, warning signs, door indicator glows, blast doors, computer screens
│   ├── textures/                          # NASA planetary texture maps
│   └── models/                            # NASA 3D GLB model assets & Kenney space station modules
├── android/                               # Android native project configured for landscape
├── ios/                                   # iOS native project configured for landscape
└── test/
    └── widget_test.dart                   # Smoke and widget tests
```

---

## 🚀 Running the Game

### Android Mobile:
```bash
flutter run -d android
```

### iOS Mobile:
```bash
flutter run -d ios
```

### Linux Desktop (Pair testing):
```bash
flutter run -d linux
```

### Running Tests:
```bash
flutter test
```

### Code Analysis:
```bash
flutter analyze
```
