using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using FF14DutyHint.Models;
using FF14DutyHint.Services;

namespace FF14DutyHint.Views;

public partial class DutySelectionWindow : Window
{
    private const string AllExpansions = "全部版本";

    private readonly List<Duty> _allDuties;
    private string _selectedExpansion = AllExpansions;
    private string _selectedType = "";

    public Duty? SelectedDuty { get; private set; }

    public DutySelectionWindow(List<Duty> duties, string? currentDutyId)
    {
        InitializeComponent();
        _allDuties = duties;

        // 從資料中收集所有 expansion，依名稱排序
        var expansions = duties
            .Select(d => d.Expansion ?? "")
            .Where(e => !string.IsNullOrWhiteSpace(e))
            .Distinct()
            .OrderBy(e => e, StringComparer.Ordinal)
            .ToList();

        ExpansionCombo.Items.Add(AllExpansions);
        foreach (var exp in expansions)
        {
            ExpansionCombo.Items.Add(exp);
        }
        ExpansionCombo.SelectedIndex = 0;

        ApplyFilter();

        if (!string.IsNullOrEmpty(currentDutyId))
        {
            var current = duties.FirstOrDefault(d => d.Id == currentDutyId);
            if (current is not null)
            {
                DutyListBox.SelectedItem = current;
                DutyListBox.ScrollIntoView(current);
            }
        }
        if (DutyListBox.SelectedIndex < 0 && DutyListBox.Items.Count > 0)
        {
            DutyListBox.SelectedIndex = 0;
        }

        Loaded += (_, _) => SearchBox.Focus();
    }

    private void ApplyFilter()
    {
        var keyword = SearchBox?.Text?.Trim() ?? string.Empty;

        var query = _allDuties.AsEnumerable();

        // 版本篩選
        if (_selectedExpansion != AllExpansions)
        {
            query = query.Where(d =>
                string.Equals(d.Expansion, _selectedExpansion, StringComparison.Ordinal));
        }

        // 類型篩選
        if (!string.IsNullOrEmpty(_selectedType))
        {
            query = query.Where(d =>
                string.Equals(d.Type, _selectedType, StringComparison.OrdinalIgnoreCase));
        }

        // 關鍵字篩選
        if (!string.IsNullOrEmpty(keyword))
        {
            query = query.Where(d =>
                (d.Name?.Contains(keyword, StringComparison.OrdinalIgnoreCase) ?? false) ||
                (d.NameEn?.Contains(keyword, StringComparison.OrdinalIgnoreCase) ?? false) ||
                (d.Expansion?.Contains(keyword, StringComparison.OrdinalIgnoreCase) ?? false));
        }

        var filtered = query
            .OrderBy(d => d.Expansion ?? string.Empty, StringComparer.Ordinal)
            .ThenBy(d => GetTypeSortOrder(d.Type))
            .ThenBy(d => d.JobLevelSync ?? 0)
            .ThenBy(d => GetBaseName(d.NameEn ?? d.Name ?? string.Empty), StringComparer.OrdinalIgnoreCase)
            .ThenBy(d => GetDifficultyOrder(d.NameEn ?? d.Name ?? string.Empty))
            .ThenBy(d => d.NameEn ?? d.Name ?? string.Empty, StringComparer.OrdinalIgnoreCase)
            .ToList();
        DutyListBox.ItemsSource = filtered;

        ResultCountText.Text = filtered.Count == _allDuties.Count
            ? $"全部 {filtered.Count} 個副本"
            : $"{filtered.Count} / {_allDuties.Count} 個副本";
    }

    private static int GetTypeSortOrder(string? type)
    {
        return (type ?? string.Empty).ToLowerInvariant() switch
        {
            "dungeon" => 1,
            "trial" => 2,
            "raid" => 3,
            "alliance" => 4,
            "ultimate" => 5,
            _ => 9
        };
    }

