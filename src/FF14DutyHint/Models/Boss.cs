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

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("phases")]
    public List<Phase> Phases { get; set; } = new();
}
