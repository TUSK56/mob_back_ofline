using Jobito.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Jobito.Api.Data;

public static class SeedData
{
    public static async Task InitializeAsync(AppDbContext db)
    {
        if (!await db.Users.AnyAsync())
        {
            db.Users.AddRange(
                new AppUser
                {
                    Email = "user@jobito.com",
                    Password = "12345678",
                    Role = "user",
                    Name = "Ahmed User"
                },
                new AppUser
                {
                    Email = "company@jobito.com",
                    Password = "12345678",
                    Role = "company",
                    Name = "Jobito Labs"
                });
            await db.SaveChangesAsync();
        }

        if (!await db.Jobs.AnyAsync())
        {
            var company = await db.Users.FirstAsync(x => x.Email == "company@jobito.com");
            db.Jobs.Add(new JobPost
            {
                Id = "job_1",
                Title = "Flutter Mobile Developer",
                CompanyId = company.Id,
                CompanyName = "Jobito Labs",
                Location = "Cairo, Egypt",
                SalaryRange = "20k - 30k EGP",
                Type = "Full-time",
                TagsCsv = "Flutter,Dart,REST",
                CreatedAt = DateTime.UtcNow
            });
            await db.SaveChangesAsync();
        }
    }
}
