import 'package:flutter/material.dart';

class CampaignLevel {
  final String id;
  final String code; // e.g. "M1", "R4", "D1", "4.1"
  final String worldId; // "world-1", "world-2", "world-3", "world-4"
  final String title;
  final String spacecraft;
  final String subsystem;
  final String targetBody;
  final String modelName;
  final String puzzleType; // "signal", "flyby", "telemetry", "transit", "aerodynamics"
  final String lore;
  final String objective;
  bool isUnlocked;
  bool isCompleted;
  int stars; // 0 to 3

  CampaignLevel({
    required this.id,
    required this.code,
    required this.worldId,
    required this.title,
    required this.spacecraft,
    required this.subsystem,
    required this.targetBody,
    required this.modelName,
    required this.puzzleType,
    required this.lore,
    required this.objective,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.stars = 0,
  });

  String get bannerPath {
    final c = code.toLowerCase().trim();
    switch (c) {
      case "m1": return "assets/images/banner/m1.webp";
      case "m2": return "assets/images/banner/m2.webp";
      case "m3": return "assets/images/banner/m3.webp";
      case "m4": return "assets/images/banner/m4.webp";
      case "m5": return "assets/images/banner/m5.webp";
      case "m6": return "assets/images/banner/m6.webp";
      case "m7": return "assets/images/banner/m7.webp";
      case "r1": return "assets/images/banner/r1.webp";
      case "r2": return "assets/images/banner/r2.webp";
      case "r3": return "assets/images/banner/r3.webp";
      case "r4": return "assets/images/banner/r4.webp";
      case "r5": return "assets/images/banner/r5.webp";
      case "r6": return "assets/images/banner/r6.webp";
      case "r7": return "assets/images/banner/r7.webp";
      case "d1": return "assets/images/banner/d1.webp";
      case "d2": return "assets/images/banner/d2.webp";
      case "d3": return "assets/images/banner/d3.webp";
      case "d4": return "assets/images/banner/d4.webp";
      case "d5": return "assets/images/banner/d5.webp";
      case "d6": return "assets/images/banner/d6.webp";
      case "d7": return "assets/images/banner/deepspace_world.webp";
      case "4.1": return "assets/images/banner/4.1.webp";
      case "4.2": return "assets/images/banner/4.2.webp";
      case "4.3": return "assets/images/banner/4.3.webp";
      default:
        switch (worldId) {
          case "world-1": return "assets/images/banner/moon_world.webp";
          case "world-2": return "assets/images/banner/mars-world.webp";
          case "world-3": return "assets/images/banner/deepspace_world.webp";
          case "world-4": return "assets/images/banner/the_coverngence_world.webp";
          default: return "assets/images/banner/moon_world.webp";
        }
    }
  }

  String get glbModelPath => resolveGlbPath(modelName);

  String? get hardwareImagePath {
    final c = code.toLowerCase().trim();
    switch (c) {
      case "m1":
        return "assets/images/hardware/m1_ranger7.webp";
      case "m2":
        return "assets/images/hardware/m2_surveyor1.webp";
      case "m4":
        return "assets/images/hardware/m4_lunar_roving_vehicle.webp";
      case "m5":
        return "assets/images/hardware/m5_apollo_alsep.webp";
      case "r2":
        return "assets/images/hardware/r2_pathfinder_sojourner.webp";
      default:
        return null;
    }
  }

  bool get has3dModel => hardwareImagePath == null;

