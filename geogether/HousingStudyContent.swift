import SwiftUI

struct HousingStudyPoint: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let description: LocalizedStringResource
}

struct HousingStudyPage: Identifiable {
    let id: Int
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
    let symbol: String
    let colors: [Color]
    let points: [HousingStudyPoint]

    static func pages(for location: HousingLocation) -> [HousingStudyPage] {
        switch location {
        case .homes: publicHousing
        case .dining: hawkerCenter
        case .playground: playground
        case .garden: park
        case .school, .community: []
        }
    }

    private static let publicHousing: [HousingStudyPage] = [
        HousingStudyPage(
            id: 0,
            title: "H — Homes Meet Basic Needs",
            subtitle: "Shelter, safety and services",
            symbol: "house.fill",
            colors: [.cyan, .blue, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Essential shelter", description: "Formal housing gives families a stable place to live, with access to water, sanitation and electricity."),
                HousingStudyPoint(id: 1, title: "• Quality of life", description: "A well-maintained home and supportive surroundings help residents live comfortably.")
            ]
        ),
        HousingStudyPage(
            id: 1,
            title: "O — Optimise Land",
            subtitle: "More homes on limited land",
            symbol: "building.2.fill",
            colors: [.orange, .pink, .yellow],
            points: [
                HousingStudyPoint(id: 0, title: "• Build upwards", description: "High-rise flats house many families on a smaller land area than low-rise housing for the same population."),
                HousingStudyPoint(id: 1, title: "• Balance competing needs", description: "Planning must also make space for schools, transport, jobs and recreation.")
            ]
        ),
        HousingStudyPage(
            id: 2,
            title: "M — Meet Daily Needs",
            subtitle: "A town with essentials nearby",
            symbol: "figure.walk",
            colors: [.mint, .green, .cyan],
            points: [
                HousingStudyPoint(id: 0, title: "• Plan services together", description: "HDB towns include shops, schools, parks and community centres to meet daily needs."),
                HousingStudyPoint(id: 1, title: "• Shorter journeys", description: "Nearby amenities make walking and short public transport trips practical, saving time and transport costs.")
            ]
        ),
        HousingStudyPage(
            id: 3,
            title: "E — Enduring Communities",
            subtitle: "Homes people care about",
            symbol: "person.3.fill",
            colors: [.indigo, .purple, .pink],
            points: [
                HousingStudyPoint(id: 0, title: "• Shared spaces", description: "Common spaces let neighbours meet, build friendships and develop a sense of belonging."),
                HousingStudyPoint(id: 1, title: "• Maintain for the future", description: "Repairs, clean surroundings and responsible use of resources help keep estates liveable.")
            ]
        ),
        HousingStudyPage(
            id: 4,
            title: "G3 Exam Tip: PEEL",
            subtitle: "How does public housing support sustainability?",
            symbol: "pencil.and.list.clipboard",
            colors: [.yellow, .orange, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Point", description: "High-rise housing makes efficient use of limited land."),
                HousingStudyPoint(id: 1, title: "• Explain", description: "Building upwards accommodates many families within a smaller land area."),
                HousingStudyPoint(id: 2, title: "• Example", description: "An HDB town combines blocks of flats with nearby schools, shops and parks."),
                HousingStudyPoint(id: 3, title: "• Link", description: "Residents have homes and essential services nearby, supporting a liveable, sustainable town."),
                HousingStudyPoint(id: 4, title: "Remember HOME", description: "Homes meet basic needs • Optimise land • Meet daily needs • Enduring communities.")
            ]
        )
    ]

