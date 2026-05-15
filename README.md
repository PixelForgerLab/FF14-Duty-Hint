# FF14 Duty Hint Overlay

[![Build](https://github.com/PixelForgerLab/FF14-Duty-Hint/actions/workflows/build.yml/badge.svg)](https://github.com/PixelForgerLab/FF14-Duty-Hint/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4)](https://dotnet.microsoft.com/)

> 一個 Windows Overlay 應用程式，讓你在遊玩《Final Fantasy XIV》時，可以在畫面上顯示副本的機制提示。

## ✨ 特色

- 🪟 **無邊框 Overlay 視窗** — 永遠置頂、可拖拽、可調透明度
- 🎯 **不偷遊戲焦點** — 點擊 overlay 不會切走 FF14 焦點
- 📚 **手動選擇副本** — 從清單挑選想顯示提示的副本（含搜尋）
- 🎨 **機制類型顏色標籤** — 全體 / 坦克 / 集合 / 散開 / AoE 一目了然
- 🏅 **品質徽章** — 副本依「優秀 / 需更新 / 骨架」分類，一眼看出哪些有完整機制
- 📂 **自訂副本資料夾** — 內建 + APPDATA + 使用者自訂三層覆寫，可放自己的私房筆記
- 🔤 **字體大小可調** — 配合不同解析度與視力需求
- 💾 **設定自動儲存** — 視窗位置、大小、透明度、上次選的副本都會被記住
- 📂 **JSON 格式資料** — 任何人都可以輕鬆貢獻新副本
- 🚫 **不讀取記憶體 / 不修改遊戲** — 不違反 SE 使用條款

## 📂 副本資料來源（多層覆寫）

啟動時依序載入這三個資料夾，相同 id 的副本**後者覆寫前者**：

| 優先級 | 來源 | 路徑 |
|---|---|---|
| 1 (低) | 內建 | exe 同層 `data\duties\` |
| 2 (中) | 使用者資料夾 | `%APPDATA%\FF14DutyHint\duties\` |
| 3 (高) | 自訂資料夾 | 設定中可選 |

副本選擇與詳細頁會顯示 `自訂` / `自訂*` 徽章標明來源。

## 📦 下載

到 [Releases](https://github.com/PixelForgerLab/FF14-Duty-Hint/releases) 頁面下載最新版的 `FF14DutyHint.zip`，解壓後執行 `FF14DutyHint.exe` 即可。

> ⚠️ 第一次執行時，Windows SmartScreen 可能會跳警告（因為這是未簽章的程式），點 `更多資訊` → `仍要執行` 即可。

## ⌨️ 操作

| 操作 | 說明 |
|---|---|
| 拖拽標題列 | 移動視窗 |
| `Ctrl + D` | 開啟副本選擇 |
| `Ctrl + ,` | 開啟設定 |
| 拖拉右下角 | 調整視窗大小 |

## 🛠️ 從原始碼建置

### 環境需求
- Windows 10 / 11
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

### 建置與執行
```powershell
git clone https://github.com/PixelForgerLab/FF14-Duty-Hint.git
cd FF14-Duty-Hint
dotnet build
dotnet run --project src/FF14DutyHint
```

### 發佈成單一 exe
```powershell
dotnet publish src/FF14DutyHint -c Release -r win-x64 --self-contained false -o publish
```

## 📚 副本資料

所有副本提示都儲存在 `data/duties/*.json`（**約 365 個**，涵蓋 ARR 至 Dawntrail 全部 dungeon / trial / raid / ultimate / alliance raid 等）。

絕大多數副本目前僅有骨架（名稱、版本、人數），歡迎透過 PR 補充詳細機制提示！

想新增或修改副本嗎？歡迎發 PR！詳見：
- [貢獻指南](docs/CONTRIBUTING.md)
- [JSON 格式說明](docs/duty-format.md)

### 重新產生副本骨架（維護者用）

```powershell
pwsh ./tools/Generate-Duties.ps1
# 或，覆寫已存在的檔案（會清掉手寫機制提示！）：
pwsh ./tools/Generate-Duties.ps1 -Force
```
腳本會從 [xivapi/ffxiv-datamining](https://github.com/xivapi/ffxiv-datamining) 下載最新的 `ContentFinderCondition.csv`，自動生成所有副本的骨架 JSON。

## 🤝 貢獻

歡迎透過 Issue 或 Pull Request 貢獻：
- 新副本提示資料
- UI / UX 改進
- Bug 回報
- 翻譯

請先閱讀 [CONTRIBUTING.md](docs/CONTRIBUTING.md)。

## 📜 授權

本專案以 [MIT License](LICENSE) 授權發布。

## ⚠️ 免責聲明

本軟體**不**讀取遊戲記憶體、**不**修改遊戲檔案、**不**自動操作。它只是一個獨立的視窗應用程式。

> FINAL FANTASY XIV © SQUARE ENIX CO., LTD. 本專案與 Square Enix 無任何關係。
