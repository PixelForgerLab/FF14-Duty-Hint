using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace FF14DutyHint.Models;

/// <summary>
/// Boss 戰中的一個階段（Phase）。
/// </summary>
public class Phase
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("mechanics")]
    public List<Mechanic> Mechanics { get; set; } = new();
}
