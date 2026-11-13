import Foundation

/// The full Geography simulation question bank.
/// 6 topics x 5 questions (easy -> hard), matching the printed answer key.
enum QuestionBank {

    static let topics: [QuizTopic] = [
        urbanisation,
        housing,
        mangroves,
        continentsAndWater,
        population,
        transport
    ]

    // MARK: - 1. Urbanisation and settlements

    private static let urbanisation = QuizTopic(
        id: "urbanisation",
        title: "Urbanisation and settlements",
        subtitle: "How towns and cities grow",
        symbol: "building.2.fill",
        tint: .teal,
        questions: [
            fill("u1",
                 prompt: "Urbanisation is the process where an increasing proportion of a country's population lives in ______ areas.",
                 blanks: [blank("urban")]),

            fill("u2",
                 prompt: "A village is an example of a ______ settlement, while a city is an example of an ______ settlement.",
                 blanks: [blank("rural"), blank("urban")]),

            fill("u3",
                 prompt: "When more people move from rural areas to cities, the demand for housing, transport and other ______ increases.",
                 blanks: [blank("services / infrastructure", "services", "infrastructure", "amenities", "facilities")]),

            ordering("u4",
                     prompt: "Arrange the following settlements from smallest to largest.",
                     options: ["City", "Hamlet", "Village", "Town"],
                     correctOrder: ["Hamlet", "Village", "Town", "City"]),

            fill("u5",
                 prompt: "A rural village is experiencing rapid population growth. The government decides to construct more roads, schools and hospitals to support its residents. This process is an example of ______ development.",
                 hint: "What kind of development follows a growing population?",
                 blanks: [blank("urban")])
        ]
    )

    // MARK: - 2. Housing

    private static let housing = QuizTopic(
        id: "housing",
        title: "Housing",
        subtitle: "Homes, inequality and renewal",
        symbol: "house.fill",
        tint: .orange,
        questions: [
            fill("h1",
                 prompt: "In Singapore, public housing flats are commonly built and managed by the ______.",
                 blanks: [blank("HDB", "Housing and Development Board", "Housing & Development Board", "Housing Development Board")]),

            fill("h2",
                 prompt: "Informal settlements are areas where people live in housing that is often built without proper planning or ______.",
                 blanks: [blank("approval / regulations", "approval", "regulations", "regulation", "permits", "permission", "planning approval")]),

            fill("h3",
                 prompt: "Housing inequality occurs when different groups of people have unequal access to safe and ______ housing.",
                 blanks: [blank("affordable")]),

            fill("h4",
                 prompt: "The process of replacing old or deteriorating buildings with newer and improved developments is known as urban ______.",
                 blanks: [blank("redevelopment", "renewal")]),

            fill("h5",
                 prompt: "A city wants to build more houses while reducing environmental damage. It decides to incorporate green spaces, energy-efficient appliances and better ventilation. These features help create more ______ housing.",
                 hint: "It is the kind of housing that meets today's needs without harming the future.",
                 blanks: [blank("sustainable", "green", "eco-friendly", "environmentally friendly")])
        ]
    )

    // MARK: - 3. Mangrove ecosystems

    private static let mangroves = QuizTopic(
        id: "mangroves",
        title: "Mangrove ecosystems",
        subtitle: "Life where land meets the sea",
        symbol: "leaf.fill",
        tint: .green,
        questions: [
            fill("m1",
                 prompt: "Mangroves are commonly found along tropical and subtropical ______ where land meets the sea.",
                 blanks: [blank("coastlines", "coasts", "coast", "coastal areas", "shores", "shorelines")]),

            fill("m2",
                 prompt: "The specialised roots that help mangrove trees remain stable in soft, muddy soil are called ______ roots.",
                 hint: "They hold the tree up like stilts.",
                 blanks: [blank("prop")]),

            fill("m3",
                 prompt: "Some mangrove trees have specialised roots that grow upwards above the soil to absorb ______ from the atmosphere.",
                 blanks: [blank("oxygen", "air")]),

            fill("m4",
                 prompt: "Mangrove ecosystems provide habitats and breeding grounds for many different species, helping to maintain ______.",
                 blanks: [blank("biodiversity")]),

            fill("m5",
                 prompt: "When mangrove forests are cleared for coastal development, animals lose their natural ______, causing a decline in biodiversity.",
                 hint: "Another word for a species' natural home.",
                 blanks: [blank("habitat", "habitats", "home", "homes")])
        ]
    )

