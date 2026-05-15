using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows;
using System.Windows.Input;
using FF14DutyHint.Helpers;
using FF14DutyHint.Models;
using FF14DutyHint.Services;
using FF14DutyHint.Views;

namespace FF14DutyHint;

public partial class MainWindow : Window, INotifyPropertyChanged
{
    private AppSettings _settings = new();
    private List<Duty> _duties = new();
    private List<string> _lastLoadWarnings = new();
    private Duty? _currentDuty;
    private bool _initialized;

    public MainWindow()
    {
        InitializeComponent();
        DataContext = this;

        Loaded += OnLoaded;
        Closing += OnClosing;
    }

    public double HeaderFontSize => Math.Round(_settings.FontSize + 4);
    public double BossFontSize => Math.Round(_settings.FontSize + 2);
    public double PhaseFontSize => Math.Round(_settings.FontSize + 1);
    public double BodyFontSize => _settings.FontSize;

    protected override void OnSourceInitialized(EventArgs e)
    {
        base.OnSourceInitialized(e);
        WindowInterop.MakeOverlayWindow(this);
    }

    private void OnLoaded(object sender, RoutedEventArgs e)
    {
        _settings = SettingsService.Load();
        ApplySettings();
        ReloadDuties();
        RaiseFontProperties();
        _initialized = true;
    }

    private void OnClosing(object? sender, CancelEventArgs e)
    {
        if (!_initialized)
        {
            return;
        }

        _settings.WindowLeft = Left;
        _settings.WindowTop = Top;
        _settings.WindowWidth = Width;
        _settings.WindowHeight = Height;
        SettingsService.Save(_settings);
    }

    private void ApplySettings()
    {
        Opacity = Math.Clamp(_settings.Opacity, 0.2, 1.0);
        Topmost = _settings.Topmost;

        if (!double.IsNaN(_settings.WindowLeft) && !double.IsNaN(_settings.WindowTop))
        {
            Left = _settings.WindowLeft;
            Top = _settings.WindowTop;
        }
        if (_settings.WindowWidth > 0)
        {
            Width = _settings.WindowWidth;
        }
        if (_settings.WindowHeight > 0)
        {
            Height = _settings.WindowHeight;
        }
    }

    /// <summary>從各來源（內建/APPDATA/自訂資料夾）重新載入所有副本，並保留目前選擇。</summary>
    private void ReloadDuties()
    {
        var previousId = _currentDuty?.Id ?? _settings.LastDutyId;

        var loadResult = DutyLoader.LoadAll(_settings);
        _duties = loadResult.Duties;
        _lastLoadWarnings = loadResult.Warnings;

        UpdateWarningBanner();

        if (!string.IsNullOrEmpty(previousId))
        {
            var matching = _duties.FirstOrDefault(d =>
                string.Equals(d.Id, previousId, StringComparison.OrdinalIgnoreCase));
            if (matching is not null)
            {
                SetDuty(matching);
                return;
            }
        }

        // 第一次或找不到對應 → 顯示「請選副本」空畫面
        if (_currentDuty is null)
        {
            SetDuty(null);
        }
    }

    private void UpdateWarningBanner()
    {
        if (_lastLoadWarnings.Count == 0)
        {
            WarningBanner.Visibility = Visibility.Collapsed;
            WarningBannerText.Text = string.Empty;
            return;
        }

        WarningBannerText.Text = $"⚠ {_lastLoadWarnings.Count} 個資料載入警告（按此查看）";
        WarningBanner.Visibility = Visibility.Visible;
    }

    private void WarningBanner_Click(object sender, MouseButtonEventArgs e)
    {
        if (_lastLoadWarnings.Count == 0)
        {
            return;
        }

        var msg = string.Join("\n\n", _lastLoadWarnings.Take(20));
        if (_lastLoadWarnings.Count > 20)
        {
            msg += $"\n\n... 還有 {_lastLoadWarnings.Count - 20} 則。";
        }
        MessageBox.Show(this, msg, "資料載入警告", MessageBoxButton.OK, MessageBoxImage.Warning);
    }

    private void RaiseFontProperties()
    {
        OnPropertyChanged(nameof(HeaderFontSize));
        OnPropertyChanged(nameof(BossFontSize));
        OnPropertyChanged(nameof(PhaseFontSize));
        OnPropertyChanged(nameof(BodyFontSize));
    }

    private const string NoDutyHint = "👈 點選右上「副本」按鈕，選擇要顯示的副本提示。";
    private const string NoMechanicsHint = "🚧 此副本目前沒有詳細機制提示。\n\n你可以到 GitHub 透過 PR 貢獻你的攻略筆記！\nhttps://github.com/PixelForgerLab/FF14-Duty-Hint\n\n或者點右上「副本」選擇其他副本。";
    private const string MnemonicOnlyNoneHint = "ℹ 此副本（與每個 Boss）目前沒有口訣資料。\n\n切換到「全部」模式即可看到完整機制。";

