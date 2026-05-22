import SwiftUI
import AuthenticationServices
import CryptoKit
import Inject

struct AuthView: View {
    @ObserveInjection var inject
    @Environment(AuthService.self) private var auth
    @State private var nonce: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var awaitingOTP: Bool = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48, weight: .light))
                Text("Sourcerer")
                    .font(.largeTitle.weight(.semibold))
                Text("Your headless content database, in your pocket.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            SignInWithAppleButton(.signIn) { request in
                let raw = AuthView.randomNonceString()
                self.nonce = raw
                request.requestedScopes = [.fullName, .email]
                request.nonce = AuthView.sha256(raw)
            } onCompletion: { result in
                handleAppleResult(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)

            VStack(spacing: 8) {
                Text("or use email")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !awaitingOTP {
                    TextField("you@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(.thinMaterial, in: .rect(cornerRadius: 10))
                    Button {
                        Task {
                            await auth.sendEmailOTP(email: email)
                            awaitingOTP = auth.lastError == nil
                        }
                    } label: {
                        Text("Send code")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || auth.isLoading)
                } else {
                    TextField("6-digit code", text: $otp)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(.thinMaterial, in: .rect(cornerRadius: 10))
                    Button {
                        Task { await auth.verifyEmailOTP(email: email, token: otp) }
                    } label: {
                        Text("Verify")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(otp.count < 6 || auth.isLoading)
                }
            }

            if let err = auth.lastError {
                Text(err)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(24)
        .enableInjection()
    }

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth_):
            guard let cred = auth_.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = cred.identityToken,
                  let token = String(data: tokenData, encoding: .utf8) else {
                auth.lastError = "Apple sign-in returned no identity token."
                return
            }
            Task { await auth.signInWithApple(idToken: token, nonce: nonce) }
        case .failure(let err):
            auth.lastError = err.localizedDescription
        }
    }

    // MARK: - Nonce helpers

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let chars: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            for r in randoms where remaining > 0 {
                if r < chars.count {
                    result.append(chars[Int(r)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    AuthView()
        .environment(AuthService(client: PreviewSupabase.client))
}
