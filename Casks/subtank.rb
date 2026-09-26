# ============================================================
# subtank.rb — the Homebrew cask, as it is seeded into the tap
# ============================================================
# WHY THIS EXISTS   2026-09-23. subtank is installed from its own tap,
#                   github.com/subtank-dev/homebrew-tap, which does not exist
#                   yet. This is the cask it starts with: bump-cask.sh copies
#                   it to Casks/subtank.rb the first time and from then on
#                   rewrites only version and the two sha256 lines there.
#                   Users install it by full name:
#                     brew install --cask subtank-dev/tap/subtank
# WHAT IT DOES      Installs the notarized DMG for this Mac's architecture
#                   from dl.subtank.dev and tells Homebrew the app updates
#                   itself.
# WHAT IT CANNOT DO Remove Keychain items (see the note above zap), or follow
#                   the beta channel: the cask tracks stable releases only.
#                   In .ai/homebrew the version and sha256 values are
#                   placeholders; in the tap, bump-cask.sh keeps them current.
# ============================================================
cask "subtank" do
  arch arm: "arm64", intel: "x64"

  version "0.0.5"
  sha256 arm:   "d0ab121c228f739c463e44366e0a04238b7f89b7a5ebf46f988c7723cd000dd5",
         intel: "25197c0714381d1a5d5b35c53161bdd92c1759ee419048ec292ed925c19159fc"

  url "https://dl.subtank.dev/releases/subtank-#{version}-#{arch}.dmg"
  name "subtank"
  desc "Menu bar meter for AI plan limits, credits and renewals"
  homepage "https://subtank.dev/"

  # The same feed the app reads. electron-builder writes it and release.sh
  # uploads it only after the files it names, so livecheck never sees a
  # version whose DMG is missing.
  livecheck do
    url "https://dl.subtank.dev/releases/latest-mac.yml"
    strategy :electron_builder
  end

  # The app updates itself from dl.subtank.dev (electron-updater), so a plain
  # `brew upgrade` leaves it alone and only `brew upgrade --greedy` replaces it.
  auto_updates true
  # Electron 44's floor, and the app's LSMinimumSystemVersion (13.0.0). The
  # bare symbol means "this release or newer"; the ">= :ventura" string form
  # is deprecated.
  depends_on macos: :ventura

  app "subtank.app"
  binary "#{appdir}/subtank.app/Contents/Resources/bin/subtank"

  uninstall quit: "dev.subtank.app"

  # Keychain items are out of zap's reach: every key subtank saves lives under
  # Keychain service "subtank", and zap can only trash files. The app's own
  # Reset removes them; run it before uninstalling to leave nothing behind.
  # Electron's cookie-encryption key ("subtank Safe Storage") is a Keychain
  # item too, and zap cannot reach it either.
  zap trash: [
    "~/Library/Application Support/subtank",
    "~/Library/Caches/dev.subtank.app",
    "~/Library/Caches/dev.subtank.app.ShipIt",
    "~/Library/Caches/subtank-updater",
    "~/Library/HTTPStorages/dev.subtank.app",
    "~/Library/Logs/subtank",
    "~/Library/Preferences/dev.subtank.app.plist",
    "~/Library/Saved Application State/dev.subtank.app.savedState",
  ]
end
