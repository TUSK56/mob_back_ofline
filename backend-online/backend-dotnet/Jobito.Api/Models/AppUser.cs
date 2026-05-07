namespace Jobito.Api.Models;

public class AppUser
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    public string Password { get; set; } = "";
    public string Role { get; set; } = "user";
    public string Name { get; set; } = "";
    public string? GoogleId { get; set; }
    public string? PhotoUrl { get; set; }

    // User/Tradesman profile details
    public string? Phone { get; set; }
    public string? Gender { get; set; }
    public string? Dob { get; set; }
    public string? Address { get; set; }
    public string? Title { get; set; }
    public string? SkillsCsv { get; set; }
    public string? EducationJson { get; set; }
    public string? ExperienceJson { get; set; }
    public string? SocialLinksJson { get; set; }
    public string? PortfolioImagesJson { get; set; }

    // Company specific details
    public string? About { get; set; }
    public string? Staff { get; set; }
    public string? LocationHeadquarters { get; set; }
    public string? LocationsCsv { get; set; }
    public string? Classification { get; set; }
    public string? BenefitsCsv { get; set; }
    public string? TechStackCsv { get; set; }
    public int FoundedDay { get; set; }
    public int FoundedMonth { get; set; }
    public int FoundedYear { get; set; }
    public string? Website { get; set; }
    public string? Industry { get; set; }
    public string? CommercialRegister { get; set; }
    public string? NationalNumber { get; set; }
    public string? ContactsJson { get; set; }
}
