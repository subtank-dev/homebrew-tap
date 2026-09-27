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

  version "0.0.6"
  sha256 arm:   "667e2b85f1e12f33a2c085549f4550498bf367b99206051a827c0b73b655b922",
         intel: "4cf4903e0fb05508218e8bea1f8433c5effcb33a355d7805649a158aba1111f8"

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
