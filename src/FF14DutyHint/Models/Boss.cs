using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace FF14DutyHint.Models;

/// <summary>
/// 副本中的一個 Boss。
/// </summary>
public class Boss
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("nameEn")]
    public string? NameEn { get; set; }

    /// <summary>一句話口訣，可在「只看口訣」模式顯示。</summary>
    [JsonPropertyName("mnemonic")]
    public string? Mnemonic { get; set; }

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("phases")]
    public List<Phase> Phases { get; set; } = new();
}

