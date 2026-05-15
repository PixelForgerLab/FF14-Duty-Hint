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
        // 套用 WS_EX_NOACTIVATE：在遊戲中點擊 Overlay 不會偷走焦點，
        // 也順帶 WS_EX_TOOLWINDOW 從 Alt+Tab 清單隱藏。
        WindowInterop.MakeOverlayWindow(this);
    }

    private void OnLoaded(object sender, RoutedEventArgs e)
    {
        _settings = SettingsService.Load();
        ApplySettings();

        _duties = DutyLoader.LoadAll();

        // 還原上次選的副本
        if (!string.IsNullOrEmpty(_settings.LastDutyId))
        {
            var last = _duties.FirstOrDefault(d => d.Id == _settings.LastDutyId);
            if (last is not null)
            {
                SetDuty(last);
            }
        }

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

    private void RaiseFontProperties()
    {
        OnPropertyChanged(nameof(HeaderFontSize));
        OnPropertyChanged(nameof(BossFontSize));
        OnPropertyChanged(nameof(PhaseFontSize));
        OnPropertyChanged(nameof(BodyFontSize));
    }

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
        EmptyHintText.Visibility = duty.Bosses.Count == 0 ? Visibility.Visible : Visibility.Collapsed;

        _settings.LastDutyId = duty.Id;
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
        dlg.SettingsChanged += s =>
        {
            _settings = s;
            Opacity = Math.Clamp(_settings.Opacity, 0.2, 1.0);
            Topmost = _settings.Topmost;
            RaiseFontProperties();
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