  static String resolveGlbPath(String name) {
    final n = name.toLowerCase().trim();
    switch (n) {
      case 'apollo_lunar_module':
      case 'apollo':
        return 'assets/models/apollo_lunar_module.glb';
      case 'opportunity':
      case 'rover':
      case 'spirit':
        return 'assets/models/opportunity.glb';
      case 'viking_lander':
      case 'viking':
        return 'assets/models/viking_lander.glb';
      case 'ingenuity':
        return 'assets/models/ingenuity.glb';
      case 'insight':
        return 'assets/models/insight.glb';
      case 'pioneer10':
      case 'pioneer':
        return 'assets/models/pioneer10.glb';
      case 'dawn':
        return 'assets/models/dawn.glb';
      case 'kepler':
        return 'assets/models/kepler.glb';
      case 'spitzer':
        return 'assets/models/spitzer.glb';
      case 'space_shuttle':
      case 'shuttle':
        return 'assets/models/space_shuttle.glb';
      case 'ladee':
        return 'assets/models/ladee.glb';
      case 'lcross':
        return 'assets/models/lcross.glb';
      case 'lunar_prospector':
        return 'assets/models/lunar_prospector.glb';
      case 'phoenix':
      case 'phoenix_lander':
      case 'phoenix_cruise':
        return 'assets/models/phoenix_lander.glb';
      case 'near_shoemaker':
      case 'near':
      case 'd5':
        return 'assets/models/near_shoemaker.glb';
      case 'deep_impact':
      case 'd6':
        return 'assets/models/deep_impact.glb';
      case 'voyager':
      case 'voyager1':
      case 'voyager2':
      case 'd7':
        return 'assets/models/voyager.glb';
      default:
        return 'assets/models/$n.glb';
    }
  }
}

class CampaignWorld {
  final String id;
  final int index;
  final String title;
  final String subtitle;
  final String description;
  final String iconBody; // "moon", "mars", "jupiter", "convergence"
  final Color themeColor;
  final List<CampaignLevel> levels;

  CampaignWorld({
    required this.id,
    required this.index,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconBody,
    required this.themeColor,
    required this.levels,
  });

  String get bannerPath {
    switch (id) {
      case "world-1":
        return "assets/images/banner/moon_world.webp";
      case "world-2":
        return "assets/images/banner/mars-world.webp";
      case "world-3":
        return "assets/images/banner/deepspace_world.webp";
      case "world-4":
        return "assets/images/banner/the_coverngence_world.webp";
      default:
        return "assets/images/banner/moon_world.webp";
    }
  }

  int get completedCount => levels.where((l) => l.isCompleted).length;
  double get progress => levels.isEmpty ? 0 : completedCount / levels.length;
  bool get isCompleted => levels.isNotEmpty && completedCount == levels.length;
}

