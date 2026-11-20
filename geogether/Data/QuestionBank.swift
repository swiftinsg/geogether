import Foundation

/// The full Geography simulation question bank.
///
/// 6 topics, 101 questions in total:
/// 1. Sustainable development of housing (10)
/// 2. Urban studies (15, in three sections A–C)
/// 3. Tropical rainforests (12, short answer)
/// 4. Hydrological cycle and water (14, short answer)
/// 5. Population growth and density (25, easy → hard)
/// 6. Transport in Singapore (25, easy → hard)
///
/// Each quiz draws `QuizSession.questionsPerQuiz` random questions from the
/// chosen topic, so the bank is intentionally larger than one quiz.
enum QuestionBank {

    static let topics: [QuizTopic] = [
        housingSustainability,
        urbanStudies,
        tropicalRainforests,
        hydrologicalCycle,
        population,
        transport
    ]

    // MARK: - 1. Sustainable development of housing

    private static let housingSustainability = QuizTopic(
        id: "housing-sustainability",
        title: "Sustainable development of housing",
        subtitle: "Social, economic and environmental sustainability",
        symbol: "house.fill",
        tint: .orange,
        questions: [
            fill("hs1",
                 prompt: "What is one improvement we can make that contributes to sustainable housing?",
                 blanks: [blank("waste disposal", "waste disposals", "public transport","sewage disposals","public transports", "solar power", "rainwater collection")]),

            fill("hs2",
                 prompt: "What is one more improvement we can make that contributes to sustainable housing?",
                 blanks: [blank("waste disposal", "waste disposals", "public transport","sewage disposals","public transports", "solar power", "rainwater collection")]),

            fill("hs3",
                 prompt: "What is one more improvement we can make that contributes to sustainable housing?",
                 blanks: [blank("waste disposal", "waste disposals", "public transport","sewage disposals","public transports", "solar power", "rainwater collection")]),

            fill("hs4",
                 prompt: "Extra: Improper waste and sewage disposal can increase the chances of _____",
                 blanks: [blank("disease", "diseases","sickness")]),

            fill("hs5",
                 prompt: "Extra: Shared spaces such as parks and community centres help promote ______ by encouraging interaction between neighbours.",
                 blanks: [blank("social cohesion", "a sense of belonging")]),


    )

    // MARK: - 2. Urban studies

    private static let urbanStudies = QuizTopic(
        id: "urban-studies",
        title: "Urban studies",
        subtitle: "Settlements, key concepts, rural and urban areas",
        symbol: "building.2.fill",
        tint: .teal,
        questions: urbanSettlements + urbanConcepts + urbanRural
    )

    private static let urbanSettlements: [QuizQuestion] = [
        fill("us1",
             section: "A. Settlements and settlement hierarchy",
             prompt: "A settlement is a place where a group of people live permanently and carry out various activities to support ______.",
             blanks: [blank("themselves")]),

        fill("us2",
             section: "A. Settlements and settlement hierarchy",
             prompt: "Settlements are ranked based on their size, population and number of ______ they provide.",
             blanks: [blank("services")]),

        fill("us3",
             section: "A. Settlements and settlement hierarchy",
             prompt: "As we move higher up the settlement hierarchy, the population and number of services generally ______.",
             blanks: [blank("increase", "increases", "rise", "rises")]),

        fill("us4",
             section: "A. Settlements and settlement hierarchy",
             prompt: "As we move higher up the settlement hierarchy, the frequency (total number) of settlements generally ______.",
             blanks: [blank("decrease", "decreases", "fall", "falls", "reduce", "reduces")]),

        ordering("us5",
                 section: "A. Settlements and settlement hierarchy",
                 prompt: "Arrange the following settlements from smallest to largest.",
                 options: ["City", "Hamlet", "Isolated dwelling", "Village", "Conurbation", "Small town", "Large town"],
                 correctOrder: ["Isolated dwelling", "Hamlet", "Village", "Small town", "Large town", "City", "Conurbation"])
    ]

    private static let urbanConcepts: [QuizQuestion] = [
        fill("us6",
             section: "B. Key geographical concepts",
             prompt: "The maximum distance people are willing to travel to obtain a particular service is known as its ______.",
             blanks: [blank("range")]),

        fill("us7",
             section: "B. Key geographical concepts",
             prompt: "Bread, milk and stationery are examples of ______-order goods because they are purchased frequently.",
             blanks: [blank("low", "lower")]),

        fill("us8",
             section: "B. Key geographical concepts",
             prompt: "Specialised surgery and university education are examples of ______-order goods.",
             blanks: [blank("high", "higher")]),

        fill("us9",
             section: "B. Key geographical concepts",
             prompt: "The minimum number of people needed to generate enough demand for a service to remain profitable is known as the ______ population.",
             blanks: [blank("threshold")]),

        fill("us10",
             section: "B. Key geographical concepts",
             prompt: "The area served by a settlement is known as its sphere of influence, also called its ______ area.",
             blanks: [blank("catchment")])
    ]

    private static let urbanRural: [QuizQuestion] = [
        fill("us11",
             section: "C. Rural and urban areas",
             prompt: "Rural areas generally have a ______ population density compared to urban areas.",
             blanks: [blank("lower", "low")]),

        fill("us12",
             section: "C. Rural and urban areas",
             prompt: "Urban areas typically have highly developed infrastructure, including roads, power and ______.",
             blanks: [blank("water", "water supply", "utilities")]),

        fill("us13",
             section: "C. Rural and urban areas",
             prompt: "Houses grouped closely together around a central point, such as a crossroads or church, form a ______ settlement pattern.",
             blanks: [blank("nucleated", "nucleus", "clustered")]),

        fill("us14",
             section: "C. Rural and urban areas",
             prompt: "Houses built in a line along a road, river or canal form a ______ settlement pattern.",
             blanks: [blank("linear")]),

        fill("us15",
             section: "C. Rural and urban areas",
             prompt: "Houses spread far apart, often associated with large individual farms, form a ______ settlement pattern.",
             blanks: [blank("dispersed", "scattered", "disperse")])
    ]

    // MARK: - 3. Tropical rainforests

    private static let tropicalRainforests = QuizTopic(
        id: "tropical-rainforests",
        title: "Tropical rainforests",
        subtitle: "Climate, layers and plant adaptations",
        symbol: "leaf.fill",
        tint: .green,
        questions: [
            shortAnswer("trf1",
                        prompt: "What is the specific latitudinal distribution of tropical rainforests?",
                        answer: "They are located between 10°N and 10°S of the Equator."),

            shortAnswer("trf2",
                        prompt: "Name three specific examples of tropical rainforests and their locations.",
                        answer: "The Amazon Rainforest in South America, the Congo River Basin Rainforest in West and Central Africa, and the Kalimantan Rainforest in Indonesia."),

            shortAnswer("trf3",
                        prompt: "What defines the temperature profile of an equatorial climate?",
                        answer: "High temperatures all year round with a mean annual temperature above 26°C and a small annual temperature range of 2–3°C."),

            shortAnswer("trf4",
                        prompt: "What is the typical rainfall pattern in areas that support tropical rainforests?",
                        answer: "They receive high annual rainfall of more than 2000 mm, which is well distributed throughout the year, with each month receiving at least 150 mm."),

            shortAnswer("trf5",
                        prompt: "What does it mean for a tropical rainforest to be \"evergreen\"?",
                        answer: "Trees do not shed all of their leaves at particular times of the year; instead, plants continuously grow new leaves to replace older ones that die and fall off."),

            shortAnswer("trf6",
                        prompt: "What are the five distinct vertical layers of a tropical rainforest?",
                        answer: "Emergent, Canopy, Understorey, Shrub layer and Ground layer (forest floor)."),

            shortAnswer("trf7",
                        prompt: "What are the physical characteristics of trees in the Emergent layer?",
                        answer: "They have tall, straight and smooth trunks with few branches, reaching heights greater than 30 m, and sometimes up to 50–80 m."),

            shortAnswer("trf8",
                        prompt: "How dense is the Canopy layer, and what is its effect on sunlight?",
                        answer: "It consists of densely grown trees whose crowns interlock to form an almost continuous cover, blocking out 97% to 98% of sunlight."),

            shortAnswer("trf9",
                        prompt: "What are lianas?",
                        answer: "Thick, woody vines that grow on the ground and twine up trees to reach for sunlight."),

            shortAnswer("trf10",
                        prompt: "How do epiphytes survive in the rainforest, and what are some examples?",
                        answer: "Epiphytes grow directly on trees to receive more sunlight. Examples include ferns (such as the Staghorn fern and Bird's Nest fern), orchids, mosses and lichens."),

            shortAnswer("trf11",
                        prompt: "Why is vegetation sparse and poorly developed on the forest floor?",
                        answer: "Because of the lack of sunlight passing through the continuous canopy layer above."),

            shortAnswer("trf12",
                        prompt: "Why is the layer of leaf litter on the forest floor so thin?",
                        answer: "The hot and wet environment causes rapid decomposition of the dead leaves.")
        ]
    )

    // MARK: - 4. Hydrological cycle and water

    private static let hydrologicalCycle = QuizTopic(
        id: "hydrological-cycle",
        title: "Hydrological cycle and water",
        subtitle: "Processes, drainage basins and rivers",
        symbol: "drop.fill",
        tint: .blue,
        questions: [
            shortAnswer("hy1",
                        prompt: "What is evaporation?",
                        answer: "The process in which water in liquid form changes into a gaseous or vapour state."),

            shortAnswer("hy2",
                        prompt: "How do plants contribute water vapour to the atmosphere?",
                        answer: "Through transpiration, a process where vegetation loses water in the form of water vapour through the stomata of its leaves."),

            shortAnswer("hy3",
                        prompt: "How does temperature affect the air's capacity to hold water vapour?",
                        answer: "When air becomes warmer, it expands and its capacity to hold water vapour rises, meaning warm air can hold more water vapour than cold air."),

            shortAnswer("hy4",
                        prompt: "What is the dew point?",
                        answer: "The temperature at which the air is saturated and is holding all the water vapour it can hold."),

            shortAnswer("hy5",
                        prompt: "What happens during the process of condensation?",
                        answer: "Water vapour changes to a liquid state, turning into water droplets that eventually coalesce to form clouds."),

            shortAnswer("hy6",
                        prompt: "What triggers rain to fall from clouds?",
                        answer: "Upon further condensation, the water droplets in the clouds become too heavy to remain suspended in the air."),

            shortAnswer("hy7",
                        prompt: "What happens to water during infiltration?",
                        answer: "It is the portion of water that reaches the ground and soaks into the soil."),

            shortAnswer("hy8",
                        prompt: "What is percolation, and what does it create over time?",
                        answer: "It is the movement of water further down underground. Continuous percolation results in large amounts of underground water collecting on top of an impermeable rock layer."),

            shortAnswer("hy9",
                        prompt: "What is the surface level of this collected groundwater called?",
                        answer: "The water table."),

            shortAnswer("hy10",
                        prompt: "Under what conditions does surface runoff occur?",
                        answer: "When rainfall exceeds the infiltration rate, or in areas with impermeable concrete surfaces and sparse vegetation."),

            shortAnswer("hy11",
                        prompt: "What is a drainage basin?",
                        answer: "An area of land drained by a river and its tributaries, also known as a catchment area."),

            shortAnswer("hy12",
                        prompt: "What geographic feature separates one drainage basin from another?",
                        answer: "A watershed, which is a boundary that lies along the tops of slopes."),

            shortAnswer("hy13",
                        prompt: "Define the source and mouth of a river.",
                        answer: "The source is the river's beginning, and the mouth is where the river empties its water into lakes, seas or oceans."),

            shortAnswer("hy14",
                        prompt: "What is a river confluence?",
                        answer: "The exact point where two rivers or streams meet.")
        ]
    )

    // MARK: - 5. Population growth and density

    private static let population = QuizTopic(
        id: "population",
        title: "Population growth and density",
        subtitle: "Distribution, migration and pressure on resources",
        symbol: "person.3.fill",
        tint: .purple,
        questions: populationEasy + populationMedium + populationHard
    )

    private static let populationEasy: [QuizQuestion] = [
        fill("p1",
             section: "Easy",
             prompt: "Population density refers to the number of people living per unit of ______.",
             blanks: [blank("land", "area", "land area")]),

        fill("p2",
             section: "Easy",
             prompt: "Population density can be calculated by dividing the total population by the total ______ area.",
             blanks: [blank("land")]),

        fill("p3",
             section: "Easy",
             prompt: "A city has a population of 800,000 people and a land area of 200 km².\nIts population density is ______ people/km².",
             hint: "800,000 ÷ 200",
             blanks: [blank("4,000", "4000", "4 000")]),

        fill("p4",
             section: "Easy",
             prompt: "When a large number of people live within a relatively small area, the area is described as ______ populated.",
             blanks: [blank("densely", "heavily")]),

        fill("p5",
             section: "Easy",
             prompt: "A sudden increase in population can cause greater demand for housing, food, water and public ______.",
             blanks: [blank("services / infrastructure", "services", "infrastructure", "amenities", "facilities")]),

        fill("p6",
             section: "Easy",
             prompt: "An increase in the number of people living in a particular area over time is known as population ______.",
             blanks: [blank("growth", "increase")]),

        fill("p7",
             section: "Easy",
             prompt: "Population distribution refers to how people are ______ across a particular area.",
             blanks: [blank("distributed", "spread", "spread out")]),

        fill("p8",
             section: "Easy",
             prompt: "An area with very few people living within a large land area is described as ______ populated.",
             blanks: [blank("sparsely", "sparse", "lightly")]),

        fill("p9",
             section: "Easy",
             prompt: "The movement of people from one place to another to live is known as ______.",
             blanks: [blank("migration", "migrating", "migrate")]),

        fill("p10",
             section: "Easy",
             prompt: "Population density is usually measured in people per ______.",
             blanks: [blank("km²", "km2", "km", "square kilometres", "square kilometers", "square km")])
    ]

    private static let populationMedium: [QuizQuestion] = [
        fill("p11",
             section: "Medium",
             prompt: "A town has a population of 120,000 people and a land area of 60 km².\nIts population density is ______ people/km².",
             hint: "120,000 ÷ 60",
             blanks: [blank("2,000", "2000", "2 000")]),

        fill("p12",
             section: "Medium",
             prompt: "A city has a population density of 5,000 people/km² and a land area of 80 km².\nIts total population is ______ people.",
             hint: "5,000 × 80",
             blanks: [blank("400,000", "400000", "400 000")]),

        fill("p13",
             section: "Medium",
             prompt: "When birth rates are higher than death rates, the population generally ______.",
             blanks: [blank("increases", "increase", "grows", "grow", "rises", "rise")]),

        fill("p14",
             section: "Medium",
             prompt: "Areas with more employment opportunities and better infrastructure tend to attract ______ people.",
             blanks: [blank("more", "many", "more people")]),

        fill("p15",
             section: "Medium",
             prompt: "An increase in population can place greater pressure on natural resources such as water, food and ______.",
             blanks: [blank("land", "space", "energy")])
    ]

    private static let populationHard: [QuizQuestion] = [
        fill("p16",
             section: "Hard",
             prompt: "A city has a population of 2 million people and a land area of 400 km².\nIts population density is ______ people/km².",
             hint: "2,000,000 ÷ 400",
             blanks: [blank("5,000", "5000", "5 000")]),

        fill("p17",
             section: "Hard",
             prompt: "Two cities have the same population, but City A has a smaller land area than City B.\nCity A will have a ______ population density.",
             blanks: [blank("higher", "high", "greater", "larger")]),

        fill("p18",
             section: "Hard",
             prompt: "When the population grows faster than the development of housing and infrastructure, it may result in ______.",
             blanks: [blank("overcrowding", "overcrowded", "overpopulation")]),

        fill("p19",
             section: "Hard",
             prompt: "When people move from rural areas to urban areas in search of better employment opportunities, this is known as rural-to-urban ______.",
             blanks: [blank("migration", "migrating", "migrate")]),

        fill("p20",
             section: "Hard",
             prompt: "A city experiences rapid population growth, causing overcrowding and increased demand for public services. The government decides to build more schools, hospitals and transport networks to improve its ______.",
             blanks: [blank("infrastructure", "services", "facilities")]),

        fill("p21",
             section: "Hard",
             prompt: "A village has a population of 24,000 people and a population density of 800 people/km².\nIts land area is ______ km².",
             hint: "24,000 ÷ 800",
             blanks: [blank("30", "30 km²", "30 km2")]),

        fill("p22",
             section: "Hard",
             prompt: "A city increases its land area through development while keeping its population constant.\nIts population density will ______.",
             blanks: [blank("decrease", "decreases", "fall", "falls", "drop", "drops", "reduce", "lower")]),

        fill("p23",
             section: "Hard",
             prompt: "People are more likely to settle in areas with favourable physical conditions, such as flat land and a reliable supply of ______.",
             blanks: [blank("water", "fresh water", "food")]),

        fill("p24",
             section: "Hard",
             prompt: "A city has a population of 600,000 people. Its population increases to 750,000 while its land area remains at 150 km².\nThe new population density is ______ people/km².",
             hint: "750,000 ÷ 150",
             blanks: [blank("5,000", "5000", "5 000")]),

        fill("p25",
             section: "Hard",
             prompt: "A rapidly growing population increases the demand for housing, schools and healthcare. This is an example of increasing population ______.",
             blanks: [blank("pressure", "growth")])
    ]

    // MARK: - 6. Transport in Singapore

    private static let transport = QuizTopic(
        id: "transport",
        title: "Transport in Singapore",
        subtitle: "Public and private transport, congestion and planning",
        symbol: "tram.fill",
        tint: .pink,
        questions: transportEasy + transportMedium + transportHard
    )

    private static let transportEasy: [QuizQuestion] = [
        fill("t1",
             section: "Easy",
             prompt: "The MRT and public buses are examples of ______ transport.",
             blanks: [blank("public", "mass")]),

        fill("t2",
             section: "Easy",
             prompt: "Cars and motorcycles are examples of ______ transport.",
             blanks: [blank("private", "personal")]),

        fill("t3",
             section: "Easy",
             prompt: "When the number of vehicles on the road increases significantly, it can lead to traffic ______.",
             blanks: [blank("congestion", "jams", "jam", "congestion jams")]),

        fill("t4",
             section: "Easy",
             prompt: "Walking, cycling and using public transport are examples of more ______ forms of transport.",
             hint: "They can be kept up without harming the environment.",
             blanks: [blank("sustainable", "green", "eco-friendly", "environmentally friendly")]),

        fill("t5",
             section: "Easy",
             prompt: "A new residential estate is built far away from the nearest MRT station. To improve transport accessibility, the government could introduce additional bus routes and build a new ______ station nearby.",
             blanks: [blank("MRT", "train", "LRT", "MRT/LRT")]),

        fill("t6",
             section: "Easy",
             prompt: "The abbreviation MRT stands for Mass Rapid ______.",
             blanks: [blank("transit", "transport")]),

        fill("t7",
             section: "Easy",
             prompt: "Buses and trains allow large numbers of people to travel using shared ______.",
             blanks: [blank("transport", "transportation", "vehicles", "space")]),

        fill("t8",
             section: "Easy",
             prompt: "Travelling in your own car is an example of using ______ transport.",
             blanks: [blank("private", "personal")]),

        fill("t9",
             section: "Easy",
             prompt: "Cycling does not produce direct vehicle exhaust ______.",
             blanks: [blank("emissions", "emission", "fumes", "gases")]),

        fill("t10",
             section: "Easy",
             prompt: "The ease with which people can reach transport services is known as transport ______.",
             blanks: [blank("accessibility", "access")])
    ]

    private static let transportMedium: [QuizQuestion] = [
        fill("t11",
             section: "Medium",
             prompt: "Traffic congestion occurs when the number of vehicles exceeds the available road ______.",
             blanks: [blank("capacity", "space")]),

        fill("t12",
             section: "Medium",
             prompt: "Using public transport instead of private cars can help reduce traffic ______.",
             blanks: [blank("congestion", "jams", "jam")]),

        fill("t13",
             section: "Medium",
             prompt: "Building MRT stations near residential estates improves transport ______ for residents.",
             blanks: [blank("accessibility", "access", "connectivity")]),

        fill("t14",
             section: "Medium",
             prompt: "A student cycles to school instead of travelling by car. This helps reduce carbon ______.",
             blanks: [blank("emissions", "emission", "footprint")]),

        fill("t15",
             section: "Medium",
             prompt: "Singapore's MRT system helps connect residential areas with workplaces and ______ centres.",
             blanks: [blank("shopping", "commercial", "business")])
    ]

    private static let transportHard: [QuizQuestion] = [
        fill("t16",
             section: "Hard",
             prompt: "A neighbourhood has limited access to public transport. Residents have to travel long distances to reach the nearest MRT station.\nThe neighbourhood has poor transport ______.",
             blanks: [blank("accessibility", "access", "connectivity")]),

        fill("t17",
             section: "Hard",
             prompt: "During peak hours, roads become overcrowded because many people travel at the same ______.",
             blanks: [blank("time", "time of day")]),

        fill("t18",
             section: "Hard",
             prompt: "Encouraging people to walk, cycle and take public transport helps reduce reliance on ______ vehicles.",
             blanks: [blank("private", "personal", "cars", "car")]),

        fill("t19",
             section: "Hard",
             prompt: "A new MRT line is constructed to connect several residential estates to the city centre. This improves connectivity and transport ______.",
             blanks: [blank("accessibility", "access", "connectivity")]),

        fill("t20",
             section: "Hard",
             prompt: "The government introduces more frequent buses and trains during peak hours to accommodate the increasing number of passengers and reduce ______.",
             blanks: [blank("overcrowding", "crowding", "congestion", "overcrowded")]),

        fill("t21",
             section: "Hard",
             prompt: "A city wants to reduce air pollution caused by vehicles. It encourages residents to use bicycles and public transport. These are examples of ______ transport methods.",
             blanks: [blank("sustainable", "green", "eco-friendly", "environmentally friendly")]),

        fill("t22",
             section: "Hard",
             prompt: "Connecting residential areas, schools, workplaces and shopping centres through an efficient transport network is an example of transport ______.",
             blanks: [blank("planning", "plan")]),

        fill("t23",
             section: "Hard",
             prompt: "A new housing estate is built without nearby bus stops or MRT stations. Residents may become more dependent on ______ transport.",
             blanks: [blank("private", "personal", "car", "cars")]),

        fill("t24",
             section: "Hard",
             prompt: "A city has too many private vehicles on its roads. One possible solution is to encourage more people to use ______ transport.",
             blanks: [blank("public", "mass")]),

        fill("t25",
             section: "Hard",
             prompt: "A well-connected transport network allows people to reach their destinations more easily, improving overall transport ______.",
             blanks: [blank("accessibility", "access", "connectivity")])
    ]

    // MARK: - Helpers

    private static func fill(_ id: String,
                             section: String? = nil,
                             prompt: String,
                             hint: String? = nil,
                             blanks: [Blank]) -> QuizQuestion {
        QuizQuestion(id: id, section: section, prompt: prompt, hint: hint, kind: .fillInTheBlank(blanks))
    }

    private static func ordering(_ id: String,
                                 section: String? = nil,
                                 prompt: String,
                                 options: [String],
                                 correctOrder: [String]) -> QuizQuestion {
        QuizQuestion(id: id, section: section, prompt: prompt, hint: nil,
                     kind: .ordering(options: options, correctOrder: correctOrder))
    }

    private static func shortAnswer(_ id: String,
                                    section: String? = nil,
                                    prompt: String,
                                    answer: String) -> QuizQuestion {
        QuizQuestion(id: id, section: section, prompt: prompt, hint: nil,
                     kind: .shortAnswer(modelAnswer: answer))
    }

    /// `blank("services / infrastructure", "services", "infrastructure")`
    /// The first value is what the learner sees in the answer key.
    private static func blank(_ canonical: String, _ alternatives: String...) -> Blank {
        Blank(accepted: [canonical] + alternatives, display: canonical)
    }
}