    private static let hawkerCenter: [HousingStudyPage] = [
        HousingStudyPage(
            id: 0,
            title: "E — Essential Food",
            subtitle: "Everyday meals close to home",
            symbol: "fork.knife",
            colors: [.cyan, .blue, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Meet a basic need", description: "Hawker centres provide a variety of affordable cooked food for residents."),
                HousingStudyPoint(id: 1, title: "• Support daily routines", description: "Nearby meal options are convenient for families, workers and older residents.")
            ]
        ),
        HousingStudyPage(
            id: 1,
            title: "A — Accessibility",
            subtitle: "Less travelling for a meal",
            symbol: "figure.walk",
            colors: [.orange, .pink, .yellow],
            points: [
                HousingStudyPoint(id: 0, title: "• Close to housing", description: "Locating food centres near homes gives many residents easy access to meals."),
                HousingStudyPoint(id: 1, title: "• Save time and money", description: "Walking or taking a short bus ride reduces travel time and transport costs."),
                HousingStudyPoint(id: 2, title: "• Fewer car trips", description: "Short local journeys can reduce reliance on cars and associated emissions.")
            ]
        ),
        HousingStudyPage(
            id: 2,
            title: "T — Togetherness",
            subtitle: "A community dining room",
            symbol: "person.3.fill",
            colors: [.mint, .green, .cyan],
            points: [
                HousingStudyPoint(id: 0, title: "• Shared tables", description: "Eating in the same space creates opportunities for neighbours to meet."),
                HousingStudyPoint(id: 1, title: "• Shared food culture", description: "Food from different cultures helps make hawker centres familiar community places.")
            ]
        ),
        HousingStudyPage(
            id: 3,
            title: "S — Sustain Livelihoods",
            subtitle: "Support people and their neighbourhood",
            symbol: "storefront.fill",
            colors: [.indigo, .purple, .pink],
            points: [
                HousingStudyPoint(id: 0, title: "• Local jobs", description: "Stalls provide opportunities for hawkers to earn a living."),
                HousingStudyPoint(id: 1, title: "• Keep the centre liveable", description: "Clean tables, proper waste disposal and less food waste help maintain a pleasant shared space.")
            ]
        ),
        HousingStudyPage(
            id: 4,
            title: "G3 Exam Tip: PEEL",
            subtitle: "Why locate hawker centres near housing?",
            symbol: "pencil.and.list.clipboard",
            colors: [.yellow, .orange, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Point", description: "Nearby hawker centres improve access to affordable meals."),
                HousingStudyPoint(id: 1, title: "• Explain", description: "Many residents need convenient food options within their neighbourhood."),
                HousingStudyPoint(id: 2, title: "• Example", description: "A resident walks from their flat to a nearby hawker centre instead of driving elsewhere."),
                HousingStudyPoint(id: 3, title: "• Link", description: "This saves travel time and cost while shared dining spaces create opportunities for community bonding."),
                HousingStudyPoint(id: 4, title: "Remember EATS", description: "Essential food • Accessibility • Togetherness • Sustain livelihoods.")
            ]
        )
    ]

    private static let playground: [HousingStudyPage] = [
        HousingStudyPage(
            id: 0,
            title: "P — Physical Activity",
            subtitle: "Move, climb and play",
            symbol: "figure.play",
            colors: [.cyan, .blue, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Active children", description: "Slides, swings and climbing equipment encourage outdoor movement."),
                HousingStudyPoint(id: 1, title: "• Develop movement skills", description: "Playing helps children practise balance and coordination.")
            ]
        ),
        HousingStudyPage(
            id: 1,
            title: "L — Learning Through Play",
            subtitle: "Small games, useful skills",
            symbol: "lightbulb.fill",
            colors: [.orange, .pink, .yellow],
            points: [
                HousingStudyPoint(id: 0, title: "• Social skills", description: "Taking turns and sharing equipment help children learn to cooperate."),
                HousingStudyPoint(id: 1, title: "• Explore and discover", description: "Play gives children opportunities to try activities and solve small challenges.")
            ]
        ),
        HousingStudyPage(
            id: 2,
            title: "A — All Are Welcome",
            subtitle: "Inclusive spaces near home",
            symbol: "figure.roll",
            colors: [.mint, .green, .cyan],
            points: [
                HousingStudyPoint(id: 0, title: "• Easy access", description: "Neighbourhood play areas give families a place to play without a long journey."),
                HousingStudyPoint(id: 1, title: "• Design for different needs", description: "Inclusive equipment and accessible routes help more children join in."),
                HousingStudyPoint(id: 2, title: "• Example", description: "Bishan–Ang Mo Kio Park has wheelchair-accessible play equipment and sensory features.")
            ]
        ),
        HousingStudyPage(
            id: 3,
            title: "Y — Your Community",
            subtitle: "Play together, belong together",
            symbol: "person.3.fill",
            colors: [.indigo, .purple, .pink],
            points: [
                HousingStudyPoint(id: 0, title: "• Meet neighbours", description: "Children make local friends while parents and caregivers have chances to talk."),
                HousingStudyPoint(id: 1, title: "• Shared memories", description: "Regular visits help families feel attached to their neighbourhood."),
                HousingStudyPoint(id: 2, title: "• Care for the space", description: "Maintaining equipment and keeping play areas clean support long-term enjoyment.")
            ]
        ),
        HousingStudyPage(
            id: 4,
            title: "G3 Exam Tip: PEEL",
            subtitle: "How do playgrounds improve housing estates?",
            symbol: "pencil.and.list.clipboard",
            colors: [.yellow, .orange, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Point", description: "Playgrounds provide nearby recreation and opportunities for social interaction."),
                HousingStudyPoint(id: 1, title: "• Explain", description: "Children play together while caregivers meet other neighbourhood families."),
                HousingStudyPoint(id: 2, title: "• Example", description: "Children take turns on shared play equipment as their parents chat nearby."),
                HousingStudyPoint(id: 3, title: "• Link", description: "Active play and friendships improve quality of life and strengthen belonging in the estate."),
                HousingStudyPoint(id: 4, title: "Remember PLAY", description: "Physical activity • Learning • All are welcome • Your community.")
            ]
        )
    ]

