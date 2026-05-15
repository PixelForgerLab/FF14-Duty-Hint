using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace FF14DutyHint.Models;

/// <summary>
/// 一個機制提示。
/// </summary>
public class Mechanic
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// 機制類型：raidwide / tankbuster / stack / spread / aoe / other / ...
    /// 影響顯示時的顏色標籤。
    /// </summary>
    [JsonPropertyName("type")]
    public string? Type { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("tips")]
    public List<Tip> Tips { get; set; } = new();
}

