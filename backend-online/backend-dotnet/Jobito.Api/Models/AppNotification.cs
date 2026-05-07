namespace Jobito.Api.Models;

public class AppNotification
{
    public string Id { get; set; } = $"noti_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
    public string Type { get; set; } = "";
    public string Text { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
