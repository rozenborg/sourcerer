import Foundation
import Supabase

@MainActor
@Observable
final class AppEnvironment {
    let supabase: SupabaseClient
    let auth: AuthService
    let articles: ArticleRepository
    let interactions: InteractionsRepository

    init() {
        let (url, anonKey) = AppEnvironment.loadSecrets()
        self.supabase = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
        self.auth = AuthService(client: supabase)
        self.articles = SupabaseArticleRepository(client: supabase)
        self.interactions = SupabaseInteractionsRepository(
            client: supabase,
            userId: { [weak auth] in auth?.userId }
        )
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
