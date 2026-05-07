using Jobito.Api.Data;
using Jobito.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Jobito.Api.Controllers;

[ApiController]
[Route("api/messages")]
[Authorize]
public class MessagesController(AppDbContext db) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var items = await db.Messages
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new
            {
                id = x.Id,
                fromCompany = x.FromCompany,
                text = x.Text,
                createdAt = x.CreatedAt
            })
            .ToListAsync();
        return Ok(items);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateMessageRequest request)
    {
        var entity = new ChatMessage
        {
            Id = $"msg_{DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            FromCompany = User.IsInRole("company"),
            Text = request.Text ?? "",
            CreatedAt = DateTime.UtcNow
        };
        db.Messages.Add(entity);
        await db.SaveChangesAsync();
        return StatusCode(201, new
        {
            id = entity.Id,
            fromCompany = entity.FromCompany,
            text = entity.Text,
            createdAt = entity.CreatedAt
        });
    }
}

public class CreateMessageRequest
{
    public string? Text { get; set; }
}
