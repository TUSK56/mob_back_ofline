namespace Jobito.Api.Models;

public class JobPost
{
    public string Id { get; set; } = $"job_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}";
    public int CompanyId { get; set; }
    public string Title { get; set; } = "";
    public string CompanyName { get; set; } = "";
    public string Location { get; set; } = "Remote";
    public string SalaryRange { get; set; } = "Negotiable";
    public string Type { get; set; } = "Full-time";
    public string Description { get; set; } = "";
    public string ResponsibilitiesCsv { get; set; } = "";
    public string QualificationsCsv { get; set; } = "";
    public string NiceToHavesCsv { get; set; } = "";
    public string BenefitsCsv { get; set; } = "";
    public string Classification { get; set; } = "";
    public string TagsCsv { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int ApplicationCount { get; set; } = 0;
    public int RequiredCount { get; set; } = 1;
    public int AcceptedCount { get; set; } = 0;
    public DateTime? Deadline { get; set; }
    public string Status { get; set; } = "Open";
    public int ViewsCount { get; set; } = 0;
}
