import Foundation
import CoreGraphics
import Combine

struct GeoQuestion: Identifiable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct GeoQuest: Identifiable {
    let id: String
    let title: String
    let topic: String
    let zoneName: String
    let npcName: String
    let npcShapeColor: String
    let position: CGPoint
    let storyText: String
    let fieldNotes: [String]
    let question: GeoQuestion
    var isCompleted: Bool = false
}

struct PollutionEnemy: Identifiable {
    let id: String
    let name: String
    let pollutionType: String
    let position: CGPoint
    let topicLesson: String
    let question: GeoQuestion
    var isPurified: Bool = false
}

class GeographyCurriculum: ObservableObject {
    @Published var quests: [GeoQuest] = [
        GeoQuest(
            id: "patterns",
            title: "The Scattered Paws",
            topic: "Settlement Patterns",
            zoneName: "Whispering Hills",
            npcName: "Barnaby the Farm Cat",
            npcShapeColor: "orange",
            position: CGPoint(x: -550, y: 450),
            storyText: "Meow! My cousins live far apart across these hills to tend large farms, while river cats build in long rows along the stream. Help me classify our settlements!",
            fieldNotes: [
                "• Dispersed: Isolated buildings spread out over a wide area (common in hilly farming regions).",
                "• Linear: Buildings arranged in a long line along a road, river, or valley.",
                "• Nucleated: Buildings tightly clustered around a central point like a crossroads or bridge."
            ],
            question: GeoQuestion(
                prompt: "A village develops tightly around a bridge and a central market square. What settlement pattern is this?",
                options: ["Dispersed", "Linear", "Nucleated", "Conurbation"],
                correctIndex: 2,
                explanation: "Explanation: Nucleated settlements cluster tightly around a central feature like a crossroads, water source, or bridge because it provides shared social and economic benefits."
            )
        ),
        GeoQuest(
            id: "hierarchy",
            title: "From Den to Metropolis",
            topic: "Settlement Hierarchy",
            zoneName: "Central Valley",
            npcName: "Mayor Whiskers",
            npcShapeColor: "purple",
            position: CGPoint(x: -100, y: 150),
            storyText: "We're mapping the feline kingdom from smallest to largest! Can you verify our Settlement Hierarchy?",
            fieldNotes: [
                "Hierarchy (Smallest → Largest):",
                "1. Isolated Dwelling → 2. Hamlet → 3. Village",
                "4. Small Town → 5. Large Town → 6. City → 7. Conurbation."
            ],
            question: GeoQuestion(
                prompt: "When several expanding cities grow outward and merge into one continuous urban area, what is it called?",
                options: ["Hamlet", "Conurbation", "Isolated Dwelling", "Village"],
                correctIndex: 1,
                explanation: "Explanation: A conurbation forms when multiple previously separate towns or cities expand so much that they merge into a single massive urban zone."
            )
        ),
        GeoQuest(
            id: "services",
            title: "The Fish Market Dilemma",
            topic: "Order of Goods & Sphere of Influence",
            zoneName: "Meowtropolis CBD",
            npcName: "Chef Cleo",
            npcShapeColor: "cyan",
            position: CGPoint(x: 480, y: 380),
            storyText: "Cats travel 10 minutes for milk, but 2 hours for my rare Golden Tuna Sushi! Help me explain why.",
            fieldNotes: [
                "• Low-Order Goods: Daily essentials (milk, bread). Small threshold population & small sphere of influence.",
                "• High-Order Goods: Expensive/specialist items. Large threshold population & wide sphere of influence.",
                "• Sphere of Influence: The geographic area served by a settlement or service."
            ],
            question: GeoQuestion(
                prompt: "Why does a specialist feline heart hospital have a much larger Sphere of Influence than a corner milk shop?",
                options: [
                    "It sells low-order convenience goods",
                    "It requires a larger threshold population and people travel further for high-order services",
                    "It is located in a dispersed hamlet",
                    "Milk shops have a higher range"
                ],
                correctIndex: 1,
                explanation: "Explanation: High-order services are rare, so customers are willing to travel much longer distances (greater range) to access them compared to everyday items."
            )
        ),
        GeoQuest(
            id: "rural_urban",
            title: "Country Mouse vs City Cat",
            topic: "Rural vs. Urban Areas",
            zoneName: "The Greenbelt Border",
            npcName: "Scout Milo",
            npcShapeColor: "green",
            position: CGPoint(x: -500, y: -250),
            storyText: "Look at the contrast across this border! High-rise towers on one side, open pastures on the other.",
            fieldNotes: [
                "• Urban Areas: High population density, built-up infrastructure, secondary/tertiary jobs, higher land value.",
                "• Rural Areas: Low population density, open countryside, primary sector jobs (farming, forestry)."
            ],
            question: GeoQuestion(
                prompt: "Which characteristic is typically associated with an URBAN area rather than a rural area?",
                options: [
                    "Predominantly primary sector employment",
                    "Low population density and dispersed housing",
                    "High land values and vertical high-rise building density",
                    "Lack of public transit networks"
                ],
                correctIndex: 2,
                explanation: "Explanation: High land values in cities drive developers to build vertically (skyscrapers) to maximize space usage."
            )
        ),
        GeoQuest(
            id: "mangroves",
            title: "Guardians of the Coast",
            topic: "Mangrove Root Adaptations",
            zoneName: "Tidal Mangrove Swamp",
            npcName: "Captain Marina",
            npcShapeColor: "blue",
            position: CGPoint(x: 520, y: -420),
            storyText: "Storm surges are approaching! Our mangrove forest protects the coast, and each root type has a special superpower.",
            fieldNotes: [
                "• Prop Roots: Arch above water to anchor trees in shifting mud.",
                "• Pneumatophores (Pencil Roots): Grow vertically upward out of anaerobic mud like snorkels to breathe air."
            ],
            question: GeoQuestion(
                prompt: "Why do Avicennia mangroves grow vertical 'pencil roots' (pneumatophores) sticking straight up out of the mud?",
                options: [
                    "To trap plastic bottles",
                    "To take in oxygen directly from the air because waterlogged mud lacks oxygen",
                    "To store freshwater during droughts",
                    "To repel crabs"
                ],
                correctIndex: 1,
                explanation: "Explanation: Coastal mud is waterlogged and oxygen-poor (anaerobic), so pneumatophores act like botanical snorkels during low tide."
            )
        ),
        GeoQuest(
            id: "housing",
            title: "Eco-Condos for Stray Cats",
            topic: "Housing & 3 Pillars of Sustainability",
            zoneName: "Solar Eco-District",
            npcName: "Architect Luna",
            npcShapeColor: "pink",
            position: CGPoint(x: 0, y: -480),
            storyText: "Stray cats need affordable, green homes! Help me balance Social, Environmental, and Economic sustainability.",
            fieldNotes: [
                "• Social: Safe, affordable housing and community parks.",
                "• Environmental: Solar panels, rainwater harvesting, green roofs.",
                "• Economic: Local green jobs and affordable energy bills."
            ],
            question: GeoQuestion(
                prompt: "Installing solar panels and rainwater harvesting on affordable cat housing directly addresses which two pillars?",
                options: [
                    "Environmental (lower emissions) & Economic (lower utility bills)",
                    "Only Linear Settlement Patterns",
                    "Prop Roots & Conurbations",
                    "High-order goods & Rural depopulation"
                ],
                correctIndex: 0,
                explanation: "Explanation: Renewable energy and resource efficiency protect ecosystems (Environmental) while lowering monthly household expenses (Economic)."
            )
        ),
        // --- BRAND NEW CHARACTERS ADDED BELOW ---
        GeoQuest(
            id: "microclimate",
            title: "The Concrete Heat Trap",
            topic: "Urban Microclimates & Heat Islands",
            zoneName: "Meowtropolis CBD",
            npcName: "Professor Felix",
            npcShapeColor: "yellow",
            position: CGPoint(x: 180, y: 500),
            storyText: "It's way hotter in the downtown concrete plaza than it is in the grassy park! Why is city air so warm?",
            fieldNotes: [
                "• Urban Heat Island Effect: Cities are significantly warmer than surrounding rural areas due to dark asphalt, concrete, and lack of vegetation.",
                "• Mitigation: Green roofs, street trees, and reflective cool pavements reduce urban temperatures."
            ],
            question: GeoQuestion(
                prompt: "What is a major cause of the Urban Heat Island effect in city centers?",
                options: [
                    "An abundance of tall green forests and wetlands",
                    "Dark asphalt and concrete surfaces absorbing and retaining solar heat",
                    "Freezing mountain winds channeled down streets",
                    "Constant ocean breezes"
                ],
                correctIndex: 1,
                explanation: "Explanation: Dark building materials and paved roads absorb large amounts of solar radiation during the day and slowly release it as heat."
            )
        ),
        GeoQuest(
            id: "migration",
            title: "Journey to the City",
            topic: "Push & Pull Migration Factors",
            zoneName: "Whispering Hills",
            npcName: "Tabitha the Traveler",
            npcShapeColor: "mint",
            position: CGPoint(x: -250, y: 480),
            storyText: "Many cats are leaving the quiet countryside for Meowtropolis. What forces are driving them to move?",
            fieldNotes: [
                "• Push Factors: Reasons encouraging people to leave rural areas (e.g., farm mechanization, lack of jobs, drought).",
                "• Pull Factors: Attractions drawing people to cities (e.g., better jobs, universities, entertainment, healthcare)."
            ],
            question: GeoQuestion(
                prompt: "Which of the following is considered a PULL factor drawing rural residents toward urban cities?",
                options: [
                    "Crop failure due to severe drought",
                    "Availability of higher-paying jobs and tertiary education",
                    "Isolation from hospitals and emergency services",
                    "Lack of electricity in rural farmhouses"
                ],
                correctIndex: 1,
                explanation: "Explanation: Employment opportunities and educational institutions act as powerful magnets (pull factors) attracting people to urban centers."
            )
        ),
        GeoQuest(
            id: "food_miles",
            title: "The Global Fish Bowl",
            topic: "Food Miles & Sustainable Consumption",
            zoneName: "Solar Eco-District",
            npcName: "Noodle the Chef Cat",
            npcShapeColor: "indigo",
            position: CGPoint(x: -350, y: -420),
            storyText: "My canned fish was caught across the ocean and shipped thousands of miles! How does that impact our carbon footprint?",
            fieldNotes: [
                "• Food Miles: The distance food travels from the farm/ocean to your plate.",
                "• Sustainable Eating: Buying locally grown food reduces transport emissions, saves energy, and supports local farmers."
            ],
            question: GeoQuestion(
                prompt: "What is the primary environmental benefit of purchasing locally sourced food rather than imported food?",
                options: [
                    "It increases food miles and shipping fuel consumption",
                    "It reduces carbon emissions associated with long-distance transportation",
                    "It guarantees that crops require no water",
                    "It eliminates the need for any packaging whatsoever"
                ],
                correctIndex: 1,
                explanation: "Explanation: Shorter transport distances (fewer food miles) burn less fossil fuel, substantially lowering greenhouse gas emissions."
            )
        )
    ]
    
