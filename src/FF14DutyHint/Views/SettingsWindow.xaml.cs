using System;
using System.Windows;
using System.Windows.Controls.Primitives;
using FF14DutyHint.Services;

namespace FF14DutyHint.Views;

public partial class SettingsWindow : Window
{
    private readonly AppSettings _settings;
    private bool _initialized;

    public event Action<AppSettings>? SettingsChanged;

    public SettingsWindow(AppSettings settings)
    {
        InitializeComponent();
        _settings = settings;

        OpacitySlider.Value = settings.Opacity;
        FontSizeSlider.Value = settings.FontSize;
        TopmostCheck.IsChecked = settings.Topmost;
        UpdateValueTexts();
        _initialized = true;
    }

    private void UpdateValueTexts()
    {
        OpacityValueText.Text = $"{Math.Round(OpacitySlider.Value * 100)}%";
        FontSizeValueText.Text = $"{Math.Round(FontSizeSlider.Value)} pt";
    }

    private void OpacitySlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
    {
        if (!_initialized) return;
        _settings.Opacity = OpacitySlider.Value;
        UpdateValueTexts();
        SettingsChanged?.Invoke(_settings);
    }

    private void FontSizeSlider_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
    {
        if (!_initialized) return;
        _settings.FontSize = Math.Round(FontSizeSlider.Value);
        UpdateValueTexts();
        SettingsChanged?.Invoke(_settings);
    }

    private void TopmostCheck_Changed(object sender, RoutedEventArgs e)
    {
        if (!_initialized) return;
        _settings.Topmost = TopmostCheck.IsChecked == true;
        SettingsChanged?.Invoke(_settings);
    }

    private void Close_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
