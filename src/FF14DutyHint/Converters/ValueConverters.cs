using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;
using System.Windows.Media;

namespace FF14DutyHint.Converters;

/// <summary>
/// 將機制 type 字串轉成對應的色彩 Brush。
/// </summary>
public class MechanicTypeToBrushConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        var key = value switch
        {
            string s when !string.IsNullOrWhiteSpace(s) => s.Trim().ToLowerInvariant() switch
            {
                "raidwide" => "MechRaidwide",
                "tankbuster" or "tank-buster" => "MechTankbuster",
                "stack" or "share" => "MechStack",
                "spread" => "MechSpread",
                "aoe" => "MechAoe",
                _ => "MechOther"
            },
            _ => "MechOther"
        };

        if (Application.Current?.Resources[key] is Brush brush)
        {
            return brush;
        }
        return Brushes.Gray;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// 將機制 type 字串轉成顯示用標籤文字。
/// </summary>
public class MechanicTypeToLabelConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value switch
        {
            string s when !string.IsNullOrWhiteSpace(s) => s.Trim().ToLowerInvariant() switch
            {
                "raidwide" => "全體",
                "tankbuster" or "tank-buster" => "坦克",
                "stack" or "share" => "集合",
                "spread" => "散開",
                "aoe" => "AoE",
                _ => s
            },
            _ => "機制"
        };
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// 將集合是否為空轉成 Visibility（空=Collapsed）。
/// </summary>
public class CollectionToVisibilityConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        if (value is System.Collections.IEnumerable e)
        {
            var en = e.GetEnumerator();
            return en.MoveNext() ? Visibility.Visible : Visibility.Collapsed;
        }
        return Visibility.Collapsed;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// null 或空字串 => Collapsed。
/// </summary>
public class StringToVisibilityConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value is string s && !string.IsNullOrWhiteSpace(s) ? Visibility.Visible : Visibility.Collapsed;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}
