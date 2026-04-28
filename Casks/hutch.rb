cask "hutch" do
  version "0.2.1"
  sha256 "7929bece9986afbc08d16a73a75306f867270919925bab80b10448fbddd845b7"

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