    @Published var enemies: [PollutionEnemy] = [
        PollutionEnemy(
            id: "smog_slime",
            name: "Toxic Smog Slime",
            pollutionType: "Urban Air Pollution",
            position: CGPoint(x: 240, y: 220),
            topicLesson: "Heavy traffic in high-density cities releases NOx and particulate matter. Encouraging public transit and electric vehicles improves urban sustainability!",
            question: GeoQuestion(
                prompt: "Which urban strategy best reduces traffic congestion and air pollution sustainably?",
                options: [
                    "Building wider highways through parks",
                    "Expanding integrated public transit and safe cycling lanes",
                    "Moving all shops to isolated dwellings",
                    "Removing greenbelts"
                ],
                correctIndex: 1,
                explanation: "Explanation: Public transit systems transport large numbers of citizens efficiently, drastically reducing per-capita vehicle emissions."
            )
        ),
        PollutionEnemy(
            id: "sludge_blob",
            name: "Oil Sludge Blob",
            pollutionType: "Coastal Mangrove Pollution",
            position: CGPoint(x: 280, y: -280),
            topicLesson: "Oil spills coat mangrove pneumatophores (breathing roots), suffocating the trees and destroying coastal storm protection!",
            question: GeoQuestion(
                prompt: "What happens if heavy oil coats a mangrove's pneumatophores?",
                options: [
                    "The tree grows taller",
                    "The lenticels (pores) get blocked, suffocating the root system",
                    "It turns into a nucleated settlement",
                    "The soil becomes rich in oxygen"
                ],
                correctIndex: 1,
                explanation: "Explanation: Pneumatophores rely on open pores to exchange gases; oil seals them shut, cutting off oxygen and killing the tree."
            )
        ),
        PollutionEnemy(
            id: "landfill_beast",
            name: "Sprawl Trash Golem",
            pollutionType: "Unsustainable Urban Sprawl",
            position: CGPoint(x: -280, y: -80),
            topicLesson: "Uncontrolled urban sprawl destroys rural farmland and forces long car commutes. High-density brownfield redevelopment protects rural areas!",
            question: GeoQuestion(
                prompt: "What is a 'brownfield site' in sustainable housing development?",
                options: [
                    "Untouched countryside farmland",
                    "Previously developed urban land that can be cleaned and reused for housing",
                    "A mangrove swamp",
                    "An isolated farm"
                ],
                correctIndex: 1,
                explanation: "Explanation: Redeveloping abandoned industrial or urban lots (brownfields) prevents cities from sprawling outward into greenfield rural lands."
            )
        )
    ]
    
    var completedCount: Int {
        quests.filter { $0.isCompleted }.count + enemies.filter { $0.isPurified }.count
    }
    
    var totalCount: Int {
        quests.count + enemies.count
    }
}
