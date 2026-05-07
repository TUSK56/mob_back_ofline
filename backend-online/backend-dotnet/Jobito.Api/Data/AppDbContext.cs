using Jobito.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace Jobito.Api.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<AppUser> Users => Set<AppUser>();
    public DbSet<JobPost> Jobs => Set<JobPost>();
    public DbSet<JobApplication> Applications => Set<JobApplication>();
    public DbSet<ChatMessage> Messages => Set<ChatMessage>();
    public DbSet<AppNotification> Notifications => Set<AppNotification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AppUser>(entity =>
        {
            entity.HasIndex(x => x.Email).IsUnique();
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.Password).HasMaxLength(128);
            entity.Property(x => x.Name).HasMaxLength(128);
            entity.Property(x => x.Role).HasMaxLength(32);
        });

        modelBuilder.Entity<JobPost>(entity =>
        {
            entity.Property(x => x.Title).HasMaxLength(256);
            entity.Property(x => x.CompanyName).HasMaxLength(256);
            entity.Property(x => x.Location).HasMaxLength(128);
            entity.Property(x => x.SalaryRange).HasMaxLength(128);
            entity.Property(x => x.Type).HasMaxLength(64);
            entity.Property(x => x.TagsCsv).HasMaxLength(1000);
        });

        modelBuilder.Entity<JobApplication>(entity =>
        {
            entity.Property(x => x.UserName).HasMaxLength(128);
            entity.Property(x => x.Status).HasMaxLength(64);
        });

        modelBuilder.Entity<ChatMessage>(entity =>
        {
            entity.Property(x => x.Text).HasMaxLength(2000);
        });

        modelBuilder.Entity<AppNotification>(entity =>
        {
            entity.Property(x => x.Type).HasMaxLength(64);
            entity.Property(x => x.Text).HasMaxLength(2000);
        });
    }
}
