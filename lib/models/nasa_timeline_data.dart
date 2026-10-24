class TimelineItem {
  final String year;
  final String name;
  final String target;
  final String type;
  final String status;
  final String details;

  TimelineItem({
    required this.year,
    required this.name,
    required this.target,
    required this.type,
    required this.status,
    required this.details,
  });
}

class TimelineEra {
  final String title;
  final String subtitle;
  final List<TimelineItem> items;

  TimelineEra({
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

class NasaTimelineCatalog {
  static List<TimelineEra> getEras() {
    return [
      TimelineEra(
        title: "1. The Pioneer Era (1960–1969)",
        subtitle: "Early Probes, Lunar Impactors & Apollo 11",
        items: [
          TimelineItem(
            year: "1962",
            name: "Mariner 2",
            target: "Venus / Heliocentric",
            type: "Unmanned Flyby",
            status: "Inactive in Heliocentric Orbit",
            details: "First successful interplanetary flyby stage; confirmed superheated 430°C surface of Venus.",
          ),
          TimelineItem(
            year: "1964–1965",
            name: "Ranger Program (Ranger 7, 8, 9)",
            target: "Moon (Mare Cognitum, Tranquillitatis)",
            type: "Unmanned Impact Probes",
            status: "Impact Debris on Lunar Surface",
            details: "High-speed impact imaging probes that returned 17,000 close-up photos before crashing into lunar craters.",
          ),
          TimelineItem(
            year: "1966–1968",
            name: "Surveyor Program (Surveyor 1, 3, 5, 6, 7)",
            target: "Moon (Ocean of Storms)",
            type: "Robotic Soft Landers",
            status: "Parked on Lunar Surface",
            details: "Demonstrated soft landing mechanics; Surveyor 3 was later visited by Apollo 12 astronauts in 1969.",
          ),
          TimelineItem(
            year: "1969",
            name: "Apollo 11 Eagle Descent Stage",
            target: "Moon (Sea of Tranquility)",
            type: "Manned Landing",
            status: "Permanent Heritage Artifact",
            details: "Descent engine stage, laser reflector, seismic package, boots, and plaque left at Tranquility Base.",
          ),
        ],
      ),
      TimelineEra(
        title: "2. Apollo & Deep Space Exploration (1970–1989)",
        subtitle: "Lunar Bases, Viking & Interstellar Probes",
        items: [
          TimelineItem(
            year: "1969–1972",
            name: "Apollo 12, 14, 15, 16, 17 Descent Stages",
            target: "Moon (Multiple Surface Sites)",
            type: "Manned Landers",
            status: "Surfaced on Moon",
            details: "Intrepid, Antares, Falcon, Orion, and Challenger descent stages with ALSEP nuclear power packages.",
          ),
          TimelineItem(
            year: "1971–1972",
            name: "Apollo Lunar Roving Vehicles (LRV 1–3)",
            target: "Moon (Hadley, Descartes, Taurus-Littrow)",
            type: "Electric Rovers",
            status: "Parked on Surface",
            details: "Battery-powered crewed rover chassis left parked next to Fallen Astronaut memorial statuette.",
          ),
          TimelineItem(
            year: "1972",
            name: "Pioneer 10 Interstellar Probe",
            target: "Jupiter / Interstellar Space",
            type: "Deep Space Probe",
            status: "Traversing Interstellar Escape Trajectory",
            details: "First probe to cross asteroid belt and image Jupiter. Heading toward Aldebaran with the Golden Plaque.",
          ),
          TimelineItem(
            year: "1976",
            name: "Viking 1 & Viking 2 Landers",
            target: "Mars (Chryse & Utopia Planitia)",
            type: "Robotic Landers",
            status: "Inactive on Martian Surface",
            details: "First long-duration surface science stations on Mars; operated biological experiments and weather sensors.",
          ),
        ],
      ),
      TimelineEra(
        title: "3. Modern Mars & Deep Space Era (1990–Present)",
        subtitle: "Rovers, Telescopes & Ion Propulsion",
        items: [
          TimelineItem(
            year: "2004–2018",
            name: "Opportunity Rover (MER-B)",
            target: "Mars (Meridiani Planum)",
            type: "Solar-Powered Rover",
            status: "Parked in Perseverance Valley",
            details: "Traveled 45.16 km over 14 years, discovering sedimentary hematite blueberries formed in ancient water.",
          ),
          TimelineItem(
            year: "2007–2018",
            name: "Dawn Ion Spacecraft",
            target: "Asteroid Belt (Ceres & Vesta)",
            type: "Ion Propulsion Orbiter",
            status: "Stable Orbit around Ceres",
            details: "First spacecraft to orbit two separate planetary bodies; mapped subsurface water ice and bright sodium carbonate faculae.",
          ),
          TimelineItem(
            year: "2009–2018",
            name: "Kepler Space Telescope",
            target: "Earth-Trailing Heliocentric Orbit",
            type: "Photometer Observatory",
            status: "Derelict in Heliocentric Orbit",
            details: "Discovered 2,662 confirmed exoplanets by observing stellar light curve micro-dips across 530,000 stars.",
          ),
          TimelineItem(
            year: "2013–2014",
            name: "LADEE Lunar Explorer",
            target: "Moon (Exosphere)",
            type: "Lunar Science Orbiter",
            status: "Impacted Sundman V Crater",
            details: "Sampled dust levitation caused by solar UV charging; deliberately impacted lunar far side.",
          ),
          TimelineItem(
            year: "2021–2024",
            name: "Ingenuity Mars Helicopter",
            target: "Mars (Jezero Crater)",
            type: "Rotorcraft Drone",
            status: "Parked at Neretva Vallis",
            details: "Proved powered atmospheric flight on Mars with 72 historic sorties in 1% Earth air density.",
          ),
        ],
      ),
    ];
  }
}
