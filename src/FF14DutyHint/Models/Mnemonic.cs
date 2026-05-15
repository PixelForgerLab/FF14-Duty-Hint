using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace FF14DutyHint.Models;

/// <summary>
/// 簡易提示（Mnemonic），可儲存單句或多句。
/// JSON 可寫：
///   "mnemonic": "單句"
///   "mnemonic": ["第一句", "第二句", "第三句"]
/// </summary>
[JsonConverter(typeof(MnemonicJsonConverter))]
public class Mnemonic
{
    public List<string> Lines { get; set; } = new();

    public bool HasContent => Lines.Count > 0 && Lines.Exists(l => !string.IsNullOrWhiteSpace(l));

    public bool IsSingleLine => Lines.Count == 1;
}

public class MnemonicJsonConverter : JsonConverter<Mnemonic>
{
    public override Mnemonic? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var m = new Mnemonic();

        if (reader.TokenType == JsonTokenType.Null)
        {
            return null;
        }

        if (reader.TokenType == JsonTokenType.String)
        {
            var s = reader.GetString();
            if (!string.IsNullOrEmpty(s))
            {
                m.Lines.Add(s);
            }
            return m;
        }

        if (reader.TokenType == JsonTokenType.StartArray)
        {
            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndArray)
                {
                    break;
                }
                if (reader.TokenType == JsonTokenType.String)
                {
                    var s = reader.GetString();
                    if (!string.IsNullOrEmpty(s))
                    {
                        m.Lines.Add(s);
                    }
                }
                else
                {
                    reader.Skip();
                }
            }
            return m;
        }

        reader.Skip();
        return m;
    }

    public override void Write(Utf8JsonWriter writer, Mnemonic value, JsonSerializerOptions options)
    {
        if (value.Lines.Count == 1)
        {
            writer.WriteStringValue(value.Lines[0]);
            return;
        }

        writer.WriteStartArray();
        foreach (var line in value.Lines)
        {
            writer.WriteStringValue(line);
        }
        writer.WriteEndArray();
    }
}

/// <summary>
/// 顯示用：一個簡易提示行 (含編號 / bullet)。
/// </summary>
public class MnemonicLine
{
    public string Bullet { get; set; } = string.Empty;
    public string Text { get; set; } = string.Empty;
}

public static class MnemonicExtensions
{
    /// <summary>
    /// 將 Mnemonic 拆成顯示用 lines。
    /// 1 行 → 不編號（用 💡 圖示）
    /// 多行 → 編號 1）2）3）...
    /// </summary>
    public static List<MnemonicLine> ToDisplayLines(this Mnemonic? mnemonic)
    {
        var result = new List<MnemonicLine>();
        if (mnemonic == null || mnemonic.Lines.Count == 0)
        {
            return result;
        }

        if (mnemonic.Lines.Count == 1)
        {
            result.Add(new MnemonicLine { Bullet = "•", Text = mnemonic.Lines[0] });
        }
        else
        {
            for (int i = 0; i < mnemonic.Lines.Count; i++)
            {
                result.Add(new MnemonicLine
                {
                    Bullet = $"{i + 1}）",
                    Text = mnemonic.Lines[i]
                });
            }
        }
        return result;
    }
}

