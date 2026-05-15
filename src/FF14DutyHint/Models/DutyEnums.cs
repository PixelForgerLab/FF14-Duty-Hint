namespace FF14DutyHint.Models;

/// <summary>
/// 副本內容品質等級（由 JSON 作者標示）。
/// </summary>
public enum DutyQuality
{
    /// <summary>未指定，由系統推斷（無 boss 顯示 Skeleton，有 boss 不顯示徽章）。</summary>
    Unspecified,

    /// <summary>骨架，只有副本基本資訊。</summary>
    Skeleton,

    /// <summary>需要更新，有部分內容但不完整或可能過時。</summary>
    NeedsUpdate,

    /// <summary>完整，內容完整且經過驗證。</summary>
    Excellent
}

/// <summary>
/// 副本來源（用來區分內建 / 使用者自訂）。
/// </summary>
public enum DutySource
{
    /// <summary>內建（隨 exe 發佈）。</summary>
    BuiltIn,

    /// <summary>使用者預設資料夾 (%APPDATA%/FF14DutyHint/duties)。</summary>
    UserAppData,

    /// <summary>使用者在設定中指定的自訂資料夾。</summary>
    UserCustomFolder
}
