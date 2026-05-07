using System.Security.Claims;
using Jobito.Api.Data;
using Jobito.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Jobito.Api.Controllers;

[ApiController]
[Route("api/jobs")]
[Authorize]
public class JobsController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var items = await (
            from job in db.Jobs
            join user in db.Users on job.CompanyId equals user.Id into users
            from user in users.DefaultIfEmpty()
            orderby job.CreatedAt descending
            select new
            {
                id = job.Id,
                title = job.Title,
                companyId = job.CompanyId.ToString(),
                companyName = job.CompanyName,
                companyLogoUrl = user != null ? user.PhotoUrl : null,
                location = job.Location,
                salaryRange = job.SalaryRange,
                type = job.Type,
                description = job.Description,
                responsibilities = job.ResponsibilitiesCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
                qualifications = job.QualificationsCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
                niceToHaves = job.NiceToHavesCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
                benefits = job.BenefitsCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
                classification = job.Classification,
                tags = job.TagsCsv.Split(',', StringSplitOptions.RemoveEmptyEntries),
                createdAt = job.CreatedAt,
                requiredCount = job.RequiredCount,
                acceptedCount = job.AcceptedCount,
                deadline = job.Deadline,
                status = job.Status,
                viewsCount = job.ViewsCount
            })
            .ToListAsync();
        return Ok(items);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string id)
    {
        if (!User.IsInRole("company"))
        {
            return Forbid();
        }

        var companyIdClaim = User.FindFirstValue("sub") ?? "0";
        var companyId = int.TryParse(companyIdClaim, out var idVal) ? idVal : 0;

        var job = await db.Jobs.FindAsync(id);
        if (job == null)
        {
            return NotFound(new { message = "Job not found" });
        }

        // Only the owning company can delete this job
        if (job.CompanyId != companyId)
        {
            return Forbid();
        }

        db.Jobs.Remove(job);
        await db.SaveChangesAsync();

        return Ok(new { message = "Job deleted successfully" });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateJobRequest request)
    {
        if (!User.IsInRole("company"))
        {
            return Forbid();
        }

        if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.CompanyName))
        {
            return BadRequest(new { message = "title and companyName are required" });
        }

        var companyIdClaim = User.FindFirstValue("sub") ?? "0";

        var entity = new JobPost
        {
            Id = $"job_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            Title = request.Title,
            CompanyId = int.TryParse(companyIdClaim, out var idVal) ? idVal : 0,
            CompanyName = request.CompanyName,
            Location = request.Location ?? "Remote",
            SalaryRange = request.SalaryRange ?? "Negotiable",
            Type = request.Type ?? "Full-time",
            Description = request.Description ?? "",
            ResponsibilitiesCsv = request.Responsibilities is { Length: > 0 } ? string.Join("|", request.Responsibilities) : "",
            QualificationsCsv = request.Qualifications is { Length: > 0 } ? string.Join("|", request.Qualifications) : "",
            NiceToHavesCsv = request.NiceToHaves is { Length: > 0 } ? string.Join("|", request.NiceToHaves) : "",
            BenefitsCsv = request.Benefits is { Length: > 0 } ? string.Join("|", request.Benefits) : "",
            Classification = request.Classification ?? "General",
            TagsCsv = request.Tags is { Length: > 0 } ? string.Join(",", request.Tags) : "",
            CreatedAt = DateTime.UtcNow,
            RequiredCount = request.RequiredCount ?? 1,
            Deadline = request.Deadline,
            Status = request.Status ?? "Open"
        };

        db.Jobs.Add(entity);
        db.Notifications.Add(new AppNotification
        {
            Id = $"noti_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            Type = "job_published",
            Text = $"{entity.CompanyName} posted a new role: {entity.Title}",
            CreatedAt = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        return StatusCode(201, new
        {
            id = entity.Id,
            title = entity.Title,
            companyId = entity.CompanyId.ToString(),
            companyName = entity.CompanyName,
            location = entity.Location,
            salaryRange = entity.SalaryRange,
            type = entity.Type,
            description = entity.Description,
            responsibilities = entity.ResponsibilitiesCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            qualifications = entity.QualificationsCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            niceToHaves = entity.NiceToHavesCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            benefits = entity.BenefitsCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            classification = entity.Classification,
            tags = entity.TagsCsv.Split(',', StringSplitOptions.RemoveEmptyEntries),
            createdAt = entity.CreatedAt,
            requiredCount = entity.RequiredCount,
            acceptedCount = entity.AcceptedCount,
            deadline = entity.Deadline,
            status = entity.Status,
            viewsCount = entity.ViewsCount
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] CreateJobRequest request)
    {
        if (!User.IsInRole("company"))
        {
            return Forbid();
        }

        var companyIdClaim = User.FindFirstValue("sub") ?? "0";
        var companyId = int.TryParse(companyIdClaim, out var idVal) ? idVal : 0;

        var job = await db.Jobs.FindAsync(id);
        if (job == null)
        {
            return NotFound(new { message = "Job not found" });
        }

        if (job.CompanyId != companyId)
        {
            return Forbid();
        }

        if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.CompanyName))
        {
            return BadRequest(new { message = "title and companyName are required" });
        }

        job.Title = request.Title;
        job.CompanyName = request.CompanyName;
        job.Location = request.Location ?? "Remote";
        job.SalaryRange = request.SalaryRange ?? "Negotiable";
        job.Type = request.Type ?? "Full-time";
        job.Description = request.Description ?? "";
        job.ResponsibilitiesCsv = request.Responsibilities is { Length: > 0 } ? string.Join("|", request.Responsibilities) : "";
        job.QualificationsCsv = request.Qualifications is { Length: > 0 } ? string.Join("|", request.Qualifications) : "";
        job.NiceToHavesCsv = request.NiceToHaves is { Length: > 0 } ? string.Join("|", request.NiceToHaves) : "";
        job.BenefitsCsv = request.Benefits is { Length: > 0 } ? string.Join("|", request.Benefits) : "";
        job.Classification = request.Classification ?? "General";
        job.TagsCsv = request.Tags is { Length: > 0 } ? string.Join(",", request.Tags) : "";
        job.RequiredCount = request.RequiredCount ?? job.RequiredCount;
        job.Deadline = request.Deadline;
        if (!string.IsNullOrEmpty(request.Status)) {
            job.Status = request.Status;
        }

        await db.SaveChangesAsync();

        return Ok(new
        {
            id = job.Id,
            title = job.Title,
            companyId = job.CompanyId.ToString(),
            companyName = job.CompanyName,
            location = job.Location,
            salaryRange = job.SalaryRange,
            type = job.Type,
            description = job.Description,
            responsibilities = job.ResponsibilitiesCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            qualifications = job.QualificationsCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            niceToHaves = job.NiceToHavesCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            benefits = job.BenefitsCsv.Split('|', StringSplitOptions.RemoveEmptyEntries),
            classification = job.Classification,
            tags = job.TagsCsv.Split(',', StringSplitOptions.RemoveEmptyEntries),
            createdAt = job.CreatedAt,
            requiredCount = job.RequiredCount,
            acceptedCount = job.AcceptedCount,
            deadline = job.Deadline,
            status = job.Status,
            viewsCount = job.ViewsCount
        });
    }
}

public class CreateJobRequest
{
    public string? Title { get; set; }
    public string? CompanyName { get; set; }
    public string? Location { get; set; }
    public string? SalaryRange { get; set; }
    public string? Type { get; set; }
    public string? Description { get; set; }
    public string[]? Responsibilities { get; set; }
    public string[]? Qualifications { get; set; }
    public string[]? NiceToHaves { get; set; }
    public string[]? Benefits { get; set; }
    public string? Classification { get; set; }
    public string[]? Tags { get; set; }
    public int? RequiredCount { get; set; }
    public DateTime? Deadline { get; set; }
    public string? Status { get; set; }
}
