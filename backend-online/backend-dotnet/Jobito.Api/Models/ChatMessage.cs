namespace Jobito.Api.Models;

public class ChatMessage
{
    public string Id { get; set; } = $"msg_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
    public bool FromCompany { get; set; }
    public string Text { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
