using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace FF14DutyHint.Models;

/// <summary>
/// 一個副本（如「絕望的樂園 第九層：零式」）的完整提示資料。
/// </summary>
public class Duty
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("nameEn")]
    public string? NameEn { get; set; }

    [JsonPropertyName("expansion")]
    public string? Expansion { get; set; }

    [JsonPropertyName("type")]
    public string? Type { get; set; }

    [JsonPropertyName("playerCount")]
    public int? PlayerCount { get; set; }

    [JsonPropertyName("iLvlSync")]
    public int? ILvlSync { get; set; }

    [JsonPropertyName("jobLevelSync")]
    public int? JobLevelSync { get; set; }

    [JsonPropertyName("highEnd")]
    public bool HighEnd { get; set; }

    /// <summary>
    /// JSON 中的 quality 欄位字串，由 <see cref="Quality"/> 解析。
    /// </summary>
    [JsonPropertyName("quality")]
    public string? QualityRaw { get; set; }

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("bosses")]
    public List<Boss> Bosses { get; set; } = new();

    /// <summary>
    /// 解析後的品質等級。若 JSON 未指定 quality 但 bosses 為空，自動推斷為 Skeleton；
    /// 其他情況保留為 Unspecified（不顯示徽章）。
    /// </summary>
    [JsonIgnore]
    public DutyQuality Quality
    {
        get
        {
            var raw = (QualityRaw ?? "").Trim().ToLowerInvariant();
            return raw switch
            {
                "excellent" => DutyQuality.Excellent,
                "needs-update" or "needsupdate" => DutyQuality.NeedsUpdate,
                "skeleton" => DutyQuality.Skeleton,
                _ => Bosses.Count == 0 ? DutyQuality.Skeleton : DutyQuality.Unspecified
            };
        }
    }

    /// <summary>來源（內建/使用者）— Loader 設定，不會序列化。</summary>
    [JsonIgnore]
    public DutySource Source { get; set; } = DutySource.BuiltIn;

    /// <summary>該 Duty 是否覆寫了內建檔案。— Loader 設定。</summary>
    [JsonIgnore]
    public bool OverridesBuiltIn { get; set; }

    /// <summary>原始 JSON 檔案路徑（供 UI 顯示來源）— Loader 設定。</summary>
    [JsonIgnore]
    public string? SourcePath { get; set; }

    public string DisplayName =>
        string.IsNullOrWhiteSpace(NameEn) ? Name : $"{Name} ({NameEn})";
}

