import Foundation
import Supabase
import AuthenticationServices

@MainActor
@Observable
final class AuthService {
    private let client: SupabaseClient
    var session: Session?
    var isLoading: Bool = false
    var lastError: String?

    init(client: SupabaseClient) {
        self.client = client
        Task { await self.refreshSession() }
        Task { await self.observeAuthChanges() }
    }

    var isAuthenticated: Bool { session != nil }
    var userId: UUID? { session?.user.id }

    func refreshSession() async {
        do {
            self.session = try await client.auth.session
        } catch {
            self.session = nil
        }
    }

    private func observeAuthChanges() async {
        for await state in client.auth.authStateChanges {
            self.session = state.session
        }
    }

    func signInWithApple(idToken: String, nonce: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await client.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
            )
            await refreshSession()
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func sendEmailOTP(email: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await client.auth.signInWithOTP(email: email)
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func verifyEmailOTP(email: String, token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await client.auth.verifyOTP(
                email: email,
                token: token,
                type: .email
            )
            await refreshSession()
            self.lastError = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
            self.session = nil
        } catch {
            self.lastError = error.localizedDescription
        }
    }
}