    private static let park: [HousingStudyPage] = [
        HousingStudyPage(
            id: 0,
            title: "L — Leisure and Well-being",
            subtitle: "A green space to unwind",
            symbol: "leaf.fill",
            colors: [.cyan, .blue, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Space to relax", description: "Parks offer places for residents to rest, enjoy nature and spend time outdoors."),
                HousingStudyPoint(id: 1, title: "• Active living", description: "Paths and open spaces give residents opportunities to walk, jog and exercise.")
            ]
        ),
        HousingStudyPage(
            id: 1,
            title: "E — Environmental Benefits",
            subtitle: "Cooler, greener neighbourhoods",
            symbol: "tree.fill",
            colors: [.orange, .pink, .yellow],
            points: [
                HousingStudyPoint(id: 0, title: "• Shade and cooling", description: "Trees provide shade and plants release water vapour, helping cool their surroundings."),
                HousingStudyPoint(id: 1, title: "• Support biodiversity", description: "Trees, shrubs and ponds can provide habitats for wildlife such as birds and insects.")
            ]
        ),
        HousingStudyPage(
            id: 2,
            title: "A — Active Travel",
            subtitle: "Green routes between places",
            symbol: "figure.walk",
            colors: [.mint, .green, .cyan],
            points: [
                HousingStudyPoint(id: 0, title: "• Walk and cycle", description: "Connected paths can make short trips on foot or bicycle more convenient."),
                HousingStudyPoint(id: 1, title: "• Reduce car dependence", description: "When residents replace short car journeys with active travel, emissions can be reduced.")
            ]
        ),
        HousingStudyPage(
            id: 3,
            title: "F — Friendships and Belonging",
            subtitle: "Shared greenery, shared experiences",
            symbol: "person.3.fill",
            colors: [.indigo, .purple, .pink],
            points: [
                HousingStudyPoint(id: 0, title: "• Meet and connect", description: "Walks, picnics and shared activities create opportunities for neighbours to interact."),
                HousingStudyPoint(id: 1, title: "• Sense of place", description: "Familiar green spaces and positive memories build attachment to the neighbourhood."),
                HousingStudyPoint(id: 2, title: "• Protect the space", description: "Keeping parks clean and caring for plants helps future residents enjoy them too.")
            ]
        ),
        HousingStudyPage(
            id: 4,
            title: "G3 Exam Tip: PEEL",
            subtitle: "Why include parks in housing estates?",
            symbol: "pencil.and.list.clipboard",
            colors: [.yellow, .orange, .mint],
            points: [
                HousingStudyPoint(id: 0, title: "• Point", description: "Parks improve the living environment and provide nearby recreation."),
                HousingStudyPoint(id: 1, title: "• Explain", description: "Greenery offers shade while paths and open areas encourage outdoor activities."),
                HousingStudyPoint(id: 2, title: "• Example", description: "Residents walk in a neighbourhood park and meet neighbours along the paths."),
                HousingStudyPoint(id: 3, title: "• Link", description: "Recreation, cooling and social interaction help make the estate more liveable and sustainable."),
                HousingStudyPoint(id: 4, title: "Remember LEAF", description: "Leisure • Environmental benefits • Active travel • Friendships.")
            ]
        )
    ]
}
