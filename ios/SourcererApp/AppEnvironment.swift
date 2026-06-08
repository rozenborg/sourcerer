import Foundation
import Supabase

@MainActor
@Observable
final class AppEnvironment {
    let supabase: SupabaseClient
    let auth: AuthService
    let articles: ArticleRepository
    let interactions: InteractionsRepository
    let ratings: RatingsRepository

    init(supabaseURL: URL, supabaseAnonKey: String) {
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey)
        self.auth = AuthService(client: supabase)
        self.articles = SupabaseArticleRepository(client: supabase)
        self.interactions = SupabaseInteractionsRepository(
            client: supabase,
            userId: { [weak auth] in auth?.userId }
        )
        self.ratings = SupabaseRatingsRepository(
            client: supabase,
            userId: { [weak auth] in auth?.userId }
        )
    }

    /// Full-DI init for previews and tests — accepts pre-built dependencies so
    /// the live Supabase repositories can be swapped for fakes.
    init(
        supabase: SupabaseClient,
        auth: AuthService,
        articles: ArticleRepository,
        interactions: InteractionsRepository,
        ratings: RatingsRepository
    ) {
        self.supabase = supabase
        self.auth = auth
        self.articles = articles
        self.interactions = interactions
        self.ratings = ratings
    }

    convenience init() {
        let (url, anonKey) = AppEnvironment.loadSecrets()
        self.init(supabaseURL: url, supabaseAnonKey: anonKey)
    }

    private static func loadSecrets() -> (URL, String) {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let urlString = plist["SUPABASE_URL"] as? String,
              let url = URL(string: urlString),
              let anonKey = plist["SUPABASE_ANON_KEY"] as? String,
              !anonKey.isEmpty
        else {
            fatalError("""
                Missing or invalid SourcererApp/Resources/Secrets.plist.
                Copy Secrets.plist.example -> Secrets.plist and fill in
                SUPABASE_URL and SUPABASE_ANON_KEY.
                """)
        }
        return (url, anonKey)
    }
}
