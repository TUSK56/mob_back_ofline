using System.Security.Claims;
using Jobito.Api.Data;
using Jobito.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Jobito.Api.Controllers;

[ApiController]
[Route("api/applications")]
[Authorize]
public class ApplicationsController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var items = await db.Applications
            .OrderByDescending(x => x.UpdatedAt)
            .Select(x => new
            {
                id = x.Id,
                userId = x.UserId.ToString(),
                userName = x.UserName,
                jobId = x.JobId,
                status = x.Status,
                updatedAt = x.UpdatedAt
            })
            .ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateApplicationRequest request)
    {
        if (!User.IsInRole("user"))
        {
            return Forbid();
        }
        if (string.IsNullOrWhiteSpace(request.JobId))
        {
            return BadRequest(new { message = "jobId is required" });
        }

        var job = await db.Jobs.FirstOrDefaultAsync(x => x.Id == request.JobId);
        if (job is null) return NotFound(new { message = "Job not found" });

        var userIdClaim = User.FindFirstValue("sub") ?? "0";
        var userNameClaim = User.FindFirstValue("name") ?? "Unknown";
        var userId = int.TryParse(userIdClaim, out var parsed) ? parsed : 0;

        // Duplicate Check
        var existing = await db.Applications.AnyAsync(x => x.UserId == userId && x.JobId == request.JobId);
        if (existing)
        {
            return Conflict(new { message = "You have already applied for this job" });
        }

        var entity = new JobApplication
        {
            Id = $"app_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            UserId = userId,
            UserName = string.IsNullOrWhiteSpace(request.UserName) ? userNameClaim : request.UserName!,
            JobId = request.JobId!,
            Status = "Applied",
            UpdatedAt = DateTime.UtcNow
        };

        db.Applications.Add(entity);
        
        // Increment application count
        job.ApplicationCount += 1;

        db.Notifications.Add(new AppNotification
        {
            Id = $"noti_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            Type = "application_created",
            Text = $"{entity.UserName} applied for {job.Title}",
            CreatedAt = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        return StatusCode(201, new
        {
            id = entity.Id,
            userId = entity.UserId.ToString(),
            userName = entity.UserName,
            jobId = entity.JobId,
            status = entity.Status,
            updatedAt = entity.UpdatedAt
        });
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> UpdateStatus(string id, [FromBody] UpdateApplicationStatusRequest request)
    {
        if (!User.IsInRole("company"))
        {
            return Forbid();
        }

        var entity = await db.Applications.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null) return NotFound(new { message = "Application not found" });

        var previousStatus = entity.Status;
        entity.Status = string.IsNullOrWhiteSpace(request.Status) ? "In Review" : request.Status!;
        entity.UpdatedAt = DateTime.UtcNow;

        var job = await db.Jobs.FirstOrDefaultAsync(x => x.Id == entity.JobId);
        if (job is not null)
        {
            if (previousStatus != "Accepted" && entity.Status == "Accepted")
            {
                if (job.AcceptedCount < job.RequiredCount)
                {
                    job.AcceptedCount += 1;
                }
                else
                {
                    return BadRequest(new { message = $"Cannot accept more candidates. Required count ({job.RequiredCount}) has been reached." });
                }
            }
            else if (previousStatus == "Accepted" && entity.Status != "Accepted")
            {
                // Decrement if moving away from Accepted
                job.AcceptedCount = Math.Max(0, job.AcceptedCount - 1);
            }
        }

        db.Messages.Add(new ChatMessage
        {
            Id = $"msg_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            FromCompany = true,
            Text = $"Application for {(job?.Title ?? "this role")} moved to {entity.Status}.",
            CreatedAt = DateTime.UtcNow
        });
        db.Notifications.Add(new AppNotification
        {
            Id = $"noti_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            Type = "application_status_changed",
            Text = $"Application moved to {entity.Status}",
            CreatedAt = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        return Ok(new
        {
            id = entity.Id,
            userId = entity.UserId.ToString(),
            userName = entity.UserName,
            jobId = entity.JobId,
            status = entity.Status,
            updatedAt = entity.UpdatedAt,
            requiredCount = job?.RequiredCount,
            acceptedCount = job?.AcceptedCount
        });
    }
}

public class CreateApplicationRequest
{
    public string? JobId { get; set; }
    public string? UserName { get; set; }
}

public class UpdateApplicationStatusRequest
{
    public string? Status { get; set; }
}