    /// <summary>取得副本基底名稱（移除 (Hard)、(Extreme)、(Savage) 等難度後綴與 ' - 蠻神' 後綴）。</summary>
    private static string GetBaseName(string name)
    {
        if (string.IsNullOrEmpty(name)) return string.Empty;
        // 移除 " - <primal>" 後綴
        var dashIdx = name.LastIndexOf(" - ", StringComparison.Ordinal);
        var s = dashIdx > 0 ? name[..dashIdx] : name;
        // 移除常見難度括號後綴
        var suffixes = new[] { " (Hard)", " (Extreme)", " (Savage)", " (Ultimate)", " (殲滅戰)", " (殲殛戰)", " (困難)", " (零式)", " (絕境戰)" };
        foreach (var suffix in suffixes)
        {
            if (s.EndsWith(suffix, StringComparison.OrdinalIgnoreCase))
            {
                s = s[..^suffix.Length];
                break;
            }
        }
        return s.Trim();
    }

    /// <summary>解析副本名稱的難度順序（normal < hard < extreme < savage < ultimate）。</summary>
    private static int GetDifficultyOrder(string name)
    {
        if (string.IsNullOrEmpty(name)) return 0;
        var lower = name.ToLowerInvariant();
        if (lower.Contains("(ultimate)") || lower.Contains("絕境戰") || lower.Contains("ultimate ")) return 5;
        if (lower.Contains("(savage)") || lower.Contains("零式")) return 4;
        if (lower.Contains("(extreme)") || lower.Contains("殲殛戰") || lower.Contains("(極)")) return 3;
        if (lower.Contains("(hard)") || lower.Contains("殲滅戰") || lower.Contains("(困難)")) return 2;
        return 1;
    }

    private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
    {
        ApplyFilter();
    }

    private void ExpansionCombo_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (ExpansionCombo.SelectedItem is string exp)
        {
            _selectedExpansion = exp;
            ApplyFilter();
        }
    }

    private void TypeFilter_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not ToggleButton clicked)
        {
            return;
        }

        // 互斥：所有 ToggleButton 只能有一個 IsChecked
        foreach (var child in TypeFilterPanel.Children)
        {
            if (child is ToggleButton tb && tb != clicked)
            {
                tb.IsChecked = false;
            }
        }
        // 若使用者反向取消 → 退回 "全部"
        if (clicked.IsChecked != true)
        {
            TypeAllBtn.IsChecked = true;
            _selectedType = "";
        }
        else
        {
            _selectedType = clicked.Tag as string ?? "";
        }
        ApplyFilter();
    }

    private void DutyListBox_MouseDoubleClick(object sender, MouseButtonEventArgs e)
    {
        if (DutyListBox.SelectedItem is Duty)
        {
            ConfirmSelection();
        }
    }

    private void Ok_Click(object sender, RoutedEventArgs e) => ConfirmSelection();

    private void Cancel_Click(object sender, RoutedEventArgs e)
    {
        DialogResult = false;
        Close();
    }

    private void OpenBuiltInFolder_Click(object sender, RoutedEventArgs e)
    {
        OpenFolder(DutyLoader.GetBuiltInDirectory());
    }

    private void OpenUserFolder_Click(object sender, RoutedEventArgs e)
    {
        var dir = DutyLoader.GetUserAppDataDirectory();
        Directory.CreateDirectory(dir);
        OpenFolder(dir);
    }

    private void OpenFolder(string dir)
    {
        try
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = dir,
                UseShellExecute = true
            });
        }
        catch (System.Exception ex)
        {
            MessageBox.Show($"無法開啟資料夾：{ex.Message}", "錯誤", MessageBoxButton.OK, MessageBoxImage.Warning);
        }
    }

    private void ConfirmSelection()
    {
        if (DutyListBox.SelectedItem is Duty duty)
        {
            SelectedDuty = duty;
            DialogResult = true;
            Close();
        }
    }
}

