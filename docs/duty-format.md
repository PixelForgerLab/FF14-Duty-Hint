# 副本 JSON 格式說明

每個副本一個 `.json` 檔，放在 `data/duties/` 目錄。

## 🔖 基本結構

```json
{
  "id": "p9s_anabaseios",
  "name": "絕望樂園 第一層：零式",
  "nameEn": "Anabaseios: The Ninth Circle (Savage)",
  "expansion": "6.4 曉月之終途",
  "type": "raid",
  "playerCount": 8,
  "iLvlSync": 645,
  "notes": "副本層級的總體說明（選填）",
  "bosses": [ /* ... */ ]
}
```

## 📋 欄位說明

### 副本層級

| 欄位 | 必填 | 類型 | 說明 |
|---|---|---|---|
| `id` | ✅ | string | 唯一 ID（建議與檔名相同），小寫英數+底線 |
| `name` | ✅ | string | 副本中文名 |
| `nameEn` | ⬜ | string | 副本英文名 |
| `expansion` | ⬜ | string | 資料片版號，例：`6.4 曉月之終途` |
| `type` | ⬜ | string | `raid` / `trial` / `dungeon` / `variant` / `criterion` |
| `playerCount` | ⬜ | int | 人數（4 / 8 / 24） |
| `iLvlSync` | ⬜ | int | iLvl 同步等級 |
| `notes` | ⬜ | string | 副本整體備註 |
| `bosses` | ✅ | array | Boss 列表 |

### Boss 層級

```json
{
  "name": "Kokytos",
  "nameEn": "Kokytos",
  "notes": "Boss 整體備註",
  "phases": [ /* ... */ ]
}
```

### Phase 層級

```json
{
  "name": "P1 起手到 Limit Cut",
  "notes": "階段備註",
  "mechanics": [ /* ... */ ]
}
```

### Mechanic 層級

```json
{
  "name": "Ascendant Fist",
  "type": "tankbuster",
  "description": "兩段坦克爆擊",
  "tips": [
    "兩 T 必須換仇恨",
    "建議副 T 接第二下"
  ]
}
```

## 🎨 機制類型 (`type`)

| 值 | 顏色標籤 | 用途 |
|---|---|---|
| `raidwide` | 🟧 全體 | 全體 AoE / 全圖傷害 |
| `tankbuster` | 🟥 坦克 | 坦克爆擊 |
| `stack` | 🟩 集合 | 集合分擔機制 |
| `spread` | 🟦 散開 | 散開類機制 |
| `aoe` | 🟪 AoE | 地面圈、扇形等可預警 AoE |
| `other` | ⬜ 機制 | 其他（解謎、移動、特殊機制） |

> 如果不確定要用哪個，填 `other` 就好；之後再分類也可以。

## 🧪 驗證 JSON

最簡單的方法：把檔案丟進 [JSONLint](https://jsonlint.com)。

進階：使用 `_schema.json` 做 JSON Schema 驗證（VS Code 內建支援）。

## ✏️ 撰寫建議

- **不要劇透**：只描述機制，不描述劇情
- **語氣口語化**：「奶開減傷」比「治療職應釋放群體防護技能」好
- **重點優先**：玩家在戰鬥中只能瞄一眼，前 10 個字要最重要
- **tips 是短句**：每個 tip 是一句話，不要長篇大論
