using System;
using System.IO;
using System.Text.Json;

namespace FF14DutyHint.Services;

/// <summary>
/// 將 AppSettings 持久化到 %APPDATA%/FF14DutyHint/settings.json。
/// </summary>
public static class SettingsService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true
    };

    public static string GetSettingsPath()
    {
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        var dir = Path.Combine(appData, "FF14DutyHint");
        Directory.CreateDirectory(dir);
        return Path.Combine(dir, "settings.json");
    }

    public static AppSettings Load()
    {
        var path = GetSettingsPath();
        if (!File.Exists(path))
        {
            return new AppSettings();
        }

        try
        {
            using var stream = File.OpenRead(path);
            return JsonSerializer.Deserialize<AppSettings>(stream, JsonOptions) ?? new AppSettings();
        }
        catch (Exception ex) when (ex is JsonException or IOException)
        {
            System.Diagnostics.Debug.WriteLine($"[SettingsService] 載入失敗：{ex.Message}");
            return new AppSettings();
        }
    }

    public static void Save(AppSettings settings)
    {
        try
        {
            var path = GetSettingsPath();
            using var stream = File.Create(path);
            JsonSerializer.Serialize(stream, settings, JsonOptions);
        }
        catch (Exception ex) when (ex is JsonException or IOException)
        {
            System.Diagnostics.Debug.WriteLine($"[SettingsService] 儲存失敗：{ex.Message}");
        }
    }
}
