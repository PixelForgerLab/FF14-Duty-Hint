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

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("bosses")]
    public List<Boss> Bosses { get; set; } = new();

    public string DisplayName =>
        string.IsNullOrWhiteSpace(NameEn) ? Name : $"{Name} ({NameEn})";
}
