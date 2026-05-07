namespace Jobito.Api.Models;

public class JobApplication
{
    public string Id { get; set; } = $"app_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
    public int UserId { get; set; }
    public string UserName { get; set; } = "";
    public string JobId { get; set; } = "";
    public string Status { get; set; } = "Applied";
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
