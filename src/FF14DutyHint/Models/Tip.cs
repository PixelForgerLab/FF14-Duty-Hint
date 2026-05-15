using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace FF14DutyHint.Models;

/// <summary>
/// 玩家角色分類，用於過濾顯示的提示。
/// </summary>
public enum PlayerRole
{
    /// <summary>通用，所有角色都會看到。</summary>
    Universal,
    Tank,
    Healer,
    Dps
}

public static class PlayerRoleExtensions
{
    public static PlayerRole ParseRole(string? raw)
    {
        return (raw ?? "").Trim().ToLowerInvariant() switch
        {
            "tank" or "t" => PlayerRole.Tank,
            "healer" or "heal" or "h" => PlayerRole.Healer,
            "dps" or "d" or "damage" => PlayerRole.Dps,
            "" or "universal" or "all" or "any" => PlayerRole.Universal,
            _ => PlayerRole.Universal
        };
    }

    public static string ToDisplayLabel(this PlayerRole role)
    {
        return role switch
        {
            PlayerRole.Tank => "坦職",
            PlayerRole.Healer => "補職",
            PlayerRole.Dps => "DPS",
            _ => "通用"
        };
    }
}

/// <summary>
/// 機制提示中的一條 tip，可帶有角色標記。
/// </summary>
[JsonConverter(typeof(TipJsonConverter))]
public class Tip
{
    public string Text { get; set; } = string.Empty;

    /// <summary>原始角色字串（用於序列化保留）。</summary>
    public string? RoleRaw { get; set; }

    [JsonIgnore]
    public PlayerRole Role => PlayerRoleExtensions.ParseRole(RoleRaw);

    public override string ToString() => Text;
}

/// <summary>
/// 自訂 JSON 轉換器：
/// - 讀 string → Tip { Text }
/// - 讀 object → Tip { Text, RoleRaw }
/// - 寫 Universal 角色 → 直接寫 string（保持簡潔）
/// - 寫其他角色 → 寫 object
/// </summary>
public class TipJsonConverter : JsonConverter<Tip>
{
    public override Tip Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.String)
        {
            return new Tip { Text = reader.GetString() ?? string.Empty };
        }

        if (reader.TokenType == JsonTokenType.StartObject)
        {
            var tip = new Tip();
            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndObject)
                {
                    return tip;
                }
                if (reader.TokenType != JsonTokenType.PropertyName)
                {
                    continue;
                }
                var prop = reader.GetString();
                reader.Read();
                switch (prop?.ToLowerInvariant())
                {
                    case "text":
                    case "tip":
                        tip.Text = reader.GetString() ?? string.Empty;
                        break;
                    case "role":
                    case "for":
                        tip.RoleRaw = reader.GetString();
                        break;
                    default:
                        reader.Skip();
                        break;
                }
            }
            return tip;
        }

        // 其他型別（null/number 等）忽略
        reader.Skip();
        return new Tip();
    }

    public override void Write(Utf8JsonWriter writer, Tip value, JsonSerializerOptions options)
    {
        if (value.Role == PlayerRole.Universal && string.IsNullOrWhiteSpace(value.RoleRaw))
        {
            writer.WriteStringValue(value.Text);
            return;
        }

        writer.WriteStartObject();
        writer.WriteString("text", value.Text);
        if (!string.IsNullOrWhiteSpace(value.RoleRaw))
        {
            writer.WriteString("role", value.RoleRaw);
        }
        writer.WriteEndObject();
    }
}
