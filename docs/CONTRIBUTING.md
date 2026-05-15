# 貢獻指南

歡迎為 FF14 Duty Hint 貢獻！本專案最主要的貢獻方式是**新增或修正副本提示資料**。

## 🎯 貢獻方式

### A. 新增副本提示（最歡迎）

1. **Fork** 本 repo
2. 在 `data/duties/` 內新增 `<副本英文ID>.json`，例如 `m1s_arcadion.json`
3. 參考 [`docs/duty-format.md`](duty-format.md) 撰寫內容
4. 確保 JSON 語法正確（可用 [JSONLint](https://jsonlint.com) 檢查）
5. 送 Pull Request

### B. 修正錯誤 / 改進說明

直接編輯對應的 JSON 檔，送 PR 即可。

### C. 程式碼貢獻

- UI / UX 改進
- 新功能（例如：副本搜尋、快速鍵設定、自動偵測）
- Bug 修復

請先在 Issue 討論大致方向，再開始實作。

## 📝 撰寫副本資料的小建議

- **語氣**：直接、精煉、像隊友互相提醒，不要太長篇大論
- **避免**：劇透、抱怨、攻擊性言論
- **重點**：實戰中真正需要記住的機制，不是百科全書
- **Tips**：放關鍵走位 / 減傷 CD / 常見錯誤
- **mechanic type**：請盡量套用標準分類 (`raidwide` / `tankbuster` / `stack` / `spread` / `aoe` / `other`)，方便用顏色辨識

## 🌐 命名規範

- 副本 ID（檔名）：小寫英數 + 底線，例如：
  - `sastasha_normal`
  - `p9s_anabaseios`
  - `e12s_eden`
- 中文名：使用台版／國際版正式翻譯

## 📦 PR 檢查清單

- [ ] JSON 語法有效
- [ ] `id` 與檔名一致且未與其他副本衝突
- [ ] 沒有劇透爆雷（除了機制本身）
- [ ] 至少測試過 build：`dotnet build`

## 🙏 行為準則

請保持友善與尊重。本專案歡迎所有熱愛 FF14 的玩家。
