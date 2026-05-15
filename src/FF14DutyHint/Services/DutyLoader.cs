using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using FF14DutyHint.Models;

namespace FF14DutyHint.Services;

/// <summary>
/// 從 data/duties 目錄載入所有 .json 副本檔案。
/// 載入順序：與 exe 同層的 data/duties，找不到時退回原始碼目錄。
/// </summary>
public static class DutyLoader
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true
    };

    public static string GetDataDirectory()
    {
        var exeDir = AppContext.BaseDirectory;
        var primary = Path.Combine(exeDir, "data", "duties");
        if (Directory.Exists(primary))
        {
            return primary;
        }

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

    public static List<Duty> LoadAll()
    {
        var directory = GetDataDirectory();
        var results = new List<Duty>();

        if (!Directory.Exists(directory))
        {
            return results;
        }

        foreach (var file in Directory.EnumerateFiles(directory, "*.json", SearchOption.TopDirectoryOnly))
        {
            var fileName = Path.GetFileName(file);
            if (fileName.StartsWith("_", StringComparison.Ordinal))
            {
                continue;
            }

            try
            {
                using var stream = File.OpenRead(file);
                var duty = JsonSerializer.Deserialize<Duty>(stream, JsonOptions);
                if (duty is not null && !string.IsNullOrWhiteSpace(duty.Id))
                {
                    results.Add(duty);
                }
            }
            catch (JsonException ex)
            {
                System.Diagnostics.Debug.WriteLine($"[DutyLoader] 解析 {fileName} 失敗：{ex.Message}");
            }
            catch (IOException ex)
            {
                System.Diagnostics.Debug.WriteLine($"[DutyLoader] 讀取 {fileName} 失敗：{ex.Message}");
            }
        }

        return results
            .OrderBy(d => d.Expansion ?? string.Empty)
            .ThenBy(d => d.Name)
            .ToList();
    }
}
