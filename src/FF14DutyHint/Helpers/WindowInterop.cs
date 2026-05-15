using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;

namespace FF14DutyHint.Helpers;

/// <summary>
/// 提供 Overlay 視窗常用的 Win32 互通函式。
/// </summary>
internal static class WindowInterop
{
    private const int GWL_EXSTYLE = -20;
    private const int WS_EX_NOACTIVATE = 0x08000000;
    private const int WS_EX_TOOLWINDOW = 0x00000080;

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll")]
    private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    /// <summary>
    /// 將視窗標記為 NoActivate（點擊時不會偷走焦點），並可選擇從 Alt+Tab 清單中隱藏。
    /// 必須在 SourceInitialized 之後呼叫（hWnd 已建立）。
    /// </summary>
    public static void MakeOverlayWindow(Window window, bool hideFromAltTab = true)
    {
        var helper = new WindowInteropHelper(window);
        var hwnd = helper.Handle;
        if (hwnd == IntPtr.Zero)
        {
            return;
        }

        var ex = GetWindowLong(hwnd, GWL_EXSTYLE);
        ex |= WS_EX_NOACTIVATE;
        if (hideFromAltTab)
        {
            ex |= WS_EX_TOOLWINDOW;
        }
        SetWindowLong(hwnd, GWL_EXSTYLE, ex);
    }
}
