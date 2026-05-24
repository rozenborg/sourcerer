import SwiftUI
import AuthenticationServices
import CryptoKit

struct AuthView: View {
    @Environment(AuthService.self) private var auth
    @State private var nonce: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var awaitingOTP: Bool = false
#if DEBUG
    @Binding var debugPreview: Bool
    init(debugPreview: Binding<Bool> = .constant(false)) {
        self._debugPreview = debugPreview
    }
#endif

    var body: some View {
        ZStack {
            PageBackground(atmosphere: .dawn)

            VStack(spacing: 22) {
                Spacer()
                BriefingOrb(diameter: 150)
                Text("WELCOME TO SOURCERER")
                    .font(Theme.Typography.meta(11))
                    .tracking(2)
                    .foregroundStyle(Theme.Color.accent)
                Text("A bounded daily deck.")
                    .font(Theme.Typography.display(30))
                    .kerning(-0.5)
                    .foregroundStyle(Theme.Color.ink)
                    .multilineTextAlignment(.center)
                Text("Each morning, ~18 of the strongest AI signals — skim, save, rate. The deck ends, and so does your day with it.")
                    .font(Theme.Typography.serif(14).italic())
                    .foregroundStyle(Theme.Color.inkSoft)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)

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
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                emailBlock

                if let err = auth.lastError {
                    Text(err)
                        .font(Theme.Typography.body(12))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onLongPressGesture(minimumDuration: 1.5) {
#if DEBUG
            debugPreview = true
#endif
        }
    }

    @ViewBuilder
    private var emailBlock: some View {
        VStack(spacing: 8) {
            Text("OR USE EMAIL")
                .font(Theme.Typography.meta(10))
                .tracking(1.5)
                .foregroundStyle(Theme.Color.stone300)

            if !awaitingOTP {
                TextField("you@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(12)
                    .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.Color.stone200, lineWidth: 1)
                    )

                Button {
                    Task {
                        await auth.sendEmailOTP(email: email)
                        awaitingOTP = auth.lastError == nil
                    }
                } label: {
                    Text("SEND CODE")
                        .font(Theme.Typography.meta(11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(email.isEmpty ? Theme.Color.stone300 : Theme.Color.accent,
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(email.isEmpty || auth.isLoading)
            } else {
                TextField("6-digit code", text: $otp)
                    .keyboardType(.numberPad)
                    .padding(12)
                    .background(Theme.Color.stone0, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.Color.stone200, lineWidth: 1)
                    )
                Button {
                    Task { await auth.verifyEmailOTP(email: email, token: otp) }
                } label: {
                    Text("VERIFY")
                        .font(Theme.Typography.meta(11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(otp.count < 6 ? Theme.Color.stone300 : Theme.Color.accent,
                                    in: RoundedRectangle(cornerRadius: 12))
                }
                .disabled(otp.count < 6 || auth.isLoading)
            }
        }
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
