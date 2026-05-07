using System.Text;
using Jobito.Api.Data;
using Jobito.Api.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.IdentityModel.Tokens.Jwt;

try
{
    // Disable default claim mapping to keep standard names like 'sub'
    JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();
    
    var builder = WebApplication.CreateBuilder(args);

    builder.Services.AddDbContext<AppDbContext>(options =>
        options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

    builder.Services.AddScoped<JwtTokenService>();
    builder.Services.AddControllers();

    // Increase request size limits for large base64 images
    builder.Services.Configure<Microsoft.AspNetCore.Http.Features.FormOptions>(options =>
    {
        options.ValueLengthLimit = int.MaxValue;
        options.MultipartBodyLengthLimit = int.MaxValue;
        options.MemoryBufferThreshold = int.MaxValue;
    });

    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("AllowAll", policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
    });
    builder.Services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo
        {
            Title = "Jobito API",
            Version = "v1",
            Description = "Recruitment backend for Jobito Flutter app."
        });

        options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
        {
            Name = "Authorization",
            Type = SecuritySchemeType.Http,
            Scheme = "bearer",
            BearerFormat = "JWT",
            In = ParameterLocation.Header,
            Description = "Enter: Bearer {your-token}"
        });

        options.AddSecurityRequirement(new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer"
                    }
                },
                Array.Empty<string>()
            }
        });
    });

    var jwtKey = builder.Configuration["Jwt:Key"] ?? "";
    var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "jobito-api";
    var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "jobito-mobile";
    var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

    builder.Services
        .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(options =>
        {
            // Keep JWT claim names (e.g. "sub") instead of mapped CLR claim URIs.
            options.MapInboundClaims = false;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = jwtIssuer,
                ValidAudience = jwtAudience,
                IssuerSigningKey = signingKey,
                ClockSkew = TimeSpan.FromMinutes(5)
            };
        });

    builder.Services.AddAuthorization();

    var app = builder.Build();

    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Jobito API v1");
        options.RoutePrefix = "swagger";
    });

    // app.UseHttpsRedirection(); // معطل لضمان التوافق مع الاستضافة المشتركة
    app.UseCors("AllowAll");
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapControllers();

    app.MapGet("/", () => Results.Content(@"
    <html>
        <body style='font-family: sans-serif; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; background: #f0f2f5;'>
            <div style='background: white; padding: 2rem; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); text-align: center;'>
                <h1 style='color: #1a73e8;'>🚀 Jobito API is Running</h1>
                <p>The backend is active and ready for connections.</p>
                <div style='margin-top: 1rem;'>
                    <a href='/swagger' style='text-decoration: none; background: #1a73e8; color: white; padding: 8px 16px; border-radius: 6px;'>Open Swagger UI</a>
                </div>
            </div>
        </body>
    </html>", "text/html"));

    app.MapGet("/health", () => Results.Ok(new
    {
        ok = true,
        service = "jobito-dotnet-api",
        timestamp = DateTime.UtcNow
    }));

    try
    {
        using var scope = app.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await SqlBootstrapper.EnsureTablesAsync(db);
        await SeedData.InitializeAsync(db);
    }
    catch (Exception ex)
    {
        Console.WriteLine("DB migration/bootstrap failed: " + ex.Message);
    }

    app.Run();
}
catch (Exception ex)
{
    File.WriteAllText("startup-error.txt", ex.ToString());
    throw;
}