    // MARK: - 4. Continents and distribution of water

    private static let continentsAndWater = QuizTopic(
        id: "continents-water",
        title: "Continents and water",
        subtitle: "Landmasses and the water cycle",
        symbol: "globe.asia.australia.fill",
        tint: .blue,
        questions: [
            fill("c1",
                 prompt: "There are ______ continents on Earth.",
                 blanks: [blank("seven", "7")]),

            fill("c2",
                 prompt: "The largest ocean in the world is the ______ Ocean.",
                 blanks: [blank("Pacific")]),

            fill("c3",
                 prompt: "Most of Earth's water is found in oceans and is therefore ______ water.",
                 blanks: [blank("salt", "salty", "saline")]),

            fill("c4",
                 prompt: "The process where water changes from a liquid into water vapour due to heat is called ______.",
                 blanks: [blank("evaporation")]),

            fill("c5",
                 prompt: "A country experiences water scarcity despite receiving rainfall. One possible solution is to collect and store rainwater through a process called rainwater ______.",
                 hint: "It is like gathering a crop of rain.",
                 blanks: [blank("harvesting", "collection", "storage")])
        ]
    )

    // MARK: - 5. Population growth and density

    private static let population = QuizTopic(
        id: "population",
        title: "Population growth and density",
        subtitle: "People per square kilometre",
        symbol: "person.3.fill",
        tint: .purple,
        questions: [
            fill("p1",
                 prompt: "Population density refers to the number of people living per unit of ______.",
                 blanks: [blank("land", "area", "land area")]),

            fill("p2",
                 prompt: "Population density can be calculated by dividing the total population by the total ______ area.",
                 blanks: [blank("land")]),

            fill("p3",
                 prompt: "A city has a population of 800,000 people and a land area of 200 km².\nIts population density is ______ people/km².",
                 hint: "800,000 ÷ 200",
                 blanks: [blank("4,000", "4000", "4 000")]),

            fill("p4",
                 prompt: "When a large number of people live within a relatively small area, the area is described as ______ populated.",
                 blanks: [blank("densely", "heavily")]),

            fill("p5",
                 prompt: "A sudden increase in population can cause greater demand for housing, food, water and public ______.",
                 blanks: [blank("services / infrastructure", "services", "infrastructure", "amenities", "facilities")])
        ]
    )

    // MARK: - 6. Transport in Singapore

    private static let transport = QuizTopic(
        id: "transport",
        title: "Transport in Singapore",
        subtitle: "Moving people around the city",
        symbol: "tram.fill",
        tint: .pink,
        questions: [
            fill("t1",
                 prompt: "The MRT and public buses are examples of ______ transport.",
                 blanks: [blank("public", "mass")]),

            fill("t2",
                 prompt: "Cars and motorcycles are examples of ______ transport.",
                 blanks: [blank("private", "personal")]),

            fill("t3",
                 prompt: "When the number of vehicles on the road increases significantly, it can lead to traffic ______.",
                 blanks: [blank("congestion", "jams", "jam", "congestion jams")]),

            fill("t4",
                 prompt: "Walking, cycling and using public transport are examples of more ______ forms of transport.",
                 hint: "They can be kept up without harming the environment.",
                 blanks: [blank("sustainable", "green", "eco-friendly", "environmentally friendly")]),

            fill("t5",
                 prompt: "A new residential estate is built far away from the nearest MRT station. To improve transport accessibility, the government could introduce additional bus routes and build a new ______ station nearby.",
                 blanks: [blank("MRT", "train", "LRT", "MRT/LRT")])
        ]
    )

    // MARK: - Helpers

    private static func fill(_ id: String,
                             prompt: String,
                             hint: String? = nil,
                             blanks: [Blank]) -> QuizQuestion {
        QuizQuestion(id: id, prompt: prompt, hint: hint, kind: .fillInTheBlank(blanks))
    }

    private static func ordering(_ id: String,
                                 prompt: String,
                                 options: [String],
                                 correctOrder: [String]) -> QuizQuestion {
        QuizQuestion(id: id, prompt: prompt, hint: nil, kind: .ordering(options: options, correctOrder: correctOrder))
    }

    /// `blank("services / infrastructure", "services", "infrastructure")`
    /// The first value is what the learner sees in the answer key.
    private static func blank(_ canonical: String, _ alternatives: String...) -> Blank {
        Blank(accepted: [canonical] + alternatives, display: canonical)
    }
}
