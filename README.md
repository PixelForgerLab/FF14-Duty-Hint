# FF14 Duty Hint Overlay

<p align="center">
  <img src="src/FF14DutyHint/Resources/icon-preview.png" alt="App Icon" width="128" height="128"/>
</p>

[![Build](https://github.com/PixelForgerLab/FF14-Duty-Hint/actions/workflows/build.yml/badge.svg)](https://github.com/PixelForgerLab/FF14-Duty-Hint/actions/workflows/build.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4)](https://dotnet.microsoft.com/)

> 一個 Windows Overlay 應用程式，讓你在遊玩《Final Fantasy XIV》時，可以在畫面上顯示副本的機制提示。

## ✨ 特色

- 🪟 **無邊框 Overlay 視窗** — 永遠置頂、可拖拽、可調透明度
- 🎯 **不偷遊戲焦點** — 點擊 overlay 不會切走 FF14 焦點
- 📚 **手動選擇副本** — 從清單挑選想顯示提示的副本（含搜尋）
- 💡 **簡易模式** — 進本前快速複習，可一鍵切換「全部 ↔ 簡易」；可寫單句口訣或多句條列清單
- 👥 **角色篩選** — 選擇坦克/奶媽/DPS，只看相關 tip，畫面不爆量
- 🎨 **機制類型顏色標籤** — 全體 / 坦克 / 集合 / 散開 / AoE 一目了然
- 🏅 **品質徽章** — 副本依「完整 / 需更新 / 骨架」分類，一眼看出哪些有完整機制
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

## 🛡️ 防毒程式信任設定（重要）

由於本程式是**未簽章的個人開源軟體**，部分防毒軟體（例如 F-Secure、Bitdefender、ESET 等）可能會以「啟發式」誤判 `FF14DutyHint.exe` 或 `FF14DutyHint.dll` 為惡意檔案（常見威脅名稱：`DR/W32.MalwareX`、`Heur:Trojan.Win32.Generic` 等）。

> 這是**誤判**。本專案所有原始碼公開、CI 自動建置、SHA256 隨 release 提供。如有疑慮可自行從原始碼編譯。

**如果防毒擋下來，請將下列項目加入信任清單：**

1. 解壓後的 `FF14DutyHint` 整個資料夾，或
2. `FF14DutyHint.exe` 與 `FF14DutyHint.dll` 兩個檔案，並
3. 從隔離區還原已被刪除的檔案

各家防毒軟體設定方式不同，請參考其官網說明搜尋「加入排除 / 信任 / 例外」。

## ⚠️ 使用免責聲明

**請仔細閱讀後再使用本軟體：**

1. 🛡️ **本軟體不做以下行為**：
   - ❌ 不讀取 FF14 遊戲記憶體
   - ❌ 不攔截或讀取網路封包
   - ❌ 不修改任何遊戲檔案
   - ❌ 不自動操作鍵盤或滑鼠
   - ❌ 不傳送任何資料到外部伺服器
   - ✅ 它只是一個獨立顯示 JSON 資料的純檢視 Overlay 視窗

2. ⚠️ **但仍存在帳號風險**：
   即使本軟體技術上完全合法，**Square Enix 對第三方軟體的政策可能變動**，且任何在遊戲畫面上覆蓋顯示資訊的 Overlay 應用，理論上都可能被認定為違反使用條款（[FFXIV ToS / EULA](https://support.na.square-enix.com/rule.php?id=5382&la=1)）。
   
   **使用者需自行承擔以下風險**：
   - 帳號被封禁（temporary suspension / permanent ban）
   - 進度遺失
   - 任何因使用本軟體而產生的損失

3. 📜 **作者免責**：
   本專案以 MIT License 開源，作者與貢獻者**不為使用者的帳號狀態、遊戲損失或其他後果負任何責任**。請自行評估風險。

4. 🚫 **不建議使用情境**：
   - 賽事 / 競速場合
   - 公會嚴禁第三方工具的環境
   - 你無法承擔失去帳號後果的情況

> 若你不接受上述條款，請**不要**下載或使用本軟體。下載即視為已閱讀並接受本免責聲明。

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

完整的使用免責聲明請見上方「⚠️ 使用免責聲明」章節。重點摘要：

- ✅ 本軟體**不**讀取記憶體、**不**攔截封包、**不**自動操作、**不**修改遊戲檔案
- ⚠️ 但任何 Overlay 工具理論上都可能被 Square Enix 認定違反 ToS
- 📜 使用者需自行評估並承擔帳號風險，作者不負任何責任

> FINAL FANTASY XIV © SQUARE ENIX CO., LTD. 本專案與 Square Enix 無任何關係。
