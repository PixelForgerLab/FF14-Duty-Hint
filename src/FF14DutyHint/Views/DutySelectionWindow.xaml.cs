using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using FF14DutyHint.Models;
using FF14DutyHint.Services;

namespace FF14DutyHint.Views;

public partial class DutySelectionWindow : Window
{
    private readonly List<Duty> _allDuties;

    public Duty? SelectedDuty { get; private set; }

    public DutySelectionWindow(List<Duty> duties, string? currentDutyId)
    {
        InitializeComponent();
        _allDuties = duties;
        DutyListBox.ItemsSource = duties;

        if (!string.IsNullOrEmpty(currentDutyId))
        {
            var current = duties.FirstOrDefault(d => d.Id == currentDutyId);
            if (current is not null)
            {
                DutyListBox.SelectedItem = current;
            }
        }
        if (DutyListBox.SelectedIndex < 0 && duties.Count > 0)
        {
            DutyListBox.SelectedIndex = 0;
        }

        Loaded += (_, _) => SearchBox.Focus();
    }

    private void SearchBox_TextChanged(object sender, TextChangedEventArgs e)
    {
        var keyword = SearchBox.Text?.Trim() ?? string.Empty;
        if (string.IsNullOrEmpty(keyword))
        {
            DutyListBox.ItemsSource = _allDuties;
        }
        else
        {
            DutyListBox.ItemsSource = _allDuties.Where(d =>
                (d.Name?.Contains(keyword, System.StringComparison.OrdinalIgnoreCase) ?? false) ||
                (d.NameEn?.Contains(keyword, System.StringComparison.OrdinalIgnoreCase) ?? false) ||
                (d.Expansion?.Contains(keyword, System.StringComparison.OrdinalIgnoreCase) ?? false)
            ).ToList();
        }
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