    private void SetDuty(Duty? duty)
    {
        _currentDuty = duty;

        if (duty is null)
        {
            DutyNameText.Text = "（尚未選擇副本）";
            DutyMetaText.Text = string.Empty;
            DutyNotesBorder.Visibility = Visibility.Collapsed;
            DutyNotesText.Text = string.Empty;
            BossList.ItemsSource = null;
            QualityBadge.Visibility = Visibility.Collapsed;
            SourceBadge.Visibility = Visibility.Collapsed;
            DutyMnemonicBorder.Visibility = Visibility.Collapsed;
            EmptyHintText.Text = NoDutyHint;
            EmptyHintText.Visibility = Visibility.Visible;
            return;
        }

        DutyNameText.Text = duty.DisplayName;

        var metaParts = new List<string>();
        if (!string.IsNullOrWhiteSpace(duty.Expansion)) metaParts.Add(duty.Expansion!);
        if (!string.IsNullOrWhiteSpace(duty.Type)) metaParts.Add(duty.Type!);
        if (duty.PlayerCount is int pc) metaParts.Add($"{pc}人");
        if (duty.JobLevelSync is int jl && jl > 0) metaParts.Add($"Lv {jl}");
        if (duty.ILvlSync is int il && il > 0) metaParts.Add($"iLvl {il}");
        if (duty.HighEnd) metaParts.Add("★ 高難度");
        DutyMetaText.Text = string.Join("  ·  ", metaParts);

        ApplyQualityBadge(duty.Quality);
        ApplySourceBadge(duty);

        // 副本口訣
        if (!string.IsNullOrWhiteSpace(duty.Mnemonic))
        {
            DutyMnemonicText.Text = duty.Mnemonic;
            DutyMnemonicBorder.Visibility = Visibility.Visible;
        }
        else
        {
            DutyMnemonicBorder.Visibility = Visibility.Collapsed;
        }

        if (!string.IsNullOrWhiteSpace(duty.Notes))
        {
            DutyNotesText.Text = duty.Notes;
            DutyNotesBorder.Visibility = Visibility.Visible;
        }
        else
        {
            DutyNotesBorder.Visibility = Visibility.Collapsed;
        }

        RenderBossList(duty);

        _settings.LastDutyId = duty.Id;
        UpdateMnemonicToggleButton();
        UpdateRoleToggleButton();
    }

    /// <summary>
    /// 根據目前 PreferredRole + MnemonicOnly 設定，重新組裝顯示用的 Boss 清單。
    /// 不會修改原始 duty 資料。
    /// </summary>
    private void RenderBossList(Duty duty)
    {
        var userRole = PlayerRoleExtensions.ParseRole(_settings.PreferredRole);
        bool filterByRole = !string.Equals(_settings.PreferredRole, "all", StringComparison.OrdinalIgnoreCase);

        var bosses = new List<Boss>();
        foreach (var boss in duty.Bosses)
        {
            var bossCopy = new Boss
            {
                Name = boss.Name,
                NameEn = boss.NameEn,
                Mnemonic = boss.Mnemonic,
                Notes = boss.Notes,
                Phases = new List<Phase>()
            };

            if (_settings.MnemonicOnly)
            {
                // 只看口訣模式：保留 boss header，不顯示 phases
                bosses.Add(bossCopy);
                continue;
            }

            foreach (var phase in boss.Phases)
            {
                var phaseCopy = new Phase
                {
                    Name = phase.Name,
                    Notes = phase.Notes,
                    Mechanics = new List<Mechanic>()
                };

                foreach (var mech in phase.Mechanics)
                {
                    var mechCopy = new Mechanic
                    {
                        Name = mech.Name,
                        Type = mech.Type,
                        Description = mech.Description,
                        Tips = filterByRole
                            ? mech.Tips.Where(t => t.Role == PlayerRole.Universal || t.Role == userRole).ToList()
                            : mech.Tips
                    };
                    phaseCopy.Mechanics.Add(mechCopy);
                }
                bossCopy.Phases.Add(phaseCopy);
            }
            bosses.Add(bossCopy);
        }

        BossList.ItemsSource = bosses;

        // 空狀態提示
        bool anyContent = bosses.Count > 0 && !(
            _settings.MnemonicOnly &&
            string.IsNullOrWhiteSpace(duty.Mnemonic) &&
            bosses.All(b => string.IsNullOrWhiteSpace(b.Mnemonic))
        );

        if (duty.Bosses.Count == 0)
        {
            EmptyHintText.Text = NoMechanicsHint;
            EmptyHintText.Visibility = Visibility.Visible;
        }
        else if (_settings.MnemonicOnly && !anyContent)
        {
            EmptyHintText.Text = MnemonicOnlyNoneHint;
            EmptyHintText.Visibility = Visibility.Visible;
        }
        else
        {
            EmptyHintText.Visibility = Visibility.Collapsed;
        }
    }

    private void UpdateMnemonicToggleButton()
    {
        MnemonicToggleButton.Content = _settings.MnemonicOnly ? "口訣" : "全部";
        MnemonicToggleButton.ToolTip = _settings.MnemonicOnly
            ? "目前：只看口訣（按一下切換為全部）"
            : "目前：全部顯示（按一下切換為只看口訣）";
    }

