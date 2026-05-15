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

        // 品質徽章
        ApplyQualityBadge(duty.Quality);
        // 來源徽章
        ApplySourceBadge(duty);

        if (!string.IsNullOrWhiteSpace(duty.Notes))
        {
            DutyNotesText.Text = duty.Notes;
            DutyNotesBorder.Visibility = Visibility.Visible;
        }
        else
        {
            DutyNotesBorder.Visibility = Visibility.Collapsed;
        }

        BossList.ItemsSource = duty.Bosses;
        if (duty.Bosses.Count == 0)
        {
            EmptyHintText.Text = NoMechanicsHint;
            EmptyHintText.Visibility = Visibility.Visible;
        }
        else
        {
            EmptyHintText.Visibility = Visibility.Collapsed;
        }

        _settings.LastDutyId = duty.Id;
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