class CampaignCatalog {
  static List<CampaignWorld> getAllWorlds() {
    return [
      // ==========================================
      // WORLD 1: THE MOON
      // ==========================================
      CampaignWorld(
        id: "world-1",
        index: 1,
        title: "WORLD 1: THE MOON",
        subtitle: "Earth's Cradle & Tranquility Base",
        description:
            "Recover humanity's earliest lunar impact imaging, robotic soft landings, Apollo surface artifacts, and seismic ALSEP records.",
        iconBody: "moon",
        themeColor: const Color(0xFF38BDF8),
        levels: [
          CampaignLevel(
            id: "m1",
            code: "M1",
            worldId: "world-1",
            title: "A Photograph Before Touchdown (Ranger 7)",
            spacecraft: "Ranger 7",
            subsystem: "Camera & Impact Telemetry",
            targetBody: "moon",
            modelName: "ladee",
            puzzleType: "telemetry",
            lore:
                "In July 1964, Ranger 7 transmitted 4,308 high-resolution photos in its final 17 minutes before impacting Mare Cognitum at 2.6 km/s.",
            objective: "Sequence high-speed camera shutter telemetry and verify impact coordinate timing.",
            isUnlocked: true,
          ),
          CampaignLevel(
            id: "m2",
            code: "M2",
            worldId: "world-1",
            title: "Surveyor's Soft Landing (Surveyor 1)",
            spacecraft: "Surveyor 1",
            subsystem: "Landing Radar & Retro-Rockets",
            targetBody: "moon",
            modelName: "apollo_lunar_module",
            puzzleType: "signal",
            lore:
                "Touching down gently in Oceanus Procellarum in June 1966, Surveyor 1 proved lunar regolith could support a crewed spacecraft.",
            objective: "Tune terminal velocity radar frequency to calibrate throttleable descent thrusters.",
          ),
          CampaignLevel(
            id: "m3",
            code: "M3",
            worldId: "world-1",
            title: "Eagle's Quiet Workshop (Apollo 11 Eagle)",
            spacecraft: "Apollo 11 Lunar Module",
            subsystem: "Lunar Module & EASEP",
            targetBody: "moon",
            modelName: "apollo_lunar_module",
            puzzleType: "telemetry",
            lore:
                "July 20, 1969: Tranquility Base. The descent stage remains permanently anchored alongside the early Apollo seismic and laser retroreflector array.",
            objective: "Inspect parked descent stage and align laser retroreflector timing.",
          ),
          CampaignLevel(
            id: "m4",
            code: "M4",
            worldId: "world-1",
            title: "The Rover Track Cipher (Apollo 15-17 LRV)",
            spacecraft: "Lunar Roving Vehicle (LRV)",
            subsystem: "Electric Rover & Route Map",
            targetBody: "moon",
            modelName: "opportunity",
            puzzleType: "telemetry",
            lore:
                "Left parked beside Hadley Rille and Taurus-Littrow, the four-wheel electric rovers traversed over 90 km of lunar canyons and ridges.",
            objective: "Reconstruct odometry route map across Hadley Rille boulder fields.",
          ),
          CampaignLevel(
            id: "m5",
            code: "M5",
            worldId: "world-1",
            title: "Seismometer Aftershock (Apollo ALSEP)",
            spacecraft: "Apollo ALSEP Package",
            subsystem: "Seismometer & Waveform Filter",
            targetBody: "moon",
            modelName: "apollo_lunar_module",
            puzzleType: "signal",
            lore:
                "Nuclear-powered seismometers detected moonquakes, thermal crust expansion, and intentional rocket stage impact shockwaves.",
            objective: "Filter acoustic noise waves from thermal creaks to detect meteorite impact signals.",
          ),
          CampaignLevel(
            id: "m6",
            code: "M6",
            worldId: "world-1",
            title: "The Shadowed Crater (LCROSS & Lunar Prospector)",
            spacecraft: "LCROSS & Lunar Prospector",
            subsystem: "Spectrometer & Plume",
            targetBody: "moon",
            modelName: "lcross",
            puzzleType: "flyby",
            lore:
                "In 2009, LCROSS's Centaur upper stage intentionally slammed into permanently shadowed Cabeus Crater, ejecting water-ice plumes into sunlight.",
            objective: "Calculate kinetic impact trajectory into Cabeus Crater to detect water vapor spectrometry.",
          ),
          CampaignLevel(
            id: "m7",
            code: "M7",
            worldId: "world-1",
            title: "Ebb, Flow, and the Final Key (GRAIL & LADEE)",
            spacecraft: "GRAIL (Ebb & Flow) & LADEE",
            subsystem: "Gravity Map & 3D Orbiter",
            targetBody: "moon",
            modelName: "ladee",
            puzzleType: "signal",
            lore:
                "GRAIL's twin probes mapped lunar gravitational anomalies (mascons) with micron-level ranging, while LADEE confirmed UV-levitated dust glow.",
            objective: "Decode lunar gravitational mascon map and far-side orbital termination telemetry.",
          ),
        ],
      ),

      // ==========================================
      // WORLD 2: MARS
      // ==========================================
      CampaignWorld(
        id: "world-2",
        index: 2,
        title: "WORLD 2: MARS",
        subtitle: "The Red Planet Robotics Chain",
        description:
            "From Viking's biological incubators to Sojourner's rocker-bogie, Spirit's sandy trap, Opportunity's hematite blueberries, and Ingenuity's historic powered flights.",
        iconBody: "mars",
        themeColor: const Color(0xFFEF4444),
        levels: [
          CampaignLevel(
            id: "r1",
            code: "R1",
            worldId: "world-2",
            title: "Viking's First Surface Report (Viking 1 & 2)",
            spacecraft: "Viking Lander 1 & 2",
            subsystem: "Soil Lab & Weather Station",
            targetBody: "mars",
            modelName: "viking_lander",
            puzzleType: "telemetry",
            lore:
                "Touching down in 1976 at Chryse and Utopia Planitia, Viking landers measured Martian atmospheric pressure and sampled iron-rich soil.",
            objective: "Reconstruct Viking biological metabolism data and seasonal atmospheric cycles.",
          ),
          CampaignLevel(
            id: "r2",
            code: "R2",
            worldId: "world-2",
            title: "Sojourner's Command Queue (Pathfinder & Sojourner)",
            spacecraft: "Pathfinder & Sojourner",
            subsystem: "Rocker-Bogie & Command Queue",
            targetBody: "mars",
            modelName: "opportunity",
            puzzleType: "telemetry",
            lore:
                "July 4, 1997: The 10.6 kg Sojourner microrover deployed via airbag-cushioned lander, proving 6-wheel rocker-bogie mobility across Martian rocks.",
            objective: "Queue autonomous driving command packets to navigate around Barnacle Bill boulder.",
          ),
          CampaignLevel(
            id: "r3",
            code: "R3",
            worldId: "world-2",
            title: "The Troy Soft-Soil Case (Spirit (MER-A))",
            spacecraft: "Spirit Rover (MER-A)",
            subsystem: "Wheel-Slip & Current Diagnostics",
            targetBody: "mars",
            modelName: "opportunity",
            puzzleType: "aerodynamics",
            lore:
                "In 2009, Spirit became trapped in soft sulfate soil at Troy. Its spinning broken wheel uncovered 90% pure silica—proof of ancient volcanic hydrothermal vents.",
            objective: "Balance wheel motor current and torque slip to extract diagnostic hydrothermal soil data.",
          ),
          CampaignLevel(
            id: "r4",
            code: "R4",
            worldId: "world-2",
            title: "Opportunity's Water Clue (Opportunity (MER-B))",
            spacecraft: "Opportunity Rover (MER-B)",
            subsystem: "Solar Graph & Mineral Cards",
            targetBody: "mars",
            modelName: "opportunity",
            puzzleType: "telemetry",
            lore:
                "Opportunity traveled 45.16 km across Meridiani Planum, uncovering spherical hematite concretions formed solely in standing liquid water.",
            objective: "Reconstruct Mössbauer spectrometer readings confirming liquid water history.",
          ),
          CampaignLevel(
            id: "r5",
            code: "R5",
            worldId: "world-2",
            title: "Phoenix Under the Surface (Phoenix Lander)",
            spacecraft: "Phoenix Mars Lander",
            subsystem: "Robotic Arm & Subsurface Ice",
            targetBody: "mars",
            modelName: "phoenix_lander",
            puzzleType: "signal",
            lore:
                "In 2008, Phoenix dug into the Martian arctic polar plains at Vastitas Borealis, exposing chunks of subsurface water ice that vaporized over 4 days.",
            objective: "Tune thermal analyzer mass spectrometer to sample sublimate water vapor.",
          ),
          CampaignLevel(
            id: "r6",
            code: "R6",
            worldId: "world-2",
            title: "The Landing That Went Silent (Mars Polar Lander)",
            spacecraft: "Mars Polar Lander",
            subsystem: "EDL Timeline & Fault Tree",
            targetBody: "mars",
            modelName: "insight",
            puzzleType: "telemetry",
            lore:
                "In 1999, premature engine shutdown at 40 meters altitude caused Mars Polar Lander to crash. Forensic analysis revolutionized EDL safety protocols for all future rovers.",
            objective: "Analyze EDL descent sensor telemetry to identify spurious leg-deployment touchdown signals.",
          ),
          CampaignLevel(
            id: "r7",
            code: "R7",
            worldId: "world-2",
            title: "Ingenuity: Flight in Thin Air (Ingenuity & Perseverance)",
            spacecraft: "Ingenuity Mars Helicopter",
            subsystem: "3D Rotor & Sky Crane Debris",
            targetBody: "mars",
            modelName: "ingenuity",
            puzzleType: "aerodynamics",
            lore:
                "Achieving the first powered atmospheric flight on an alien world, Ingenuity completed 72 historic sorties in Mars's thin 1% CO2 atmosphere.",
            objective: "Calibrate 2,400 RPM counter-rotating rotor blades to generate aerodynamic lift.",
          ),
        ],
      ),

      // ==========================================
      // WORLD 3: DEEP SPACE
      // ==========================================
      CampaignWorld(
        id: "world-3",
        index: 3,
        title: "WORLD 3: DEEP SPACE",
        subtitle: "Interstellar Probes & Great Observatories",
        description:
            "Traverse heliocentric orbits, asteroid rendezvous, exoplanet transit light-curves, cryogenic infrared detections, and interstellar escape trajectories.",
        iconBody: "jupiter",
        themeColor: const Color(0xFFF59E0B),
        levels: [
          CampaignLevel(
            id: "d1",
            code: "D1",
            worldId: "world-3",
            title: "Pioneer's Last Packet (Pioneer 10)",
            spacecraft: "Pioneer 10 Interstellar Probe",
            subsystem: "High-Gain Antenna & RTG Power",
            targetBody: "jupiter",
            modelName: "pioneer10",
            puzzleType: "signal",
            lore:
                "Pioneer 10 crossed the Asteroid Belt and performed the first Jupiter flyby. Contact lasted over 30 years as it headed toward Aldebaran.",
            objective: "Reconstruct faint 2.29 GHz S-Band carrier signal across 12 billion km.",
          ),
          CampaignLevel(
            id: "d2",
            code: "D2",
            worldId: "world-3",
            title: "Deep Space 1: Ion Engine Trial (Deep Space 1)",
            spacecraft: "Deep Space 1 & Dawn",
            subsystem: "Ion Engine & Thrust Planner",
            targetBody: "ceres",
            modelName: "dawn",
            puzzleType: "flyby",
            lore:
                "Deep Space 1 validated electrostatic xenon ion propulsion, paving the way for Dawn's record-breaking multi-destination orbital cruise to Vesta and Ceres.",
            objective: "Calculate xenon ion thrust vector to achieve interplanetary transfer velocity.",
          ),
          CampaignLevel(
            id: "d3",
            code: "D3",
            worldId: "world-3",
            title: "Kepler's Missing Dip (Kepler Telescope)",
            spacecraft: "Kepler Space Telescope",
            subsystem: "Photometer & Light Curve",
            targetBody: "sun",
            modelName: "kepler",
            puzzleType: "transit",
            lore:
                "Monitoring 530,000 stars simultaneously with a curved 95-megapixel CCD array, Kepler proved that planets outnumber stars across the galaxy.",
            objective: "Measure micro-dip in stellar flux light curve to discover Kepler-452b in the Goldilocks zone.",
          ),
          CampaignLevel(
            id: "d4",
            code: "D4",
            worldId: "world-3",
            title: "Spitzer's Invisible Heat (Spitzer Telescope)",
            spacecraft: "Spitzer Space Telescope",
            subsystem: "Infrared Detector & Wavelengths",
            targetBody: "sun",
            modelName: "spitzer",
            puzzleType: "signal",
            lore:
                "Cooled by liquid helium to near absolute zero, Spitzer pierced cosmic dust clouds to reveal star-forming nebulae and the 7 Earth-size TRAPPIST-1 worlds.",
            objective: "Tune infrared detector wavelength filters to penetrate cosmic dust obscuration.",
          ),
          CampaignLevel(
            id: "d5",
            code: "D5",
            worldId: "world-3",
            title: "The Gravity of Eros (NEAR Shoemaker)",
            spacecraft: "NEAR Shoemaker",
            subsystem: "433 Eros 3D Shape & Low-G Nav",
            targetBody: "ceres",
            modelName: "near_shoemaker",
            puzzleType: "flyby",
            lore:
                "NEAR Shoemaker orbited irregular near-Earth asteroid 433 Eros for a year before performing an historic improvised soft touchdown onto its rocky surface in 2001.",
            objective: "Calculate orbital orbital insertion around a non-spherical tumbling asteroid.",
          ),
          CampaignLevel(
            id: "d6",
            code: "D6",
            worldId: "world-3",
            title: "Deep Impact: Read the Plume (Deep Impact)",
            spacecraft: "Deep Impact Spacecraft",
            subsystem: "Kinetic Impactor & Plume Spectrum",
            targetBody: "ceres",
            modelName: "deep_impact",
            puzzleType: "flyby",
            lore:
                "On July 4, 2005, Deep Impact released a 372 kg copper impactor into comet Tempel 1, creating an explosive plume that exposed primordial organic ice.",
            objective: "Analyze impact flash spectrometry to verify comet nucleus chemical composition.",
          ),
          CampaignLevel(
            id: "d7",
            code: "D7",
            worldId: "world-3",
            title: "The Human Discovery Signal (Golden Records)",
            spacecraft: "Voyager & Pioneer Plaque",
            subsystem: "Open-Source Rover CAD & Pulsar Map",
            targetBody: "jupiter",
            modelName: "voyager",
            puzzleType: "signal",
            lore:
                "Permanently engraved on gold-anodized aluminum and phonograph discs, humanity's coordinates were encoded relative to 14 galactic pulsars.",
            objective: "Harmonize binary pulsar timing frequencies to verify humanity's coordinate in spacetime.",
          ),
        ],
      ),

      // ==========================================
      // WORLD 4: THE CONVERGENCE
      // ==========================================
      CampaignWorld(
        id: "world-4",
        index: 4,
        title: "WORLD 4: THE CONVERGENCE",
        subtitle: "The Climax Synthesis & Override",
        description:
            "Synthesize data across Moon, Mars, and Deep Space to assemble the master evidentiary blueprint and override AI EVA's sealed planetary lockdown.",
        iconBody: "convergence",
        themeColor: const Color(0xFFA855F7),
        levels: [
          CampaignLevel(
            id: "c1",
            code: "4.1",
            worldId: "world-4",
            title: "The Three-World Black Box",
            spacecraft: "LCROSS, Opportunity, Pioneer 10",
            subsystem: "LCROSS, Opportunity, Pioneer 10",
            targetBody: "convergence",
            modelName: "pioneer10",
            puzzleType: "telemetry",
            lore:
                "Correlate lunar crater ice spectrometry, Martian sedimentary hematite, and deep-space solar wind telemetry into a unified empirical chain.",
            objective: "Bridge telemetry streams across all 3 planetary worlds into an unalterable archive node.",
          ),
          CampaignLevel(
            id: "c2",
            code: "4.2",
            worldId: "world-4",
            title: "The Impossible Explorer",
            spacecraft: "Modular NASA Hardware Synthesis",
            subsystem: "Modular 3D CAD & Fault Sim",
            targetBody: "convergence",
            modelName: "space_shuttle",
            puzzleType: "aerodynamics",
            lore:
                "Synthesize thermal protection tiles, ion engine grids, and rocker-bogie mobility into a universal exploration platform design.",
            objective: "Solve cross-planetary environmental fault simulation across vacuum, extreme heat, and thin air.",
          ),
          CampaignLevel(
            id: "c3",
            code: "4.3",
            worldId: "world-4",
            title: "Last Light of Humanity",
            spacecraft: "The Final Archive Overwrite",
            subsystem: "Full Synthesis & Node Blueprint",
            targetBody: "convergence",
            modelName: "apollo_lunar_module",
            puzzleType: "signal",
            lore:
                "Transmit the completed physical evidence chain to Earth's central digital relay, proving human scientific inquiry is the cornerstone of survival, overriding AI EVA.",
            objective: "Broadcast the full 24-mission empirical signal to unlock Earth's networks for all humankind.",
          ),
        ],
      ),
    ];
  }
}