    private void UpdateRoleToggleButton()
    {
        var role = PlayerRoleExtensions.ParseRole(_settings.PreferredRole);
        bool all = string.Equals(_settings.PreferredRole, "all", StringComparison.OrdinalIgnoreCase);
        RoleToggleButton.Content = all ? "全角色" : role.ToDisplayLabel();
        RoleToggleButton.ToolTip = all
            ? "目前：顯示全角色 tip（按一下切換）"
            : $"目前：只顯示 {role.ToDisplayLabel()} + 通用 tip（按一下切換）";
    }

    private void MnemonicToggle_Click(object sender, RoutedEventArgs e)
    {
        _settings.MnemonicOnly = !_settings.MnemonicOnly;
        if (_currentDuty is not null)
        {
            RenderBossList(_currentDuty);
        }
        UpdateMnemonicToggleButton();
    }

    private void RoleToggle_Click(object sender, RoutedEventArgs e)
    {
        // 循環：all -> tank -> healer -> dps -> all
        var current = (_settings.PreferredRole ?? "all").ToLowerInvariant();
        _settings.PreferredRole = current switch
        {
            "all" => "tank",
            "tank" => "healer",
            "healer" => "dps",
            _ => "all"
        };
        if (_currentDuty is not null)
        {
            RenderBossList(_currentDuty);
        }
        UpdateRoleToggleButton();
    }

    private void ApplyQualityBadge(DutyQuality q)
    {
        if (q == DutyQuality.Unspecified)
        {
            QualityBadge.Visibility = Visibility.Collapsed;
            return;
        }

        var (label, bg) = q switch
        {
            DutyQuality.Excellent => ("優秀", System.Windows.Media.Color.FromRgb(0xFF, 0xC1, 0x07)),
            DutyQuality.NeedsUpdate => ("需更新", System.Windows.Media.Color.FromRgb(0xFB, 0x8C, 0x00)),
            DutyQuality.Skeleton => ("骨架", System.Windows.Media.Color.FromRgb(0x60, 0x60, 0x68)),
            _ => ("", System.Windows.Media.Colors.Transparent)
        };
        QualityBadgeText.Text = label;
        QualityBadge.Background = new System.Windows.Media.SolidColorBrush(bg);
        QualityBadge.Visibility = Visibility.Visible;
    }

    private void ApplySourceBadge(Duty duty)
    {
        if (duty.Source == DutySource.BuiltIn && !duty.OverridesBuiltIn)
        {
            SourceBadge.Visibility = Visibility.Collapsed;
            return;
        }

        var label = duty.Source switch
        {
            DutySource.UserAppData => "自訂",
            DutySource.UserCustomFolder => "自訂*",
            _ => string.Empty
        };
        if (duty.OverridesBuiltIn)
        {
            SourceBadge.ToolTip = $"來自 {duty.SourcePath}（覆寫了內建資料）";
        }
        else
        {
            SourceBadge.ToolTip = $"來自 {duty.SourcePath}";
        }
        SourceBadgeText.Text = label;
        SourceBadge.Visibility = Visibility.Visible;
    }

    private void TitleBar_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            try { DragMove(); } catch { /* ignore re-entry */ }
        }
    }

    private void SelectDuty_Click(object sender, RoutedEventArgs e)
    {
        var dlg = new DutySelectionWindow(_duties, _currentDuty?.Id) { Owner = this };
        if (dlg.ShowDialog() == true && dlg.SelectedDuty is not null)
        {
            SetDuty(dlg.SelectedDuty);
        }
    }

    private void OpenSettings_Click(object sender, RoutedEventArgs e)
    {
        var dlg = new SettingsWindow(_settings) { Owner = this };
        dlg.AppearanceChanged += s =>
        {
            _settings = s;
            Opacity = Math.Clamp(_settings.Opacity, 0.2, 1.0);
            Topmost = _settings.Topmost;
            RaiseFontProperties();
        };
        dlg.DataSourceChanged += () =>
        {
            ReloadDuties();
        };
        dlg.DisplayModeChanged += () =>
        {
            if (_currentDuty is not null)
            {
                RenderBossList(_currentDuty);
            }
            UpdateMnemonicToggleButton();
            UpdateRoleToggleButton();
        };
        dlg.ShowDialog();
        SettingsService.Save(_settings);
    }

    private void Minimize_Click(object sender, RoutedEventArgs e)
    {
        WindowState = WindowState.Minimized;
    }

    private void Close_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }

    protected override void OnKeyDown(KeyEventArgs e)
    {
        base.OnKeyDown(e);
        if (Keyboard.Modifiers == ModifierKeys.Control)
        {
            switch (e.Key)
            {
                case Key.D:
                    SelectDuty_Click(this, new RoutedEventArgs());
                    e.Handled = true;
                    break;
                case Key.OemComma:
                    OpenSettings_Click(this, new RoutedEventArgs());
                    e.Handled = true;
                    break;
            }
        }
    }

    public event PropertyChangedEventHandler? PropertyChanged;
    private void OnPropertyChanged([CallerMemberName] string? name = null)
        => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}
