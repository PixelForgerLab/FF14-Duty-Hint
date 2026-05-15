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

    /// <summary>簡易提示（單行或多行條列）。</summary>
    [JsonPropertyName("mnemonic")]
    public Mnemonic? Mnemonic { get; set; }

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("phases")]
    public List<Phase> Phases { get; set; } = new();

    [JsonIgnore]
    public bool HasMnemonic => Mnemonic?.HasContent ?? false;

    [JsonIgnore]
    public List<MnemonicLine> MnemonicLines => Mnemonic.ToDisplayLines();
}


