using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Jobito.Api.Models;
using Microsoft.IdentityModel.Tokens;

namespace Jobito.Api.Services;

public class JwtTokenService(IConfiguration configuration)
{
    public string CreateToken(AppUser user)
    {
        var key = configuration["Jwt:Key"] ?? "";
        var issuer = configuration["Jwt:Issuer"] ?? "jobito-api";
        var audience = configuration["Jwt:Audience"] ?? "jobito-mobile";

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new("role", user.Role),
            new("name", user.Name),
            new("email", user.Email)
        };

        var creds = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddDays(30),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
