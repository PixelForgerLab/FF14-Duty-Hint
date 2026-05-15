using System;
using System.Diagnostics;
using System.IO;
using System.Windows;
using FF14DutyHint.Services;
using Microsoft.Win32;

namespace FF14DutyHint.Views;

public partial class SettingsWindow : Window
{
    private readonly AppSettings _settings;
    private bool _initialized;

    /// <summary>外觀設定變更（透明度、字體、置頂）— 主視窗即時套用。</summary>
    public event Action<AppSettings>? AppearanceChanged;

    /// <summary>資料來源變更（自訂資料夾）— 主視窗需重新載入副本。</summary>
    public event Action? DataSourceChanged;

    public SettingsWindow(AppSettings settings)
    {
        InitializeComponent();
        _settings = settings;

        OpacitySlider.Value = settings.Opacity;
        FontSizeSlider.Value = settings.FontSize;
        TopmostCheck.IsChecked = settings.Topmost;
        CustomFolderTextBox.Text = settings.CustomDutyFolder ?? string.Empty;
        UpdateValueTexts();
        UpdateCustomFolderWarning();
        _initialized = true;
    }

    private void UpdateValueTexts()
    {
        OpacityValueText.Text = $"{Math.Round(OpacitySlider.Value * 100)}%";
        FontSizeValueText.Text = $"{Math.Round(FontSizeSlider.Value)} pt";
    }

    private void UpdateCustomFolderWarning()
    {
        var folder = _settings.CustomDutyFolder;
        if (string.IsNullOrWhiteSpace(folder))
        {
            CustomFolderWarning.Visibility = Visibility.Collapsed;
            return;
        }
        if (!Directory.Exists(folder))
        {
            CustomFolderWarning.Text = $"⚠ 資料夾不存在：{folder}";
            CustomFolderWarning.Visibility = Visibility.Visible;
        }
        else
        {
            CustomFolderWarning.Visibility = Visibility.Collapsed;
        }
    }

    private void OpacitySlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
    {
        if (!_initialized) return;
        _settings.Opacity = OpacitySlider.Value;
        UpdateValueTexts();
        AppearanceChanged?.Invoke(_settings);
    }

    private void FontSizeSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
    {
        if (!_initialized) return;
        _settings.FontSize = Math.Round(FontSizeSlider.Value);
        UpdateValueTexts();
        AppearanceChanged?.Invoke(_settings);
    }

    private void TopmostCheck_Changed(object sender, RoutedEventArgs e)
    {
        if (!_initialized) return;
        _settings.Topmost = TopmostCheck.IsChecked == true;
        AppearanceChanged?.Invoke(_settings);
    }

    private void OpenUserFolder_Click(object sender, RoutedEventArgs e)
    {
        var dir = DutyLoader.GetUserAppDataDirectory();
        try
        {
            Directory.CreateDirectory(dir);
            Process.Start(new ProcessStartInfo
            {
                FileName = dir,
                UseShellExecute = true
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, $"無法開啟使用者資料夾：{ex.Message}", "錯誤",
                MessageBoxButton.OK, MessageBoxImage.Warning);
        }
    }

    private void BrowseCustom_Click(object sender, RoutedEventArgs e)
    {
        var initial = _settings.CustomDutyFolder;
        if (string.IsNullOrWhiteSpace(initial) || !Directory.Exists(initial))
        {
            initial = DutyLoader.GetUserAppDataDirectory();
        }

        var dlg = new OpenFolderDialog
        {
            Title = "選擇副本 JSON 資料夾",
            InitialDirectory = initial
        };

        if (dlg.ShowDialog(this) == true)
        {
            var selected = dlg.FolderName;
            _settings.CustomDutyFolder = selected;
            CustomFolderTextBox.Text = selected;
            UpdateCustomFolderWarning();
            DataSourceChanged?.Invoke();
        }
    }

    private void ClearCustom_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrEmpty(_settings.CustomDutyFolder))
        {
            return;
        }
        _settings.CustomDutyFolder = null;
        CustomFolderTextBox.Text = string.Empty;
        UpdateCustomFolderWarning();
        DataSourceChanged?.Invoke();
    }

    private void Close_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}

