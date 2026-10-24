import 'clue_data.dart';

class MissionData {
  final String id;
  final String title;
  final String era;
  final String destination;
  final String hardware;
  final String modelName;
  final String objective;
  final String historicalContext;
  final String scientificPrinciple;
  final String targetBody;
  final List<ClueData> clues;
  final List<String> supportedPuzzles;

  MissionData({
    required this.id,
    required this.title,
    required this.era,
    required this.destination,
    required this.hardware,
    required this.modelName,
    required this.objective,
    required this.historicalContext,
    required this.scientificPrinciple,
    required this.targetBody,
    required this.clues,
    required this.supportedPuzzles,
  });

  int get unlockedCluesCount => clues.where((c) => c.unlocked).length;
  bool get isCompleted => unlockedCluesCount == clues.length;
}

class MissionsCatalog {
  static List<MissionData> getAllMissions() {
    return [
      MissionData(
        id: "mission-01",
        title: "MISSION 01 — FIRST SIGNAL",
        era: "Pioneer Era (1970–1989)",
        destination: "Deep Space / Heliocentric",
        hardware: "Pioneer 10 Interstellar Probe",
        modelName: "pioneer10",
        objective: "Reconstruct lost Pioneer telemetry carrier wave and inspect deep-space hardware.",
        historicalContext:
            "Launched on March 2, 1972, Pioneer 10 was the first human artifact to transit the Asteroid Belt and encounter Jupiter. Contact was maintained for over 30 years until 2003 as it traversed deep space on an interstellar escape trajectory.",
        scientificPrinciple:
            "Deep-space communication relies on precise radio frequency matching, parabolic dish alignment, and Doppler velocity calculation.",
        targetBody: "jupiter",
        supportedPuzzles: ["signal", "flyby", "telemetry"],
        clues: [
          ClueData(
            id: "m01-c01",
            code: "CLUE A",
            type: "Environmental",
            rarity: ClueRarity.normal,
            title: "Parabolic Alignment",
            desc: "Pioneer 10's 2.74-meter high-gain antenna must maintain continuous directional lock with Earth's Deep Space Network.",
          ),
          ClueData(
            id: "m01-c02",
            code: "CLUE B",
            type: "Scientific Principle",
            rarity: ClueRarity.normal,
            title: "Doppler Velocity Shift",
            desc: "Frequency deviation between transmitted and received signals directly reveals spacecraft acceleration relative to Earth.",
          ),
          ClueData(
            id: "m01-c03",
            code: "CLUE C",
            type: "Engineering",
            rarity: ClueRarity.normal,
            title: "SNAP-19 RTG Power",
            desc: "Four radioisotope thermoelectric generators provide continuous nuclear decay power millions of kilometers beyond solar reach.",
          ),
          ClueData(
            id: "m01-c04",
            code: "CLUE D",
            type: "Historical Evidence",
            rarity: ClueRarity.hidden,
            title: "Jovian Slingshot",
            desc: "Jupiter's intense gravitational gradient accelerated Pioneer 10 onto a solar escape trajectory toward Aldebaran.",
          ),
          ClueData(
            id: "m01-c05",
            code: "CLUE E",
            type: "Master Signal",
            rarity: ClueRarity.master,
            title: "The Golden Plaque Map",
            desc: "The etched plaque uses 14 galactic pulsars with binary timing frequencies to permanently encode humanity's spacetime coordinate.",
          ),
        ],
      ),
      MissionData(
        id: "mission-02",
        title: "MISSION 02 — THE LUNAR ARCHIVE",
        era: "Apollo & Early Lunar Era (1969–1972)",
        destination: "The Moon (Sea of Tranquility)",
        hardware: "Apollo Lunar Module Eagle & LADEE",
        modelName: "apollo_lunar_module",
        objective: "Examine parked surface hardware at Tranquility Base and calibrate lunar seismic instruments.",
        historicalContext:
            "On July 20, 1969, Apollo 11's Lunar Module Eagle descent stage touched down. Hardware intentionally left on the lunar surface includes the descent engine, laser retroreflector, and early seismometer packages.",
        scientificPrinciple:
            "Passive seismology uses natural and controlled impact waves to determine planetary mantle and crust thickness.",
        targetBody: "moon",
        supportedPuzzles: ["telemetry", "signal"],
        clues: [
          ClueData(
            id: "m02-c01",
            code: "CLUE A",
            type: "Environmental",
            rarity: ClueRarity.normal,
            title: "Descent Stage Anchor",
            desc: "The descent stage served as a stationary launch platform, remaining permanently anchored at Tranquility Base.",
          ),
          ClueData(
            id: "m02-c02",
            code: "CLUE B",
            type: "Scientific Principle",
            rarity: ClueRarity.normal,
            title: "Laser Range Timing",
            desc: "Corner-cube retroreflectors reflect Earth lasers with millimetric precision, proving the Moon is receding at 3.8 cm per year.",
          ),
          ClueData(
            id: "m02-c03",
            code: "CLUE C",
            type: "Engineering",
            rarity: ClueRarity.normal,
            title: "Throttleable Descent Engine",
            desc: "Variable-thrust rocket engines allowed human pilots to hover, maneuver, and land gently in a 1/6th gravity environment.",
          ),
          ClueData(
            id: "m02-c04",
            code: "CLUE D",
            type: "Historical Evidence",
            rarity: ClueRarity.hidden,
            title: "EASEP Seismic Records",
            desc: "The early Apollo seismic package detected micrometeorite impacts and thermal expansion tremors.",
          ),
          ClueData(
            id: "m02-c05",
            code: "CLUE E",
            type: "Master Signal",
            rarity: ClueRarity.master,
            title: "Lunar Regolith Horizon",
            desc: "LADEE verified that solar ultraviolet radiation lofted electrostatically charged dust grains above the lunar terminator.",
          ),
        ],
      ),
      MissionData(
        id: "mission-03",
        title: "MISSION 03 — THE ASTEROID FRONTIER",
        era: "Ion Propulsion Era (2007–2018)",
        destination: "Asteroid Belt (Ceres & Vesta)",
        hardware: "Dawn Ion Propulsion Spacecraft",
        modelName: "dawn",
        objective: "Calibrate xenon ion propulsion grids and detect subsurface hydrogen ice signatures.",
        historicalContext:
            "Launched in 2007, NASA's Dawn became the first spacecraft to orbit two separate extraterrestrial destinations—proto-planet Vesta and dwarf planet Ceres—relying entirely on high-efficiency xenon ion engines.",
        scientificPrinciple:
            "Electrostatic ion thrusters accelerate xenon atoms with electric fields to over 30 km/s, providing 10x higher propellant efficiency than chemical combustion.",
        targetBody: "ceres",
        supportedPuzzles: ["telemetry", "flyby"],
        clues: [
          ClueData(
            id: "m03-c01",
            code: "CLUE A",
            type: "Engineering",
            rarity: ClueRarity.normal,
            title: "Xenon Ion Acceleration Grid",
            desc: "Molybdenum electrostatic accelerator grids expel positive xenon ions at 30 km/s for continuous months of thrust.",
          ),
          ClueData(
            id: "m03-c02",
            code: "CLUE B",
            type: "Environmental",
            rarity: ClueRarity.normal,
            title: "Ceres Bright Faculae",
            desc: "Occator Crater's luminous white spots are crystallized sodium carbonate salts deposited by ancient hydrothermal brines.",
          ),
          ClueData(
            id: "m03-c03",
            code: "CLUE C",
            type: "Scientific Principle",
            rarity: ClueRarity.normal,
            title: "Specific Impulse Efficiency",
            desc: "Operating at a specific impulse > 3,100 seconds, Dawn achieved a record 11.5 km/s delta-v using only 425 kg of xenon gas.",
          ),
          ClueData(
            id: "m03-c04",
            code: "CLUE D",
            type: "Historical Evidence",
            rarity: ClueRarity.hidden,
            title: "Rheasilvia Impact Basin",
            desc: "Vesta's 505 km impact basin excavated basaltic crust, proving early asteroid melting and planetesimal differentiation.",
          ),
          ClueData(
            id: "m03-c05",
            code: "CLUE E",
            type: "Master Signal",
            rarity: ClueRarity.master,
            title: "GRaND Water-Ice Signature",
            desc: "The Gamma Ray & Neutron Detector confirmed dwarf planet Ceres possesses an ice-rich rocky mantle with 25% water by mass.",
          ),
        ],
      ),
      MissionData(
        id: "mission-04",
        title: "MISSION 04 — THE RED PLANET",
        era: "Red Planet Expansion (1976–2021)",
        destination: "Mars (Meridiani Planum / Jezero)",
        hardware: "Opportunity Rover, Viking & Ingenuity",
        modelName: "viking_lander",
        objective: "Analyze Martian soil composition, rover navigation paths, and aerial aerodynamics.",
        historicalContext:
            "From Viking's biological experiments in 1976 to Opportunity's 45 km marathon and Ingenuity's powered aerial flights, Mars exploration transformed from isolated landings into an active chain of scientific evidence.",
        scientificPrinciple:
            "Thin-atmosphere aerodynamics requires ultra-high rotor RPM (~2400 RPM) to produce lift in 1% Earth air density.",
        targetBody: "mars",
        supportedPuzzles: ["aerodynamics", "telemetry"],
        clues: [
          ClueData(
            id: "m04-c01",
            code: "CLUE A",
            type: "Environmental",
            rarity: ClueRarity.normal,
            title: "Hematite Blueberries",
            desc: "Opportunity discovered spherical hematite concretions formed solely inside ancient liquid groundwater.",
          ),
          ClueData(
            id: "m04-c02",
            code: "CLUE B",
            type: "Scientific Principle",
            rarity: ClueRarity.normal,
            title: "Rotor Lift in 1% Air",
            desc: "Ingenuity's carbon-fiber counter-rotating blades overcome the extreme thinness of the Martian atmosphere.",
          ),
          ClueData(
            id: "m04-c03",
            code: "CLUE C",
            type: "Engineering",
            rarity: ClueRarity.normal,
            title: "Rocker-Bogie Mobility",
            desc: "The rocker-bogie suspension keeps all 6 wheels on uneven rocky terrain without springs, preventing chassis roll.",
          ),
          ClueData(
            id: "m04-c04",
            code: "CLUE D",
            type: "Historical Evidence",
            rarity: ClueRarity.hidden,
            title: "Viking Weather Station",
            desc: "Continuous meteorological monitoring confirmed seasonal carbon dioxide freezing and atmospheric pressure cycling.",
          ),
          ClueData(
            id: "m04-c05",
            code: "CLUE E",
            type: "Master Signal",
            rarity: ClueRarity.master,
            title: "Chain of Water Evidence",
            desc: "Geological layering in sedimentary rock proves Mars was once warm, wet, and habitable for sustained geological eras.",
          ),
        ],
      ),
      MissionData(
        id: "mission-05",
        title: "MISSION 05 — THE EXOPLANET OBSERVATORY",
        era: "Exoplanet Era (2009–2018)",
        destination: "Earth-Trailing Orbit (Cygnus Constellation)",
        hardware: "Kepler Space Telescope & Spitzer",
        modelName: "kepler",
        objective: "Calibrate Kepler's photometer array to detect micro-dips in stellar flux caused by transiting alien worlds.",
        historicalContext:
            "Launched on March 7, 2009, Kepler observed over 530,000 stars, discovering 2,662 confirmed alien worlds via transit photometry, proving planets outnumber stars across our galaxy.",
        scientificPrinciple:
            "Transit photometry measures the micro-dip in stellar brightness (< 0.01%) when an exoplanet passes in front of its star, directly determining planetary radius.",
        targetBody: "sun",
        supportedPuzzles: ["transit", "telemetry"],
        clues: [
          ClueData(
            id: "m05-c01",
            code: "CLUE A",
            type: "Engineering",
            rarity: ClueRarity.normal,
            title: "Curved 95-Megapixel CCD Focal Plane",
            desc: "A curved mosaic array of 42 CCD sensors compensated for telescope optical field curvature without glass lenses.",
          ),
          ClueData(
            id: "m05-c02",
            code: "CLUE B",
            type: "Scientific Principle",
            rarity: ClueRarity.normal,
            title: "Transit Photometry Light Curve",
            desc: "The ratio of brightness drop equals the ratio of planet area to star area: Delta F / F = (Rp / Rstar)^2.",
          ),
          ClueData(
            id: "m05-c03",
            code: "CLUE C",
            type: "Engineering",
            rarity: ClueRarity.normal,
            title: "Reaction Wheel Pointing Stability",
            desc: "Gyroscopic reaction wheels maintained pointing precision to 0.009 arcseconds to detect parts-per-million photon variations.",
          ),
          ClueData(
            id: "m05-c04",
            code: "CLUE D",
            type: "Historical Evidence",
            rarity: ClueRarity.hidden,
            title: "Habitable Zone Alien Worlds",
            desc: "Kepler-452b and Kepler-186f confirmed rocky terrestrial planets orbit within liquid water habitable Goldilocks zones.",
          ),
          ClueData(
            id: "m05-c05",
            code: "CLUE E",
            type: "Master Signal",
            rarity: ClueRarity.master,
            title: "Spitzer Cryogenic Infrared",
            desc: "Liquid helium cooled detectors measured atmospheric thermal emission from exoplanet cloud decks.",
          ),
        ],
      ),
      MissionData(
        id: "mission-06",
        title: "MISSION 06 — THE ASTEROID FRONTIER II",
        era: "Ion Propulsion Era (2007–2018)",
        destination: "Asteroid Belt (Ceres & Vesta)",
        hardware: "Dawn Ion Propulsion Spacecraft",
        modelName: "dawn",
        objective: "Calibrate xenon ion thruster grids and detect subsurface hydrogen ice signatures at Occator Crater.",
        historicalContext:
            "Operating in the asteroid belt, Dawn uncovered the contrasting geologies of dry protoplanet Vesta and ice-rich dwarf planet Ceres.",
        scientificPrinciple:
            "Ion propulsion provides continuous low thrust with unprecedented propellant economy across interplanetary distances.",
        targetBody: "ceres",
        supportedPuzzles: ["telemetry", "flyby"],
        clues: [
          ClueData(id: "m06-c01", code: "CLUE A", type: "Engineering", rarity: ClueRarity.normal, title: "Xenon Ion Acceleration Grid", desc: "Molybdenum electrostatic accelerator grids expel positive xenon ions at 30 km/s."),
          ClueData(id: "m06-c02", code: "CLUE B", type: "Environmental", rarity: ClueRarity.normal, title: "Ceres Bright Faculae", desc: "Occator Crater luminous white spots are crystallized sodium carbonate salts."),
          ClueData(id: "m06-c03", code: "CLUE C", type: "Scientific Principle", rarity: ClueRarity.normal, title: "Specific Impulse Efficiency", desc: "Achieved record 11.5 km/s delta-v with 425 kg xenon at >3,100 sec Isp."),
          ClueData(id: "m06-c04", code: "CLUE D", type: "Historical Evidence", rarity: ClueRarity.hidden, title: "Rheasilvia Impact Basin", desc: "Excavated Vesta's basaltic mantle, proving early asteroid differentiation."),
          ClueData(id: "m06-c05", code: "CLUE E", type: "Master Signal", rarity: ClueRarity.master, title: "GRaND Water-Ice Signature", desc: "Confirmed Ceres possesses an ice-rich rocky mantle with 25% water by mass."),
        ],
      ),
      MissionData(
        id: "mission-07",
        title: "MISSION 07 — THE EXOPLANET HUNTER",
        era: "Deep Space Observatories (2009–2018)",
        destination: "Earth-Trailing Heliocentric Orbit",
        hardware: "Kepler Space Telescope",
        modelName: "kepler",
        objective: "Reconstruct Kepler photometer light curve measurements to confirm transiting terrestrial worlds.",
        historicalContext:
            "Operating from 2009 to 2018, Kepler proved that planets outnumber stars across our galaxy by monitoring 530,000 stars simultaneously.",
        scientificPrinciple:
            "Transit depth equals the square of the ratio of planetary radius to stellar radius (ΔF/F = (Rp/R*)²).",
        targetBody: "sun",
        supportedPuzzles: ["transit", "signal"],
        clues: [
          ClueData(id: "m07-c01", code: "CLUE A", type: "Engineering", rarity: ClueRarity.normal, title: "42 CCD Photometer Array", desc: "Monitored 115 square degrees of the Cygnus constellation."),
          ClueData(id: "m07-c02", code: "CLUE B", type: "Scientific Principle", rarity: ClueRarity.normal, title: "Periodic Transit Signatures", desc: "Orbital period is derived via Kepler's Third Law from recurrence time."),
          ClueData(id: "m07-c03", code: "CLUE C", type: "Engineering", rarity: ClueRarity.normal, title: "Solar Radiation Pressure Trim", desc: "Balanced telescope pointing during K2 using solar photon pressure."),
          ClueData(id: "m07-c04", code: "CLUE D", type: "Historical Evidence", rarity: ClueRarity.hidden, title: "Kepler-186f Earth-Size World", desc: "First validated Earth-sized exoplanet in a red dwarf habitable zone."),
          ClueData(id: "m07-c05", code: "CLUE E", type: "Master Signal", rarity: ClueRarity.master, title: "Planetary Abundance Law", desc: "Average star systems host 1.6 planets, changing humanity's cosmic perspective."),
        ],
      ),
      MissionData(
        id: "mission-08",
        title: "MISSION 08 — THE LUNAR ATMOSPHERE",
        era: "Lunar Reconnaissance Era (2013–2014)",
        destination: "Moon (Far Side Orbit & Exosphere)",
        hardware: "LADEE Lunar Dust & Exosphere Explorer",
        modelName: "ladee",
        objective: "Analyze electrostatically levitated lunar dust grains and sample exospheric helium and argon.",
        historicalContext:
            "Launched on September 6, 2013, LADEE investigated the fragile lunar exosphere and confirmed that ultraviolet sunlight lofted microscopic regolith particles along the terminator line before deliberately impacting the far side in 2014.",
        scientificPrinciple:
            "Photoelectric charging by solar UV ejects electrons from regolith grains, building positive surface potentials that levitate dust particles into a glowing lunar horizon glow.",
        targetBody: "moon",
        supportedPuzzles: ["signal", "telemetry"],
        clues: [
          ClueData(id: "m08-c01", code: "CLUE A", type: "Engineering", rarity: ClueRarity.normal, title: "LDEX Impact Ionization Detector", desc: "Measured electric charges when high-velocity lunar dust grains struck a target plate."),
          ClueData(id: "m08-c02", code: "CLUE B", type: "Environmental", rarity: ClueRarity.normal, title: "Electrostatic Dust Fountains", desc: "Verified astronaut sketches from Apollo 17 showing lunar horizon glow."),
          ClueData(id: "m08-c03", code: "CLUE C", type: "Scientific Principle", rarity: ClueRarity.normal, title: "Exospheric Gas Sputtering", desc: "Solar wind ions sputter atoms directly off rocks, creating tenuous atmospheres."),
          ClueData(id: "m08-c04", code: "CLUE D", type: "Engineering", rarity: ClueRarity.hidden, title: "LLCD Pulsed Laser Comms", desc: "First deep-space optical laser link, transmitting to Earth at 622 Mbps."),
          ClueData(id: "m08-c05", code: "CLUE E", type: "Master Signal", rarity: ClueRarity.master, title: "Far Side Controlled Impact", desc: "At mission end on April 18, 2014, LADEE impacted Sundman V crater at 5,800 km/h."),
        ],
      ),
      MissionData(
        id: "mission-09",
        title: "MISSION 09 — AERIAL FLIGHT ON MARS",
        era: "Planetary Aviation Era (2021–2024)",
        destination: "Mars (Jezero Crater / Neretva Vallis)",
        hardware: "Ingenuity Mars Helicopter",
        modelName: "ingenuity",
        objective: "Test counter-rotating carbon fiber rotor lift in 1% atmospheric pressure and scout rover pathways.",
        historicalContext:
            "Arriving attached to Perseverance's belly in 2021, Ingenuity achieved the Wright Brothers moment on another planet. Originally planned for 5 test flights, it completed 72 historic flights covering over 17 km until rotor tip damage in 2024.",
        scientificPrinciple:
            "Lift in thin 0.01-bar CO2 atmosphere requires 2,400 to 2,700 RPM rotor speed, specialized low-Reynolds airfoils, and an ultralight 1.8 kg chassis.",
        targetBody: "mars",
        supportedPuzzles: ["aerodynamics", "telemetry"],
        clues: [
          ClueData(id: "m09-c01", code: "CLUE A", type: "Engineering", rarity: ClueRarity.normal, title: "Coaxial Carbon-Fiber Blades", desc: "Dual 1.2-meter counter-rotating rotor blades cancel torque without a tail rotor."),
          ClueData(id: "m09-c02", code: "CLUE B", type: "Scientific Principle", rarity: ClueRarity.normal, title: "Low-Reynolds Aerodynamics", desc: "Aerodynamic lift generation at low atmospheric densities with high-camber blade profiles."),
          ClueData(id: "m09-c03", code: "CLUE C", type: "Engineering", rarity: ClueRarity.normal, title: "Autonomous Visual Odometry", desc: "Down-looking 30 Hz cameras map ground features in real time without GPS."),
          ClueData(id: "m09-c04", code: "CLUE D", type: "Environmental", rarity: ClueRarity.hidden, title: "Jezero Delta Reconnaissance", desc: "Scouted ancient river delta deposits and boulder fields to optimize rover routes."),
          ClueData(id: "m09-c05", code: "CLUE E", type: "Master Signal", rarity: ClueRarity.master, title: "72 Historic Planetary Flights", desc: "Completed 72 sorties over 1,000 Martian sols, proving alien powered flight."),
        ],
      ),
      MissionData(
        id: "mission-10",
        title: "MISSION 10 — THE REUSABLE FLEET",
        era: "Space Shuttle Era (1981–2011)",
        destination: "Low Earth Orbit (LEO)",
        hardware: "Space Shuttle Orbiter",
        modelName: "space_shuttle",
        objective: "Inspect orbiter thermal protection tiles, pilot SSME main engine burns, and deploy orbital payloads.",
        historicalContext:
            "Flying 135 missions between 1981 and 2011, NASA's Space Shuttle fleet deployed the Hubble Space Telescope, assembled the International Space Station, and pioneered reusable winged spacecraft.",
        scientificPrinciple:
            "Orbital velocity (~28,000 km/h) creates intense hypersonic atmospheric compression during reentry, requiring silica ceramic thermal tiles capable of withstanding 1,650°C.",
        targetBody: "earth",
        supportedPuzzles: ["aerodynamics", "telemetry"],
        clues: [
          ClueData(id: "m10-c01", code: "CLUE A", type: "Engineering", rarity: ClueRarity.normal, title: "HRSI Silica Ceramic Tiles", desc: "Over 24,000 individual tiles absorb and dissipate hypersonic reentry shock heating."),
          ClueData(id: "m10-c02", code: "CLUE B", type: "Scientific Principle", rarity: ClueRarity.normal, title: "Orbital Mechanics & Delta-V", desc: "Reaching a 300 km orbit requires ~9.5 km/s delta-v from SRBs and SSME liquid engines."),
          ClueData(id: "m10-c03", code: "CLUE C", type: "Engineering", rarity: ClueRarity.normal, title: "SSME Staged Combustion Cycle", desc: "Three LH2/LOX engines operating at 20 MPa chamber pressure with 452s vacuum Isp."),
          ClueData(id: "m10-c04", code: "CLUE D", type: "Historical Evidence", rarity: ClueRarity.hidden, title: "Hubble Repair & ISS Assembly", desc: "Extravehicular spacewalks and the Canadarm robotic arm deployed and serviced great observatories."),
          ClueData(id: "m10-c05", code: "CLUE E", type: "Master Signal", rarity: ClueRarity.master, title: "135 Winged Space Missions", desc: "Carried 355 astronauts and 1.6 million kg of scientific cargo across 3 decades."),
        ],
      ),
    ];
  }
}
