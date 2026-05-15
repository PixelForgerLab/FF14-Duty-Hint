using System.Text.Json.Serialization;

namespace FF14DutyHint.Services;

/// <summary>
/// 使用者偏好設定。
/// </summary>
public class AppSettings
{
    [JsonPropertyName("opacity")]
    public double Opacity { get; set; } = 0.85;

    [JsonPropertyName("fontSize")]
    public double FontSize { get; set; } = 14.0;

    [JsonPropertyName("topmost")]
    public bool Topmost { get; set; } = true;

    [JsonPropertyName("windowLeft")]
    public double WindowLeft { get; set; } = double.NaN;

    [JsonPropertyName("windowTop")]
    public double WindowTop { get; set; } = double.NaN;

    [JsonPropertyName("windowWidth")]
    public double WindowWidth { get; set; } = 480;

    [JsonPropertyName("windowHeight")]
    public double WindowHeight { get; set; } = 640;

    [JsonPropertyName("lastDutyId")]
    public string? LastDutyId { get; set; }
}
