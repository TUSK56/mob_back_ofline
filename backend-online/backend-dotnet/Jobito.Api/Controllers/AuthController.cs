using Jobito.Api.Data;
using Jobito.Api.Models;
using Jobito.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Authorization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Jobito.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(AppDbContext db, JwtTokenService jwt) : ControllerBase
{
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            var email = request.Email.Trim().ToLowerInvariant();
            var password = request.Password.Trim();
            var requestedRole = request.Role?.Trim().ToLowerInvariant();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                return BadRequest(new { message = "Email and password are required" });

            if (!string.IsNullOrWhiteSpace(requestedRole) && requestedRole is not ("user" or "company"))
                return BadRequest(new { message = "role must be either 'user' or 'company'" });

            // SQL Server NVARCHAR comparison is case-insensitive by default – no .ToLower() needed
            var user = await db.Users.FirstOrDefaultAsync(
                x => x.Email == email && x.Password == password);

            if (user is null)
                return Unauthorized(new { message = "Invalid credentials" });

            if (!string.IsNullOrWhiteSpace(requestedRole) &&
                user.Role.ToLowerInvariant() != requestedRole)
                return Unauthorized(new { message = $"Account is not a {requestedRole} account" });

            var token = jwt.CreateToken(user);
            return Ok(new
            {
                token,
                user = new
                {
                    id = user.Id,
                    role = user.Role,
                    name = user.Name,
                    email = user.Email
                }
            });
        }
        catch (Exception ex)
        {
            // Return real error details to help diagnose production issues
            return StatusCode(500, new
            {
                message = ex.Message,
                detail  = ex.InnerException?.Message ?? string.Empty,
                type    = ex.GetType().Name
            });
        }
    }

    [HttpPost("google")]
    public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
    {
        try
        {
            var payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken);
            var email = payload.Email.ToLowerInvariant();

            var user = await db.Users.FirstOrDefaultAsync(x => x.Email == email);
            if (user == null)
            {
                user = new AppUser
                {
                    Email    = email,
                    Name     = payload.Name,
                    GoogleId = payload.Subject,
                    PhotoUrl = payload.Picture,
                    Role     = "user"
                };
                db.Users.Add(user);
            }
            else
            {
                user.GoogleId = payload.Subject;
                user.PhotoUrl = payload.Picture;
                if (string.IsNullOrWhiteSpace(user.Name)) user.Name = payload.Name;
            }

            await db.SaveChangesAsync();

            var token = jwt.CreateToken(user);
            return Ok(new { token, user = MapUserToResponse(user) });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = "Invalid Google token", details = ex.Message });
        }
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        try
        {
            var email    = request.Email.Trim().ToLowerInvariant();
            var password = request.Password.Trim();
            var name     = request.Name.Trim();
            var role     = request.Role.Trim().ToLowerInvariant();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password) || string.IsNullOrWhiteSpace(name))
                return BadRequest(new { message = "Email, password, and name are required" });

            if (password.Length < 8)
                return BadRequest(new { message = "Password must be at least 8 characters" });

            if (role != "user" && role != "company" && role != "tradesman")
                return BadRequest(new { message = "Role must be 'user', 'company', or 'tradesman'" });

            var existingUser = await db.Users.FirstOrDefaultAsync(x => x.Email == email);
            if (existingUser != null)
                return BadRequest(new { message = "Email already exists" });

            var user = new AppUser
            {
                Email    = email,
                Password = password,
                Name     = name,
                Role     = role
            };

            db.Users.Add(user);
            await db.SaveChangesAsync();

            var token = jwt.CreateToken(user);
            return Ok(new
            {
                token,
                user = new
                {
                    id    = user.Id,
                    role  = user.Role,
                    name  = user.Name,
                    email = user.Email,
                    photoUrl = user.PhotoUrl,
                    phone    = user.Phone,
                    gender   = user.Gender,
                    dob      = user.Dob,
                    address  = user.Address,
                    title    = user.Title,
                    about    = user.About,
                    skills   = user.SkillsCsv?.Split(',', StringSplitOptions.RemoveEmptyEntries),
                    educationJson = user.EducationJson,
                    experienceJson = user.ExperienceJson,
                    socialLinksJson = user.SocialLinksJson,
                    portfolioImagesJson = user.PortfolioImagesJson
                }
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = ex.Message,
                detail  = ex.InnerException?.Message ?? string.Empty,
                type    = ex.GetType().Name
            });
        }
    }

    [Authorize]
    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        try
        {
            var userIdClaim = User.FindFirstValue(JwtRegisteredClaimNames.Sub)
                ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(userIdClaim) ||
                !int.TryParse(userIdClaim, out var userId))
                return Unauthorized();

            var user = await db.Users.FindAsync(userId);
            if (user == null) return NotFound();

            if (request.PhotoUrl != null) user.PhotoUrl = request.PhotoUrl;
            if (!string.IsNullOrWhiteSpace(request.Name)) user.Name = request.Name;
            
            // Company details update
            if (request.About != null) user.About = request.About;
            if (request.Staff != null) user.Staff = request.Staff;
            if (request.Location != null) user.LocationHeadquarters = request.Location;
            if (request.Classification != null) user.Classification = request.Classification;
            if (request.Website != null) user.Website = request.Website;
            if (request.Industry != null) user.Industry = request.Industry;
            if (request.CommercialRegister != null) user.CommercialRegister = request.CommercialRegister;
            if (request.NationalNumber != null) user.NationalNumber = request.NationalNumber;
            if (request.ContactsJson != null) user.ContactsJson = request.ContactsJson;
            
            if (request.FoundedDay != 0) user.FoundedDay = request.FoundedDay;
            if (request.FoundedMonth != 0) user.FoundedMonth = request.FoundedMonth;
            if (request.FoundedYear != 0) user.FoundedYear = request.FoundedYear;

            if (request.Locations != null) user.LocationsCsv = string.Join(",", request.Locations);
            if (request.Benefits != null) user.BenefitsCsv = string.Join(",", request.Benefits);
            if (request.TechStack != null) user.TechStackCsv = string.Join(",", request.TechStack);

            // User fields
            if (request.Phone != null) user.Phone = request.Phone;
            if (request.Gender != null) user.Gender = request.Gender;
            if (request.Dob != null) user.Dob = request.Dob;
            if (request.Address != null) user.Address = request.Address;
            if (request.Title != null) user.Title = request.Title;
            if (request.Skills != null) user.SkillsCsv = string.Join(",", request.Skills);
            if (request.EducationJson != null) user.EducationJson = request.EducationJson;
            if (request.ExperienceJson != null) user.ExperienceJson = request.ExperienceJson;
            if (request.SocialLinksJson != null) user.SocialLinksJson = request.SocialLinksJson;
            if (request.PortfolioImagesJson != null) user.PortfolioImagesJson = request.PortfolioImagesJson;

            await db.SaveChangesAsync();

            await db.SaveChangesAsync();

            return Ok(MapUserToResponse(user));
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                message = ex.Message,
                detail  = ex.InnerException?.Message ?? string.Empty,
                type    = ex.GetType().Name
            });
        }
    }

    private object MapUserToResponse(AppUser user)
    {
        return new
        {
            id = user.Id,
            role = user.Role,
            name = user.Name,
            email = user.Email,
            photoUrl = user.PhotoUrl,
            about = user.About,
            staff = user.Staff,
            location = user.LocationHeadquarters,
            locations = user.LocationsCsv?.Split(',', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>(),
            classification = user.Classification,
            benefits = user.BenefitsCsv?.Split(',', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>(),
            techStack = user.TechStackCsv?.Split(',', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>(),
            foundedDay = user.FoundedDay,
            foundedMonth = user.FoundedMonth,
            foundedYear = user.FoundedYear,
            website = user.Website,
            industry = user.Industry,
            commercialRegister = user.CommercialRegister,
            nationalNumber = user.NationalNumber,
            contactsJson = user.ContactsJson,
            
            // User profile fields
            phone = user.Phone,
            gender = user.Gender,
            dob = user.Dob,
            address = user.Address,
            title = user.Title,
            skills = user.SkillsCsv?.Split(',', StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>(),
            educationJson = user.EducationJson,
            experienceJson = user.ExperienceJson,
            socialLinksJson = user.SocialLinksJson,
            portfolioImagesJson = user.PortfolioImagesJson
        };
    }
}

public class UpdateProfileRequest
{
    public string? Name     { get; set; }
    public string? PhotoUrl { get; set; }
    public string? About    { get; set; }
    public string? Staff { get; set; }
    public string? Location { get; set; }
    public string? Classification { get; set; }
    public string? Website  { get; set; }
    public string? Industry { get; set; }
    
    public List<string>? Locations { get; set; }
    public List<string>? Benefits  { get; set; }
    public List<string>? TechStack { get; set; }
    
    public int FoundedDay   { get; set; }
    public int FoundedMonth { get; set; }
    public int FoundedYear  { get; set; }
    
    public string? CommercialRegister { get; set; }
    public string? NationalNumber { get; set; }
    public string? ContactsJson { get; set; }

    // User profile fields
    public string? Phone { get; set; }
    public string? Gender { get; set; }
    public string? Dob { get; set; }
    public string? Address { get; set; }
    public string? Title { get; set; }
    public List<string>? Skills { get; set; }
    public string? EducationJson { get; set; }
    public string? ExperienceJson { get; set; }
    public string? SocialLinksJson { get; set; }
    public string? PortfolioImagesJson { get; set; }
}

public class GoogleLoginRequest
{
    public string IdToken { get; set; } = "";
}

public class LoginRequest
{
    public string  Email    { get; set; } = "";
    public string  Password { get; set; } = "";
    public string? Role     { get; set; }
}

public class RegisterRequest
{
    public string Email    { get; set; } = "";
    public string Password { get; set; } = "";
    public string Name     { get; set; } = "";
    public string Role     { get; set; } = "user";
}
