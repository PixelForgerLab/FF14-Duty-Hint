# Duty Hint Rewrite Pipeline — 工作規則

本文件定義 `data/duties/*.json` 重寫的標準流程與資料來源規則。

## 資料來源優先順序

### 1. 名稱（副本名、Boss 名、技能名、Add 名、地形 / Debuff 名）

**強制以灰機 wiki 為主，再簡轉繁（S→T）轉成繁中。**

| 項目 | 先去哪找 | 找不到時 |
|---|---|---|
| 副本名 | 灰機 wiki 搜尋 EN 名（base：取 top-1；hard：搜尋 `<EN name> Hard`） | Lodestone EN→ZH 對應、CGW 別名表 |
| Boss 名 | 灰機 wiki 中該副本頁的 `/1` `/2` `/3` `/B` 子頁面內的 boss link（如 `{{xl|夺神魔}}`） | LM 直接翻譯英文 |
| 技能名 | 灰機 wiki 子頁面中的 skill link（如 `{{xh|虚空爆炎|魔法}}`），或單獨的技能頁 | LM 直接翻譯英文 |
| Add / Debuff 名 | 灰機 wiki 子頁面內提到的相關詞條 | LM 直接翻譯 |

**S→T 規則**：由 LM（本助手）即時轉換，不用 `Convert-S2T.ps1`，不用 `.NET StrConv`。
品質要點：保留 FF14 專有譯名（如「萬魔殿」「黃道」），不要機械轉換。

### 2. 攻略心得（機制描述、流程、解法、角色 Tips）

**全網路綜合**：CGW、Lodestone、灰機 `/B` 子頁面、Reddit、巴哈姆特、game8、icy-veins、xivjpraids、kanatan、Allagan-style guides 等都可以參考。

灰機 `/B` 子頁面通常有 zh-CN 機制概述（簡短）；CGW 副本頁通常有完整英文 walkthrough；可互補。

## 灰機 wiki 子頁面慣例（重要！）

`<副本名>/B` 是「最終 boss」攻略頁；中間 boss 在 `/1` `/2` `/3` 子頁面。例如：

- 邪教驻地无限城古堡/1  ← B1 奪神魔（Psycheflayer）
- 邪教驻地无限城古堡/2  ← B2 惡魔牆（Demon Wall）
- 邪教驻地无限城古堡/B  ← B3 阿難塔波嘉（Anantaboga）

**每個副本都要把 /1 /2 /3 /B 都試抓**（404 就跳過，會擋 cache）。

## 每副本處理流程

1. 從 `duty_review_queue` SQL 表取 `status='pending'` 的下一筆。
2. 灰機搜尋副本英文名 → 取得 zh-CN 副本名（hard 用 `EN Hard` 額外搜尋）。
3. 抓 `<duty>/1` `/2` `/3` `/B` 子頁面 → 解析 boss 名、技能名、機制概述。
4. 抓 CGW `<EN name>` 副本頁 → 取得完整 walkthrough、roles tips 提示。
5. （可選）抓 Lodestone duty page、Allagan style guide 補充。
6. LM 整合：
   - 副本/Boss/技能名 → 灰機 zh-CN，LM 即時 S→T。
   - 機制描述 → 整合所有來源；雙語化（中文 + 英文技能名）。
   - 每個 mechanic 必填 `name`、`type`、`description`、`tips[]`；tips 盡量帶 `role` 標籤。
7. 寫回 `data/duties/<id>.json`。
8. 更新 `duty_review_queue.status = 'done'`、`last_pass_at`、`huiji_title`。
9. 每完成 10 個 commit + push 一次。

## 品質通過標準

| 副本類型 | bosses | mechanics（合計） | avg desc | bilingual | mnemonic |
|---|---|---|---|---|---|
| dungeon | ≥ 3 | ≥ 5 | ≥ 22 | ≥ 80% | ≥ 3 |
| variant dungeon | ≥ 1 | ≥ 5 | ≥ 22 | ≥ 80% | ≥ 3 |
| trial | — | ≥ 4 | ≥ 25 | ≥ 80% | ≥ 3 |
| raid 8p | — | ≥ 4 | ≥ 22 | ≥ 80% | ≥ 3 |
| raid 24p | ≥ 3 | ≥ 6 | ≥ 22 | ≥ 80% | ≥ 3 |
| ultimate | — | ≥ 10 | ≥ 35 | ≥ 80% | ≥ 4 |

mechanic 的 `type` 可選：`raidwide`、`aoe`、`cone`、`tankbuster`、`stack`、`spread`、`knockback`、`interrupt`、`dispel`、`add`、`mechanic`、`other`。

## 例外處理

- 灰機完全沒有副本條目：標記 `status='no-huiji'`，照常用 CGW + Lodestone，技能名用 LM 翻譯。
- CGW 也沒有：標記 `quality='needs-update'`、`status='no-data'`，保留現有 JSON。
- 季節活動（special_event_*）：先放置，最後再處理。

## 灰機 API 速率

- UA: `FF14HintBot/1.0 (https://github.com/PixelForgerLab/FF14-Duty-Hint)`
- 抓取間隔：3 秒（被 CF 擋住先停 2–10 分鐘再重試）
- Cache 路徑：`tools/duty-pipeline/data/cache/huiji/<title>.wikitext`

## 範例：amdapor_keep（v1.2.25 demo）

- 副本：`Amdapor Keep` → 灰機 `邪教驻地无限城古堡` → `邪教駐地無限城古堡`
- B1：灰機 `夺神魔` → `奪神魔`（Psycheflayer）；技能取自 `/1` 子頁面 `闪雷`/`虚空爆炎`/`召唤妖异`/`流水`/`虚空暴雷`/`精神瓦解`/`溃疡`/`岩石崩溃`/`破魔震`/`平原震裂`
- B2：灰機 `恶魔墙` → `惡魔牆`（Demon Wall）；技能取自 `/2` 子頁面 `谋杀洞`/`液化`/`击退`/`虚空淤泥`
- B3：灰機 `阿难塔波嘉` → `阿難塔波嘉`（Anantaboga）；技能取自 `/B` 子頁面 `诡异视线`/`尾部打击`/`腐烂吐息`/`天灾降临`/`恐怖眼`/`疫病云`
- 結果：24 機制、100% 雙語、avg desc 66 字、3 條頂層助記、30/34 tips 帶 role
