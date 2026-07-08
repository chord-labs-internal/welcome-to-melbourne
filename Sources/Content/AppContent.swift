import Foundation

// MARK: - Root

/// The complete, decoded contents of `db.json`.
///
/// Every screen's content is reachable from this single value type, decoded
/// once and injected into features. Keys map 1:1 to the JSON, so no custom
/// `CodingKeys` are needed at this level.
public struct AppContent: Codable, Hashable, Sendable {
    public var home: Home
    public var guides: [Guide]
    public var featured: [FeaturedItem]
    public var coffeeScreen: CategoryScreen
    public var cafes: [Cafe]
    public var jobsScreen: CategoryScreen
    public var jobs: [Job]
    public var meetupsScreen: CategoryScreen
    public var groups: [Group]
    public var recordsScreen: CategoryScreen
    public var records: [Record]
    public var nav: [NavItem]

    public init(
        home: Home,
        guides: [Guide],
        featured: [FeaturedItem],
        coffeeScreen: CategoryScreen,
        cafes: [Cafe],
        jobsScreen: CategoryScreen,
        jobs: [Job],
        meetupsScreen: CategoryScreen,
        groups: [Group],
        recordsScreen: CategoryScreen,
        records: [Record],
        nav: [NavItem]
    ) {
        self.home = home
        self.guides = guides
        self.featured = featured
        self.coffeeScreen = coffeeScreen
        self.cafes = cafes
        self.jobsScreen = jobsScreen
        self.jobs = jobs
        self.meetupsScreen = meetupsScreen
        self.groups = groups
        self.recordsScreen = recordsScreen
        self.records = records
        self.nav = nav
    }
}

// MARK: - Home

public struct Home: Codable, Hashable, Sendable {
    public var weather: Weather
    public var greeting: String
    public var city: String
    public var tagline: String
    public var searchPlaceholder: String
    public var exploreTitle: String
    public var exploreCount: String
    public var featuredTitle: String

    public init(
        weather: Weather,
        greeting: String,
        city: String,
        tagline: String,
        searchPlaceholder: String,
        exploreTitle: String,
        exploreCount: String,
        featuredTitle: String
    ) {
        self.weather = weather
        self.greeting = greeting
        self.city = city
        self.tagline = tagline
        self.searchPlaceholder = searchPlaceholder
        self.exploreTitle = exploreTitle
        self.exploreCount = exploreCount
        self.featuredTitle = featuredTitle
    }
}

public struct Weather: Codable, Hashable, Sendable {
    public var day: String
    public var temperature: Int
    public var unit: String
    public var condition: String
    public var label: String

    public init(day: String, temperature: Int, unit: String, condition: String, label: String) {
        self.day = day
        self.temperature = temperature
        self.unit = unit
        self.condition = condition
        self.label = label
    }
}

// MARK: - Guides

public struct Guide: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var slug: String
    public var title: String
    public var subtitle: String
    public var count: Int
    public var countLabel: String
    public var icon: String
    /// Hex color string, e.g. `"#B4573C"`.
    public var color: String
    public var route: String

    public init(
        id: Int,
        slug: String,
        title: String,
        subtitle: String,
        count: Int,
        countLabel: String,
        icon: String,
        color: String,
        route: String
    ) {
        self.id = id
        self.slug = slug
        self.title = title
        self.subtitle = subtitle
        self.count = count
        self.countLabel = countLabel
        self.icon = icon
        self.color = color
        self.route = route
    }
}

// MARK: - Featured

/// A "Featured this week" carousel entry. Fields vary by `type`:
/// coffee/record entries carry a `rating`; job entries carry a `salary`.
public struct FeaturedItem: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var badge: String
    public var type: String
    public var title: String
    public var meta: String
    public var suburb: String
    public var rating: Double?
    public var refId: Int
    public var image: String
    public var salary: String?

    public init(
        id: Int,
        badge: String,
        type: String,
        title: String,
        meta: String,
        suburb: String,
        rating: Double? = nil,
        refId: Int,
        image: String,
        salary: String? = nil
    ) {
        self.id = id
        self.badge = badge
        self.type = type
        self.title = title
        self.meta = meta
        self.suburb = suburb
        self.rating = rating
        self.refId = refId
        self.image = image
        self.salary = salary
    }
}

// MARK: - Category screen headers

/// The shared header + filter chips for a category screen
/// (coffee, jobs, meetups, records).
public struct CategoryScreen: Codable, Hashable, Sendable {
    public var eyebrow: String
    public var title: String
    public var subtitle: String
    public var filters: [String]

    public init(eyebrow: String, title: String, subtitle: String, filters: [String]) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.filters = filters
    }
}

// MARK: - Cafes

public struct Cafe: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var name: String
    public var rating: Double
    public var suburb: String
    /// Human-readable tag line, e.g. `"Espresso · Standing room"`.
    public var tags: String
    /// Filterable category keys, e.g. `["Espresso"]`.
    public var categories: [String]
    public var priceLevel: String
    public var image: String

    public init(
        id: Int,
        name: String,
        rating: Double,
        suburb: String,
        tags: String,
        categories: [String],
        priceLevel: String,
        image: String
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.suburb = suburb
        self.tags = tags
        self.categories = categories
        self.priceLevel = priceLevel
        self.image = image
    }
}

// MARK: - Jobs

public struct Job: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var title: String
    public var company: String
    public var suburb: String
    public var avatar: String
    public var salary: String
    public var employment: String
    public var location: String
    public var category: String

    public init(
        id: Int,
        title: String,
        company: String,
        suburb: String,
        avatar: String,
        salary: String,
        employment: String,
        location: String,
        category: String
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.suburb = suburb
        self.avatar = avatar
        self.salary = salary
        self.employment = employment
        self.location = location
        self.category = category
    }
}

// MARK: - Groups (Meetups)

public struct Group: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var name: String
    public var category: String
    public var suburb: String
    public var description: String
    public var members: Int
    public var membersLabel: String
    public var nextMeet: String

    public init(
        id: Int,
        name: String,
        category: String,
        suburb: String,
        description: String,
        members: Int,
        membersLabel: String,
        nextMeet: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.suburb = suburb
        self.description = description
        self.members = members
        self.membersLabel = membersLabel
        self.nextMeet = nextMeet
    }
}

// MARK: - Records

public struct Record: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var name: String
    public var rating: Double
    public var suburb: String
    /// Human-readable genre line, e.g. `"Soul · Funk · Jazz"`.
    public var genres: String
    /// Filterable category keys, e.g. `["Vinyl", "Rare finds"]`.
    public var categories: [String]
    public var image: String

    public init(
        id: Int,
        name: String,
        rating: Double,
        suburb: String,
        genres: String,
        categories: [String],
        image: String
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.suburb = suburb
        self.genres = genres
        self.categories = categories
        self.image = image
    }
}

// MARK: - Navigation

public struct NavItem: Codable, Hashable, Sendable, Identifiable {
    public var id: Int
    public var label: String
    public var icon: String
    public var route: String
    public var active: Bool

    public init(id: Int, label: String, icon: String, route: String, active: Bool) {
        self.id = id
        self.label = label
        self.icon = icon
        self.route = route
        self.active = active
    }
}
