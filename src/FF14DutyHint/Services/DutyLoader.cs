using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using FF14DutyHint.Models;

namespace FF14DutyHint.Services;

/// <summary>
/// Loader 的結果，包含載入的副本與警告訊息。
/// </summary>
public class DutyLoadResult
{
    public List<Duty> Duties { get; init; } = new();
    public List<string> Warnings { get; init; } = new();
}

/// <summary>
/// 從多個來源（內建 / APPDATA / 自訂資料夾）載入副本 JSON，
/// 依優先級覆寫合併（內建 < APPDATA < 自訂）。
/// </summary>
public static class DutyLoader
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true
    };

    /// <summary>內建資料夾（隨 exe 發佈）。</summary>
    public static string GetBuiltInDirectory()
    {
        var exeDir = AppContext.BaseDirectory;
        var primary = Path.Combine(exeDir, "data", "duties");
        if (Directory.Exists(primary))
        {
            return primary;
        }

        // 開發時 fallback：往上找 repo 根目錄的 data/duties
        var probe = new DirectoryInfo(exeDir);
        for (int i = 0; i < 6 && probe is not null; i++)
        {
            var candidate = Path.Combine(probe.FullName, "data", "duties");
            if (Directory.Exists(candidate))
            {
                return candidate;
            }
            probe = probe.Parent;
        }

        return primary;
    }

    /// <summary>使用者預設資料夾（%APPDATA%/FF14DutyHint/duties）。</summary>
    public static string GetUserAppDataDirectory()
    {
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        return Path.Combine(appData, "FF14DutyHint", "duties");
    }

    /// <summary>
    /// 依設定載入所有副本資料，依優先級合併：內建 → APPDATA → 自訂資料夾。
    /// </summary>
    public static DutyLoadResult LoadAll(AppSettings? settings = null)
    {
        var result = new DutyLoadResult();
        var dutyById = new Dictionary<string, Duty>(StringComparer.OrdinalIgnoreCase);

        // 1. 內建（最低優先級）
        LoadFromDirectory(GetBuiltInDirectory(), DutySource.BuiltIn, dutyById, result.Warnings);

        // 2. APPDATA
        var appDataDir = GetUserAppDataDirectory();
        if (Directory.Exists(appDataDir))
        {
            LoadFromDirectory(appDataDir, DutySource.UserAppData, dutyById, result.Warnings);
        }

        // 3. 自訂資料夾（最高優先級）
        var custom = settings?.CustomDutyFolder?.Trim();
        if (!string.IsNullOrEmpty(custom))
        {
            if (Directory.Exists(custom))
            {
                LoadFromDirectory(custom, DutySource.UserCustomFolder, dutyById, result.Warnings);
            }
            else
            {
                result.Warnings.Add($"自訂資料夾不存在：{custom}");
            }
        }

        result.Duties.AddRange(
            dutyById.Values
                .OrderBy(d => d.Expansion ?? string.Empty)
                .ThenBy(d => d.Name)
        );

        return result;
    }

    private static void LoadFromDirectory(
        string directory,
        DutySource source,
        Dictionary<string, Duty> bucket,
        List<string> warnings)
    {
        if (!Directory.Exists(directory))
        {
            return;
        }

        // 同一資料夾內依檔名排序，重複 id 取最後一個並警告（deterministic）
        var files = Directory.EnumerateFiles(directory, "*.json", SearchOption.TopDirectoryOnly)
            .Where(f => !Path.GetFileName(f).StartsWith("_", StringComparison.Ordinal))
            .OrderBy(f => f, StringComparer.OrdinalIgnoreCase);

        var seenInThisDir = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var file in files)
        {
            var fileName = Path.GetFileName(file);
            Duty? duty;
            try
            {
                using var stream = File.OpenRead(file);
                duty = JsonSerializer.Deserialize<Duty>(stream, JsonOptions);
            }
            catch (JsonException ex)
            {
                warnings.Add($"[{source}] {fileName} JSON 解析失敗：{ex.Message}");
                continue;
            }
            catch (IOException ex)
            {
                warnings.Add($"[{source}] {fileName} 讀取失敗：{ex.Message}");
                continue;
            }

            if (duty is null || string.IsNullOrWhiteSpace(duty.Id))
            {
                warnings.Add($"[{source}] {fileName} 缺少 id 或為空，已略過。");
                continue;
            }

            if (string.IsNullOrWhiteSpace(duty.Name))
            {
                warnings.Add($"[{source}] {fileName} 缺少 name，已略過。");
                continue;
            }

            if (!seenInThisDir.Add(duty.Id))
            {
                warnings.Add($"[{source}] {fileName} 與同資料夾中其他檔案的 id «{duty.Id}» 重複，以此檔覆蓋。");
            }

            duty.Source = source;
            duty.SourcePath = file;

            if (bucket.TryGetValue(duty.Id, out var existing))
            {
                if (existing.Source != source)
                {
                    duty.OverridesBuiltIn = true;
                }
            }

            bucket[duty.Id] = duty;
        }
    }
}

