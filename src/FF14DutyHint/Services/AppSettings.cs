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

    /// <summary>
    /// 使用者自訂的副本資料夾路徑（最高優先級，會覆寫 APPDATA 與內建）。
    /// 空字串/null = 不啟用。
    /// </summary>
    [JsonPropertyName("customDutyFolder")]
    public string? CustomDutyFolder { get; set; }

    /// <summary>
    /// 偏好角色（用於過濾 tips）："tank" / "healer" / "dps" / "all"。
    /// 預設 all = 顯示所有角色 tip。
    /// </summary>
    [JsonPropertyName("preferredRole")]
    public string? PreferredRole { get; set; } = "all";

    /// <summary>「只看口訣」模式（隱藏 phases / mechanics）。</summary>
    [JsonPropertyName("mnemonicOnly")]
    public bool MnemonicOnly { get; set; }
}

