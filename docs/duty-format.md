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
| `playerCount` | ⬜ | int | 人數（4 / 8 / 24 / 48） |
| `iLvlSync` | ⬜ | int | iLvl 同步等級 |
| `jobLevelSync` | ⬜ | int | 職業等級需求（由產生器自動填入） |
| `highEnd` | ⬜ | bool | 是否為高難度（Savage / Ultimate / Chaotic）|
| `quality` | ⬜ | string | 提示品質：`excellent` / `needs-update` / `skeleton`（見下方說明）|
| `mnemonic` | ⬜ | string \| string[] | 副本層級簡易提示，單句或多句陣列（多句會以 1）2）3）... 編號顯示） |
| `notes` | ⬜ | string | 副本整體備註 |
| `bosses` | ✅ | array | Boss 列表 |

### Boss 層級

```json
{
  "name": "Kokytos",
  "nameEn": "Kokytos",
  "mnemonic": "Plummet → Liquid Hell → Conflag → Death Sentence",
  "notes": "Boss 整體備註",
  "phases": [ /* ... */ ]
}
```

`mnemonic` 也可以寫成多句陣列：

```json
{
  "name": "Boss",
  "mnemonic": [
    "起手 Plummet → 主 T 對外吃",
    "Liquid Hell：被點名拉線到場邊",
    "Conflag Strike：8 人集合分擔"
  ]
}
```

| 欄位 | 說明 |
|---|---|
| `mnemonic` | Boss 層級簡易提示。單句或多句陣列。 |

## 💡 簡易（Mnemonic）

「簡易」是讓玩家**進本前快速複習**的提示。寫法：

**單句**（短提示）：
```json
"mnemonic": "Plummet 主 T 對外吃，Liquid Hell 拉線到邊。"
```

**多句陣列**（重點清單）：
```json
"mnemonic": [
  "Famfrit：看水壺方向躲海嘯。",
  "Belias：快鐘先炸、慢鐘後炸；線不要掃到別人。",
  "Construct 7：算數題做對，血量要符合條件。",
  "Yiazmat：平常盡量貼王。",
  "磁極場時，站到和自己 debuff 相反顏色那半場。",
  "被點大黑圈就帶開。",
  "有小怪或心臟先清，不要貪打王。"
]
```

UI 會以「💡 簡易」標籤顯示。多句陣列會自動編號為 `1）` `2）` `3）...`。

主視窗右上有「全部 ↔ 簡易」切換鈕，切到「簡易」就只看這些重點，不看詳細機制。

## 🏅 品質標籤 (`quality`)

| 值 | 顯示 | 用途 |
|---|---|---|
| `excellent` | 🟡 完整 | 機制完整、經過驗證、可放心使用 |
| `needs-update` | 🟠 需更新 | 有部分內容但不完整或可能過時 |
| `skeleton` | ⬜ 骨架 | 只有副本基本資料，無詳細機制 |

> **沒指定 `quality` 怎麼辦？**<br>
> 若 `bosses` 為空陣列 → 自動視為 `skeleton`<br>
> 若 `bosses` 有內容但未明確標 quality → 不顯示徽章（中性）<br>
> 寫好新副本後，建議自評後加上 `"quality": "excellent"` 或 `"needs-update"`。

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
    { "text": "建議副 T 接第二下", "role": "tank" },
    { "text": "受擊後立刻補血或盾", "role": "healer" }
  ]
}
```

### Tips（兩種寫法）

每個 tip 可以是**字串**或**物件**：

**字串形式**（通用，所有角色看得到）：
```json
"tips": ["第一個 tip", "第二個 tip"]
```

**物件形式**（指定角色）：
```json
"tips": [
  { "text": "主 T 開大型減傷", "role": "tank" },
  { "text": "立刻補血或盾", "role": "healer" },
  { "text": "保留爆發給此波", "role": "dps" },
  { "text": "全員注意走位", "role": "universal" }
]
```

**混用也可以**：
```json
"tips": [
  "通用提示（會永遠顯示）",
  { "text": "只給坦克看的", "role": "tank" }
]
```

| `role` 值 | 顯示對象 |
|---|---|
| `tank` | 偏好角色為「坦克」時顯示 |
| `healer` | 偏好角色為「奶媽」時顯示 |
| `dps` | 偏好角色為「DPS」時顯示 |
| `universal` 或省略 | 所有角色都顯示 |

> 使用者可在主視窗右上「全角色 / 坦克 / 奶媽 / DPS」按鈕切換，或在設定中選擇。

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
