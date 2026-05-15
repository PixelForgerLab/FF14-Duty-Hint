using System;
using System.Globalization;
using System.Windows;
using System.Windows.Data;
using System.Windows.Media;
using FF14DutyHint.Models;

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

/// <summary>
/// DutyQuality => 徽章背景色（Unspecified => Transparent）。
/// </summary>
public class QualityToBrushConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value switch
        {
            DutyQuality.Excellent => new SolidColorBrush(Color.FromRgb(0xFF, 0xC1, 0x07)),    // 金
            DutyQuality.NeedsUpdate => new SolidColorBrush(Color.FromRgb(0xFB, 0x8C, 0x00)),  // 橙
            DutyQuality.Skeleton => new SolidColorBrush(Color.FromRgb(0x60, 0x60, 0x68)),     // 灰
            _ => Brushes.Transparent
        };
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// DutyQuality => 標籤文字。
/// </summary>
public class QualityToLabelConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value switch
        {
            DutyQuality.Excellent => "優秀",
            DutyQuality.NeedsUpdate => "需更新",
            DutyQuality.Skeleton => "骨架",
            _ => string.Empty
        };
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// DutyQuality == Unspecified => Collapsed，其他 => Visible。
/// </summary>
public class QualityToVisibilityConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value is DutyQuality q && q != DutyQuality.Unspecified
            ? Visibility.Visible
            : Visibility.Collapsed;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// DutySource != BuiltIn => Visible (顯示「自訂」徽章)。
/// </summary>
public class UserSourceToVisibilityConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value is DutySource s && s != DutySource.BuiltIn
            ? Visibility.Visible
            : Visibility.Collapsed;
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

/// <summary>
/// DutySource => 顯示用標籤。
/// </summary>
public class SourceToLabelConverter : IValueConverter
{
    public object Convert(object? value, Type targetType, object? parameter, CultureInfo culture)
    {
        return value switch
        {
            DutySource.UserAppData => "自訂",
            DutySource.UserCustomFolder => "自訂*",
            _ => string.Empty
        };
    }

    public object ConvertBack(object? value, Type targetType, object? parameter, CultureInfo culture)
        => throw new NotSupportedException();
}

