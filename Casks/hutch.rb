cask "hutch" do
  version "0.2.0"
  sha256 "12343e7b6d52d6eecd35cb39b4b3fa7eef7f56512a66bad29c391f1abb85e99d"

  url "https://github.com/Riku4230/Hutch/releases/download/v#{version}/Hutch-v#{version}.dmg",
      verified: "github.com/Riku4230/Hutch/"
  name "Hutch"
  desc "Menu bar app for Apple Reminders with AI mode"
  homepage "https://github.com/Riku4230/Hutch"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  app "Hutch.app"

  zap trash: [
    "~/Library/Preferences/dev.remindermenu.app.plist",
    "~/Library/Application Support/Hutch",
    "~/Library/Application Support/Nudge",
    "~/Library/Caches/dev.remindermenu.app",
  ]

  caveats <<~EOS
    初回起動時に Gatekeeper 警告が出たら：
      システム設定 → プライバシーとセキュリティ → 「このまま開く」

    リマインダーへのフルアクセスとフルディスクアクセスはアプリ内ウィザードから案内されます。
  EOS
end
